require 'docthunder/meta'
require 'docthunder/function'

class DocThunder
  class SourceFile
    attr_accessor :functions
    def initialize
      @functions = []
    end
  end
end

class DocThunder
  def parse_headers(version)
    puts "    * Initialising parser for #{version.name}"
    headers.each do |header|
      puts "        * Block-wise parsing stage for #{header}"
      @file_obj = DocThunder::SourceFile.new
      parse_header(@file_obj, header)
      puts @file_obj.functions.to_json
    end
  end


  def parse_header(file_obj, filepath)
    lineno = 0
    content = File.readlines(filepath)

    content.each do |line|
      lineno = lineno + 1
      line = line.strip()
      
      #
      # Look for Preprocessor Macros
      #
      if line[0, 1] == '#' # found a preprocessor directive
        if m = /\#define (.*?) (.*)/.match(line)
          name = m[1].strip
          value = m[2].strip
          comment = ""
          if m = /\/\/\/< (.*)/.match(value)
            comment = m[1]
          end
        else
          next
        end
      end
    end

    #
    # Find functions
    #    
    lineno = 0
    data = []
    current = -1
    in_block = false
    in_comment = false

    content.each do |line|
      lineno = lineno + 1
      line = line.strip()

      next if line.size == 0
      next if line[0, 1] == '#'

      in_block = true if line =~ /\{/

      if m = /(.*?)\/\*(.*?)\*\//.match(line)    # e.g. matching: code /* comment */
        code = m[1]
        comment = m[2]
        current += 1
        data[current] ||= {:comments => clean_comment(comment), :code => [code], :line => lineno}
      elsif m = /(.*?)\/\/(.*?)/.match(line)    # e.g. matching: code // comment
        code = m[1]
        comment = m[2]
        current += 1
        data[current] ||= {:comments => clean_comment(comment), :code => [code], :line => lineno}
      else
        if line =~ /\/\*/
          in_comment = true
          current += 1
        elsif current == -1
          current += 1
        end

        data[current] ||= {:comments => '', :code => [], :line => lineno}
        data[current][:lineto] = lineno   

        if m = /(.*?);$/.match(line)        # e.g. matching: code;
          if (data[current][:code].size > 0) && !in_block
            current += 1
          else
            data[current][:code] << line
            current += 1
          end
          in_comment = false if line =~ /\*\//
          in_block = false if line =~ /\}/
        else 
          if in_comment
            data[current][:comments] += clean_comment(line) + "\n"
          else
            data[current][:code] << line
          end
        end
      end    

    end

    data.compact!    # This will remove any Nil entries!

    puts "        * Extracting file meta-data"
    meta = Meta.new(data, filepath)

    puts "        * Extracting function documentation"
    functions = extract_functions(data)

    file_obj.functions = functions
  end

  def extract_functions(data)
    functions = []
    data.each do |block|
      next if block[:code].size == 0
      
      code = block[:code].join(" ")
      comments = block[:comments]

      if m = /^(.*?) ([a-zA-Z_]+)\((.*)\)/.match(code)
        ret = m[1].strip
        name = m[2].strip
        argstring = m[3].strip

        function = Function.new(ret, name, argstring, comments)

        functions << function
      end

    end

    functions
  end
end

