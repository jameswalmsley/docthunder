class DocThunder
  class Project
    class Version
      attr_reader :name
      attr_accessor :functions

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

        #@functions.to_json

        puts "    * Running heuristics on object tree"        
        puts "    * Generating #{@name} Documents based on template".green
      end
    end
  end
end
