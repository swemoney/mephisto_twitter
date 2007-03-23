require 'rexml/document'
require 'rexml_extensions'
require 'net/http'
require 'rubygems'
require 'active_support'

module Twitter
  
  module Cache
    
    class Basic < Hash
      attr_reader :created_on
      
      def initialize(*args)
        @created_on = Time.now
      end
      
      def cache(uri, data)
        self[uri] = data
      end
      
      def expire(pattern)
        each { |uri, val| delete uri if uri =~ pattern }
      end
    end
    
  end
  
  class TwitterError < StandardError; end
  
  class Timeline < Array

    TIMELINE_TYPES = %w{user_timeline friends_timeline friends}
    
    @@host = 'twitter.com'
    @@port = 80
    @@base_url = '/statuses'
    
    @@cache_class = Cache::Basic
    @@cache = @@cache_class.new
    @@expire_cache_every = 10.minutes
    @@auto_expire_cache = true
    
    cattr_accessor :host, :port, :base_url, :cache, :cache_class, :expire_cache_every, :auto_expire_cache
    
    def initialize(user, type)
      @user, @type = user, type
      raise TwitterError, "That type (#{type}) of twitter timeline is not valid." unless TIMELINE_TYPES.include? type
      parse(request)
    end
    
    protected
    def uri
      "#{base_url}/#{@type}/#{@user.to_s}.xml"
    end
    
    def request
      check_cache if auto_expire_cache
      return cache[uri] if cache.has_key? uri
      
      Net::HTTP.start(host, port) do |http|
        cache.cache uri, http.get(uri).body
      end
    rescue
      raise TwitterError, "Ran into some turbulance connecting to twitter: #{$!}"
    end
    
    def parse(response)
      doc = REXML::Document.new response
      doc.root.elements.each do |element|
        push element.to_hash(HashWithIndifferentAccess.new)
      end
    rescue TwitterError, 'Something went wrong. I can\'t parse this.'
    end
    
    def check_cache
      self.cache = cache_class.new if Time.now > (cache.created_on + expire_cache_every)
    end
  end
end
