class DocThunder
  class CLI

    def self.doc(input_dir, options)
      doc = DocThunder.new(input_dir)
      doc.init_project
      doc.parse
      #doc.generate_doc(selected_template)
    end

    def self.gen(file)
temp = <<-TEMPLATE
{
 "name":   "project",
 "github": "user/project",
 "input":  "include/lib",
 "prefix": "lib_",
 "output": "docs"
}
TEMPLATE
      puts "Writing to #{file}"
      File.open(file, 'w+') do |f|
        f.write(temp)
      end
    end

  end
end
