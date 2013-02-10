require 'docthunder/author'
require 'docthunder/config'

class DocThunder
  class Project
    attr_reader :name
    attr_reader :authors
    attr_reader :type
    attr_reader :input_dir, :sigs
    attr_accessor :versions

    attr_reader :config

    def initialize(docthunder, config_options)
      @docthunder = docthunder
      @name = config_options["name"]
      @authors = []

      @sigs = {}
      @groups = {}

      if config_options["authors"]
        config_options["authors"].each do |author|
          @authors << Author.new(author["name"], author["email"])
        end
      end

      @authors.each do |author|
        puts "    * Detected author #{author.name} <#{author.email}>"
      end

      @type = config_options["type"]
      @input_dir = config_options["input"]

      @versions = []

      @workdir = docthunder.mkdir_temp()
      @config = DocThunder::Config.new(@workdir, @input_dir)
    end

    def tally_sigs      
      lastsigs ||= {}

      @versions.each do |version|
        functions = {}
        version.files.each do |file|
          file.functions.each do |function|
            functions[function.name] = function
          end
        end

        functions.each do |fun_name, function|
          if !@sigs[fun_name]
            @sigs[fun_name] ||= {:exists => [], :changes => {}}
          else
            if lastsigs[fun_name] != function.sig
              @sigs[fun_name][:changes][version.name] = true
            end
          end
          @sigs[fun_name][:exists] << version.name
          lastsigs[fun_name] = function.sig          
        end
      end        

    end

  end
end
