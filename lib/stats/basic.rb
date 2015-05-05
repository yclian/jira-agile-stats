require 'nokogiri'

module JiraAgileStats

  class Basic

    include JiraAgileStats::Utils

    def initialize(config)

      @auth = {
        username: config[:username],
        password: config[:password],
      }

      @url = config[:url].gsub(/\/$/, '') + '/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?'
      @url = @url + 'tempMax=1'
      @filters = config[:filters]

    end

    def get_raw(filter)
      url = @url + '&jqlQuery=' + @filters[filter] if @filters[filter] or 
        raise ArgumentError.new "Could not read filter '#{filter}'"
      got = HTTParty.get url, { basic_auth: @auth }
      xml = Nokogiri::XML(got.response.body) if got.response.is_a?(Net::HTTPSuccess) or
        raise Net::HTTPError.new "#{got.response.code} #{got.response.message}", got.response
    end

    def get(filter, date_since, date_until)
    
      xml = get_raw filter
      value = {
        count: 0,
      }
      value[:count] = xml.css('rss > channel > issue').first['total']

      return value
    
    end

    private :get_raw

  end
  
end

