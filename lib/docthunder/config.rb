class DocThunder
  class Config
    attr_reader :workdir
    attr_reader :input

    def initialize(workdir, input)
      @workdir = workdir
      @input = input
    end
  end
end
