require 'twitter_status'
Liquid::Template.register_tag('twittertimeline', MephistoTwitter::TwitterTimeline)
