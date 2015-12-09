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

  SLACK_IDS = {
    'U02LQ7Q5S' => 'cjh',
    'U02LQ8S12' => 'edgy',
    'U02SGBESY' => 'mk',
    'U033UK4SX' => 'mttwrnr',
    'U02LP2S1R' => 'rhino',
    'U02M21STC' => 'aaron',
    'U03B2L3EW' => 'dj',
    'U02SPEN6K' => 'david'
  }

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
