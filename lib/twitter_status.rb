require 'twitter'

module MephistoTwitter
  class TwitterTimeline < Liquid::Block
    Syntax = /((#{Liquid::TagAttributes}\s?,?\s?)*)as\s([a-zA-Z_.-]+)/
    
    def initialize(tag_name, markup, tokens)
      super
      if markup =~ Syntax
        @options = parse_options($1)
        @as = $5
        raise Liquid::SyntaxError.new(
	  "Syntax Error in tag 'twittertimeline' - 'user' and 'type' arguments are mandatory") unless @options[:user] && @options[:type]
      else
        raise Liquid::SyntaxError.new(
	  "Syntax Error in tag 'twittertimeline' - Valid syntax: twittertimline [ opt : 'val', opt : 'val' ] as [name]")
      end
    end
    
    def render(context)
      result, options = [], evaluate(@options, context)
      timeline = Twitter::Timeline.new(options[:user], options[:type])
      timeline = chart[0..options[:top].to_i - 1] if options[:top]
      
      timeline.each_with_index do |item, index|
        context.stack do
          context['twittertimeline'] = { 'index' => index + 1 }
          context[@as] = item
          result << render_all(@nodelist, context)
        end
      end
      
      result
    rescue 
      'Something went wrong.'
    end
    
    private
    
    def parse_options(opt_string)
      pairs, opts = opt_string.split(','), {}
      pairs.each do |pair|
        opt, value = pair.split(':')
        opts[opt.strip.to_sym] = value.strip
      end
      return opts
    end
    
    def evaluate(options, context)
      evaluated = {}
      options.each { |opt, value| evaluated[opt] = context[value]  }
      return evaluated
    end
  end
end
