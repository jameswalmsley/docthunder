class DocThunder
  class Project
    class Version
      attr_reader :name
      def initialize(name, config)
        @name = name
        @config = config
      end

      def parse(docthunder)
        puts "    * Checking out #{@name} into #{@config.workdir}"
        Dir.chdir(@config.workdir) do
          docthunder.checkout(@name, @config.workdir)
          docthunder.parse_headers(self)
        end
        puts "    * Parsing and building object tree for #{@name}"
      end
    end
  end
end
