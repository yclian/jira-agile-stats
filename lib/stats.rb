require 'httparty'

module JiraAgileStats
  
  autoload :Performance, 'stats/performance'

  module Utils

    def milliseconds_to_days(i)
      i / (60 * 60 * 24.0)
    end
  
  end

end
