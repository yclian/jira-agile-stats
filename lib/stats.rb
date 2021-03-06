require 'httparty'

module JiraAgileStats
  
  autoload :Basic, 'stats/basic'
  autoload :Performance, 'stats/performance'
  autoload :Scope, 'stats/scope'

  module Utils

    def milliseconds_to_days(i)
      i / (60 * 60 * 24.0)
    end
  
  end

end
