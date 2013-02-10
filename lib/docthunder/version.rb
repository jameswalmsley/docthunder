class DocThunder
  class Project
    class Version
      attr_reader :name
      attr_accessor :files

      def initialize(name, config)
        @name = name
        @config = config
        @files = []
      end

      def parse(docthunder)
        #puts "    * Checking out #{@name} into #{@config.workdir}"
        Dir.chdir(@config.workdir) do
          docthunder.checkout(@name, @config.workdir)
          docthunder.parse_headers(self)
        end

      end

      def to_json(*a)
        {
          "name" => @name,
          "files" => @files,
        }.to_json(*a)
      end
    end
  end

  class SourceFile
    attr_accessor :functions
    attr_accessor :meta
    attr_accessor :lines
    attr_reader   :name
    def initialize(name)
      @functions = []
      @meta = {}
      @lines = 0
      @name = name
    end

    def to_json(*a)
      functions = []
      @functions.each do |function|
        functions << function.name
      end

      {
        :file => @name,
        :meta => @meta,
        :functions => functions,        
        :lines => @lines
      }.to_json(*a)
    end

  end

end
