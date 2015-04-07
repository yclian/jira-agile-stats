module JiraAgileStats

  class Performance

    include JiraAgileStats::Utils

    def initialize(config, board)

      @auth = {
        username: config[:username],
        password: config[:password],
      }

      if config[:boards][board.to_s]
        @url = config[:url] + '/rest/greenhopper/1.0/rapid/charts/controlchart.json?rapidViewId=' + board.to_s
        config[:boards][board.to_s][:filters].each { |f|
          @url = @url + '&quickFilterId=' + f.to_s
        } if config[:boards][board.to_s]
        @board = config[:boards][board.to_s] 
      else
        raise ArgumentError.new "Could not read board configuration (#{board})"
      end

    end

    def get_raw(swimlane, filters, date_since, date_until)

      url = @url + '&swimlaneId=' + swimlane.to_s
      url = url + "&days=custom&from=#{date_since}&to=#{date_until}" 

      filters.each { |f| url = url + '&quickFilterId=' + f.to_s }
      got = HTTParty.get url, { basic_auth: @auth }
      json = JSON.parse got.response.body if got.response.is_a?(Net::HTTPSuccess) or
        raise Net::HTTPError.new "#{got.response.code} #{got.response.message}", got.response
    end

    def get(swimlane, filters, date_since, date_until)
    
      data = get_raw swimlane, filters, date_since, date_until
      value = {
    
        count: 0,
    
        min_lead_time: 0,
        avg_lead_time: 0,
        sum_lead_time: 0,
    
        throughput: 0,
        weekly_throughput: 0,
        monthly_throughput: 0,
      }
    
      time_since = Date.parse(date_since).to_time.to_i
      time_until = Date.parse(date_until).to_time.to_i
      started = @board[:columns][:started]
      done = @board[:columns][:done]
      days = milliseconds_to_days(time_until - time_since) + 1
      
      data['issues'].each do |i|
    
        # Move backward from done, until we find a proper value.
        done_at = done - 1 - i['leaveTimes'].slice(0, done).reverse.find_index { |j| j > -1 }
      
        if (i['leaveTimes'][done_at] / 1000) > time_until || (i['leaveTimes'][done_at] / 1000)< time_since 
          # Completed after end date, skipping.
          next
        end
    
        # As long as they are good, then we will add up the cycle times to get the lead time.
        lead_time = 0
        for j in started..(done - 1)
          lead_time += i['totalTime'][j] / 1000
        end
        value[:min_lead_time] = lead_time if value[:min_lead_time] == 0 || value[:min_lead_time] > lead_time
        value[:sum_lead_time] += lead_time
        value[:count] += 1
      
      end
    
    
      value[:min_lead_time] = milliseconds_to_days value[:min_lead_time]
      value[:sum_lead_time] = milliseconds_to_days value[:sum_lead_time]
      value[:avg_lead_time] = value[:sum_lead_time] / value[:count]
    
      value[:days] = value[:avg_lead_time] * value[:count]
      value[:throughput] = value[:count] / days 
      value[:weekly_throughput] = value[:throughput] * 7
      value[:monthly_throughput] = value[:weekly_throughput] * (365.25 / 12 / 7)
    
      return value
    
    
    end

    private :get_raw

  end
  
end

