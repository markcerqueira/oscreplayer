require 'rubygems'
require 'osc-ruby'
require 'yaml'

address = ARGV[0]
port = ARGV[1]
wait = ARGV[2] # wait boolean toggles whether the padded time at the beginning of recorded yml osc action is used
m_time = 0
start_time = 0

@client = OSC::Client.new( address, port )

@messages = YAML.load($stdin)

@start = Time.now

@messages.each_with_index do |m, index|
  if index == 0
    start_time = m[:time]
  end

  if wait=='true' or wait=='1'
    m_time = m[:time]
  else
    m_time = m[:time] - start_time
  end

  dt = (@start + m_time) - Time.now
  # dt = (@start + m[:time]) - Time.now

  # sleep if necessary
  puts "sleeping #{dt}" if dt > 0
  sleep(dt) if dt > 0
  
  message = OSC::OSCPacket.messages_from_network(m[:message]).first
  p message
  begin
    @client.send(message)
  rescue
    puts "Error sending message!"
  end
  
  puts ''
end
