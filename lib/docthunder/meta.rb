class DocThunder
  class Meta
    attr_reader :file, :brief, :defgroup, :ingroup, :authors, :copyright, :description
    
    def initialize(data, filename)
      @file, @brief, @defgroup, @ingroup, @copyright = nil
      file_line=0
      @authors = []
      data.each do |block|
        if block[:code].size == 0          
          lineno = 0
          block[:comments].each_line do |comment|            
            m = []
            if m = /@file\s(.*?)$/.match(comment)
              @file = m[1].strip
              file_line = block[:line] + lineno
            end
            @brief = m[1].strip if m = /@brief\s(.*?)$/.match(comment)
            @defgroup = m[1].strip if m = /@defgroup\s(.*?)$/.match(comment)
            @ingroup = m[1].strip if m = /@ingroup\s(.*?)$/.match(comment)
            @copyright = m[1].strip if m = /@copyright\s(.*?)$/.match(comment)
            @authors << m[1].strip if m = /@author\s(.*?)$/.match(comment)
            lineno = lineno + 1
          end
        end
      end

      if @file == nil
        @file = File.basename(filename)
      end

      if @file != File.basename(filename)
        puts "        ! WARNING: #{filename}:#{file_line} :: @file directive (#{@file}) mis-matches with filename... using real-name"
      end

      p self

    end

  end
end
