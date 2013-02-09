class DocThunder
  class Author
    attr_reader :name
    attr_reader :email

    def initialize(name, email)
      @name = name
      @email = email
    end

  end
end
