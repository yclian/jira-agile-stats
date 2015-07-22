module JiraAgileStats

  class Scope

    include JiraAgileStats::Utils

    def initialize(config, board)

      @auth = {
        username: config[:username],
        password: config[:password],
      }
      @url = config[:url].gsub(/\/$/, '') + '/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=' + board.to_s
      @url_for_sprints = config[:url].gsub(/\/$/, '') + "/rest/greenhopper/1.0/sprintquery/#{board.to_s}?includeHistoricSprints=false&includeFutureSprints=false"

    end

    def get(num_of_sprints)
      sprints = get_sprints_raw(num_of_sprints.to_i)
      values = get_by_sprints(sprints.map { |s| s['id'] })
      values.each_index { |i| values[i][:name] = sprints[i]['name'] }
      values
    end

    def get_by_sprint(sprint)

      data = get_by_sprint_raw sprint
      value = {
 
        id: sprint,
        name: nil,

        start_time: 0,
        end_time: 0,
        elapsed_time: 0,

        burndown_start: 0,
        burndown_start_in_hours: 0,
        burndown_end: 0,
        burnup_end: 0,
        burnup_end_in_hours: 0,
      }
      smallest_time = Time.now.to_i
      estimates = {}

      value[:start_time] = data['startTime'] / 1000
      value[:end_time] = data['endTime'] / 1000
      value[:elapsed_time] = (data['endTime'] - data['startTime']) / 1000
      value[:elapsed_time_in_hours] = (value[:elapsed_time].to_f / 60 / 60).round 3
      value[:elapsed_time_in_days] = (value[:elapsed_time_in_hours].to_f / 24).round 3

      data['changes'].each do |k,v|

        t = k.to_i / 1000
        smallest_time = t if t < smallest_time

        v.each do |w|

          time_changed = w.has_key? 'timeC'
          time_logged = (time_changed and w['timeC'].has_key? 'timeSpent')
          time_estimated = (time_changed and w['timeC'].has_key? 'newEstimate')

          # Exclude entries before Sprint
          if t >= value[:start_time] 

            # Calcualte burn-up
            if time_logged
              value[:burnup_end] += w['timeC']['timeSpent'] 
            end

          else 
            # All the estimate changes happened before the Sprint starts.
            if time_estimated
              estimates[w['key']] = [] unless estimates.has_key? w['key']
              estimates[w['key']] << w['timeC']['newEstimate']
            end
          end

        end

      end

      # We are taking the last entry of each issue, this is to ignore all outdated estimates/re-estimates.
      estimates.each do |k,v|
        value[:burndown_start] += v.last
      end

      value[:burndown_start_in_hours] = (value[:burndown_start] / 3600).to_f.round 3
      value[:burnup_end_in_hours] = (value[:burnup_end] / 3600).to_f.round 3
      
      return value
    
    end

    def get_by_sprint_raw(sprint)
      url = @url + '&sprintId=' + sprint.to_s
      got = HTTParty.get url, { basic_auth: @auth }
      json = JSON.parse got.response.body if got.response.is_a?(Net::HTTPSuccess) or
        raise Net::HTTPError.new "#{got.response.code} #{got.response.message}", got.response
    end

    def get_by_sprints(sprints)
      sprints = [sprints] unless sprints.is_a? Array
      r = []
      sprints.each { |s| r << get_by_sprint(s) }
      return r
    end

    def get_sprints_raw(num_of_sprints)
      url = @url_for_sprints
      got = HTTParty.get url, { basic_auth: @auth }
      json = JSON.parse got.response.body if got.response.is_a?(Net::HTTPSuccess) or
        raise Net::HTTPError.new "#{got.response.code} #{got.response.message}", got.response
      json['sprints'].slice -1 * num_of_sprints, num_of_sprints
    end

    private :get_by_sprint, :get_by_sprint_raw, :get_by_sprints, :get_sprints_raw

  end
  
end

