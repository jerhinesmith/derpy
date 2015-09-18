class ArgParser

  def initialize(string)
    @args = string.to_s.split(" ")
  end

  def to_hash
    {
      :command => @args.shift,
      :text => @args.shift
    }
  end
end
