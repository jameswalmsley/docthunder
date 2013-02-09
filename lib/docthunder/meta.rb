class DocThunder
  class Meta
    attr_reader :file, :brief, :defgroup, :ingroup, :authors, :copyright, :description
    
    def initialize(data)
      @file, @brief, @defgroup, @ingroup, @copyright = nil
      @authors = []
      data.each do |block|
        if block[:code].size == 0          
          puts block[:comments]         
          block[:comments].each_line do |comment|
            m = []
            @file = m[1].strip if m = /@file\s(.*?)$/.match(comment)
            @brief = m[1].strip if m = /@brief\s(.*?)$/.match(comment)
            @defgroup = m[1].strip if m = /@defgroup\s(.*?)$/.match(comment)
            @ingroup = m[1].strip if m = /@defgroup\s(.*?)$/.match(comment)
            @copyright = m[1].strip if m = /@copyright\s(.*?)$/.match(comment)
          end
        end
      end

      puts "File: #{@file} : defgroup #{@defgroup}"
      
    end

  end
end
