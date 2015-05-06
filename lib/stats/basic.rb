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

    def get_raw(filters, date_since, date_until)

      url = get_url_with_query filters, date_since, date_until
      puts url
      got = HTTParty.get url, { basic_auth: @auth }
      xml = Nokogiri::XML(got.response.body) if got.response.is_a?(Net::HTTPSuccess) or
        raise Net::HTTPError.new "#{got.response.code} #{got.response.message}", got.response
    end

    def get_url_with_query(filters, date_since, date_until)

      query = ''
      filters = [filters] unless filters.is_a? Array
      filters.each { |f|
 
        raise ArgumentError.new "Could not read filter '#{f}'" if !@filters[f]
        if query.empty?
          query = @filters[f]
        else
          query = '(' + query + ') AND (' + @filters[f] + ')'
        end

      }
      query = query % { date_since: date_since, date_until: date_until }
      return @url + '&jqlQuery=' + query

    end

    def get(filters, date_since, date_until)
    
      xml = get_raw filters, date_since, date_until
      value = {
        count: 0,
      }
      value[:count] = xml.css('rss > channel > issue').first['total']
      return value
    
    end

    private :get_raw, :get_url_with_query

  end
  
end

