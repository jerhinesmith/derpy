module Slack

  USERNAMES = %w(
    aaron
    cjh
    david
    dj
    edgy
    mk
    mttwrnr
    rhino
  )

  USERNAMES.each do |username|
    method_definition = "def self.mention_#{username}; '@#{username}';  end"
    module_eval method_definition
  end

  def self.mention_all_except(names)
    names_to_mention = USERNAMES - names
    names_to_mention.map do |username|
      module_eval "self.mention_#{username}"
    end
  end
end
