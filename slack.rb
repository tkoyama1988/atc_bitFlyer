require 'slack/incoming/webhooks'
require 'dotenv'

Dotenv.load

def post_slack(str)
  slack = Slack::Incoming::Webhooks.new ENV["WEBHOOK_URL"]
  slack.post str
end
