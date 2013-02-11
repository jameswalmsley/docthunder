require 'json'
require 'docthunder/c-parser.rb'
require 'docthunder/utils.rb'
require 'docthunder/project.rb'
require 'docthunder/author.rb'
require 'docthunder/version.rb'
require 'rocco'
require 'docthunder/layout.rb'

class DocThunder
  Version = VERSION = "0.0.1"

  def initialize(config_file)
    raise "You need to specify a config file" if !config_file
    raise "You need to specify a valid config file" if !valid_config(config_file)
  end

  def valid_config(file)
    return false if !File.file?(file)
    fpath = File.expand_path(file)
    @project_dir = File.dirname(fpath)
    @config_file = File.basename(fpath)
    @options = JSON.parse(File.read(fpath))
    true
  end

  def init_project
    puts "* Initialising DocThunder and preparing parser for #{@options["name"]}"
    @project = Project.new(self, @options)

    puts "* Retrieving versions..."
    versions = get_versions()
    versions << "HEAD"

    versions.each do |version_name|
      #puts "    * Found #{version_name}"
      #version_object = Version.new(version)
      @project.versions << Project::Version.new(version_name, @project.config)
    end
  end

  def parse
    @project.versions.each do |version|
      puts "* Processing version #{version.name}".bold.blue
      version.parse(self)
    end

    puts "* Running heuristics on object tree"
    @project.tally_sigs

  end

  def generate_docs
    puts "* Generating output documents".green

    outdir = mkdir_temp

    Dir.chdir(outdir) do
      versions = []
      @groups = {}
      @project.versions.each do |version|
        versions << version.name
        version.files.each do |file|
          file.functions.each do |function|
            @groups[function.name] = file.name.gsub('/', '_')
          end
        end
      end

      project = {
        :versions => versions.reverse,
        :github => @options['github'],
        :name => @project.name,
        :signatures => @project.sigs,
        :groups => @groups,
      }

      File.open("project.json", "w+") do |f|
        f.write(JSON.pretty_generate(project))
      end

      @project.versions.each do |version|

        #
        # Generate Examples!
        #
        tf = File.expand_path(File.join(File.dirname(__FILE__), '..', 'templates/docurium', 'layout.mustache'))
        if ex = @options['examples']
          workdir = mkdir_temp
          Dir.chdir(workdir) do
            with_git_env(workdir) do
              `git rev-parse #{version.name}:#{ex} 2>&1` # Check that examples exist in this version.
              if $?.exitstatus == 0
                puts "  - processing examples for #{version.name}"

                `git read-tree #{version.name}:#{ex}`
                `git checkout-index -a`

                files = []
                Dir.glob("**/*.c") do |file|
                  next if !File.file?(file)
                  files << file
                end

                files.each do |file|
                  puts "    # #{file}"

                  # Highlight and Roccoize
                  rocco = Rocco.new(file, files, {:language => 'c'})
                  rocco_layout = Rocco::Layout.new(rocco, tf)
                  rocco_layout.version = "#{version.name}"

                  rf = rocco_layout.render

                  rf_path = File.basename(file).split('.')[0..-2].join('.') + '.html'
                  rel_path = "ex/#{version.name}/#{rf_path}"
                  rf_path = File.join(outdir, rel_path)

                  #
                  # Create links to docurium documentation output.
                  #

                  # Write example to docs dir.
                  FileUtils.mkdir_p(File.dirname(rf_path))
                  File.open(rf_path, 'w+') do |f|
                    @examples ||= []
                    @examples << [file, rel_path]
                    f.write(rf)
                  end

                end

              end
            end
          end
        end

        files = []
        function_hash = {}

        version.files.each do |file|
          files << file
          file.functions.each do |function|
            function_data = {
              :description => function.brief,
              :return => {:type => function.return, :comment => function.return_comment},
              :args => function.args,
              :argline => function.argline,
              :file => file.name,
              :line => function.line,
              :lineto => function.lineto,
              :comments => function.comments,
              :sig => function.sig,
              :rawComments => (function.brief + "\n\n" + function.comments).strip,
              :group => file.name.gsub('/', '_')
            }
            function_hash[function.name] = function_data
          end
        end

        groups = []

        version.files.each do |file|
          grp = []
          grp_functions = []
          grp << file.name.gsub('/', '_')

          file.functions.each do |function|
            grp_functions << function.name
          end

          grp << grp_functions

          groups << grp
        end

        version_data = {
          :files => files,
          :functions => function_hash,
          :globals => {},
          :types => [],
          :prefix => "include",
          :groups => groups,
          :examples => @examples
        }

        File.open(File.join(outdir, "#{version.name}.json"), "w+") do |f|
          f.write(JSON.pretty_generate(version_data))
        end

      end

      if br = @options['branch']

        Dir.chdir(outdir) do
          here = File.expand_path(File.dirname(__FILE__))
          FileUtils.cp_r(File.join(here, '..', 'templates/docurium', '.'), '.')
        end

        puts "* Writing to branch #{br}"
        ref = "refs/heads/#{br}"
        with_git_env(outdir) do
          branches = `git branch`
          branches.gsub!('*', '')
          if m = /\s#{br}/.match(branches)
            psha = `git rev-parse #{ref}`.chomp
          else
            psha = "refs/heads/#{br}"
          end

          `git add -A`
          tsha = `git write-tree`.chomp
          puts "    - Wrote tree #{tsha}"
          if(psha == ref)
            csha = `echo 'generated docs' | git commit-tree #{tsha}`.chomp
          else
            csha = `echo 'generated docs' | git commit-tree #{tsha} -p #{psha}`.chomp
          end
          puts "    - Wrote commit #{csha}"
          `git update-ref -m 'generated docs' #{ref} #{csha}`
          puts "    - Updated #{br}"
        end
      else
        final_dir = File.join(@project_dir, @options['output'] || 'docs')
        puts "* output html into #{final_dir}"

        FileUtils.mkdir_p(final_dir)
        here = File.expand_path(File.dirname(__FILE__))
        Dir.chdir(final_dir) do
          FileUtils.cp_r(File.join(here, '..', 'templates/docurium', '.'), '.')
          FileUtils.cp_r(File.join(outdir, '.'), '.')
        end
      end
    end
  end
end
