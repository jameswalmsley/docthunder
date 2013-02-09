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
      puts "    * Found #{version_name}"
      #version_object = Version.new(version)
      @project.versions << Project::Version.new(version_name, @project.config)
    end
  end

  def parse
    @project.versions.each do |version|
      puts "* Processing version #{version.name}"
      version.parse(self)
    end
  end

end
