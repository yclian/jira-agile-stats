$:.unshift(File.dirname(__FILE__) + '/lib')

require 'stats'

config_path = ENV['CONFIG'] || File.join(File.dirname(File.expand_path(__FILE__)), 'config.rb')

$config = eval(File.open(config_path).read)
$date_since = ENV['DATE_SINCE'] || (Date.today - 1).strftime('%Y-%m-%d')
$date_until   = ENV['DATE_UNTIL'] || Date.today.strftime('%Y-%m-%d')

p = JiraAgileStats::Performance.new $config, 51

stories = p.get 61, [], $date_since, $date_until
stories_not_free = p.get 61, [249], $date_since, $date_until
stories_free = p.get 61, [366], $date_since, $date_until

puts stories
puts stories_not_free
puts stories_free

