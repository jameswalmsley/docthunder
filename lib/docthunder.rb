require 'json'
require 'docthunder/c-parser.rb'
require 'docthunder/utils.rb'
require 'docthunder/project.rb'
require 'docthunder/author.rb'
require 'docthunder/version.rb'

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
    puts "* outputting to #{outdir}"

    Dir.chdir(outdir) do
      versions = []
      @groups = {}
      @project.versions.each do |version|
        versions << version.name
        version.files.each do |file|
          file.functions.each do |function|
            @groups[function.name] = "test"
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
              :group => file.name
            }
            function_hash[function.name] = function_data
          end          
        end        

        groups = []

        version.files.each do |file|
          grp = []
          grp_functions = []
          grp << file.name

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
          :groups => groups
        }

        File.open(File.join(outdir, "#{version.name}.json"), "w+") do |f|
          f.write(JSON.pretty_generate(version_data))
        end
      end

      if br = @options['branch']

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
