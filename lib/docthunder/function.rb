class DocThunder

  class Argument
    attr_reader :type, :name, :comment

    def initialize(type, name, comment)
      @type = type
      @name = name
      @comment = comment
    end

    def to_json(*a)
      {
        "type" => @type,
        "name" => @name,
        "comment" => @comment
      }.to_json(*a)
    end

  end

  class Function
    attr_reader :return, :name, :args, :return_comment, :brief, :description

    def initialize(return_type, name, argstring, comments)
      @name = name
      @return = return_type
      @args = []
      
      # Process the argument names!

      # Replace ridiculous syntax
      args = argstring.gsub(/(\w+) \(\*(.*?)\)\(([^\)]*)\)/) do |m|
        type, name = $1, $2
        cast = $3.gsub(',', '###')        
        "#{type}(*)(#{cast}) #{name}" 
      end
      
      # Split up the individual arguments, so we can make nice objects describing them
      args = args.split(',').map do |arg|
        arg_elements = arg.strip.split(/\s/)

        if arg_elements.size > 1
          var = arg_elements.pop
          type = arg_elements.join(' ').gsub('###', ',') + ' '

          # Remove pointers from names, and push to end of type name

          var.gsub!('*') do |m|
            type += '*'
            ''
          end

        else
          type = ""
          var = arg_elements.pop.strip
        end
        desc = ''

        comments.gsub(/\@param\s#{Regexp.escape(var)}\s([^@]*)/m) do |m|
          desc = $1.gsub("\n", ' ').gsub("\t", ' ').strip
        end

        comments.gsub(/\@#{Regexp.escape(var)}\s([^@]*)/m) do |m|
          desc = $1.gsub("\n", ' ').gsub("\t", ' ').strip
        end
        
        {:type => type.strip, :name => var.strip, :comment => desc.strip}                
      end

      args.each do |arg|
        @args << Argument.new(arg[:type], arg[:name], arg[:comment])
      end

      sig = args.map do |arg|
        arg[:type].to_s
      end.join('::')
      
      return_comment = ''

      comments.gsub(/\@return\s([^@]*)/m) do |m|
        return_comment += $1.strip
      end

    end

    def to_json(*a)
      {
        "name" => @name,
        "args" => @args
      }.to_json(*a)

    end

  end
end
