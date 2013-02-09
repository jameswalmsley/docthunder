require 'docthunder/author'
require 'docthunder/config'

class DocThunder
  class Project
    attr_reader :name
    attr_reader :authors
    attr_reader :type
    attr_reader :input_dir
    attr_accessor :versions

    attr_reader :config

    def initialize(docthunder, config_options)
      @docthunder = docthunder
      @name = config_options["name"]
      @authors = []

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
  end
end
