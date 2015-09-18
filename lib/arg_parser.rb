class ArgParser

  def initialize(string)
    args = string.to_s.split(" ")

    {
      :command => args.shift,
      :text => args.shift
    }
  end
end
