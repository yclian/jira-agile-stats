$:.unshift(File.dirname(__FILE__) + '/lib')

require 'stats'

config_path = ENV['CONFIG'] || File.join(File.dirname(File.expand_path(__FILE__)), 'config.rb')

$config = eval(File.open(config_path).read)
$date_since = ENV['DATE_SINCE'] || (Date.today - 1).strftime('%Y-%m-%d')
$date_until   = ENV['DATE_UNTIL'] || Date.today.strftime('%Y-%m-%d')

d = JiraAgileStats::Basic.new $config

puts d.get 'defects_open', $date_since, $date_until

