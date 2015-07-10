# Derpy

## Getting Started

To run,

    bundle install
    SLACK_CHANNEL="[your-channel-here]" SLACK_INCOMING_PATH="[incoming-path-here]" bundle exec shotgun config.ru


To access,

    curl -v http://0.0.0.0:9292/gif?text=help



## Deploying

    git push heroku master
