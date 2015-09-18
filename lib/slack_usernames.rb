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
    unmentioned = USERNAMES - names
    unmentioned.join(", ")
  end
end
