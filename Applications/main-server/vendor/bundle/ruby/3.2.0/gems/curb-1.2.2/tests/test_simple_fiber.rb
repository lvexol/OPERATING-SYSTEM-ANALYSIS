require File.expand_path(File.join(File.dirname(__FILE__), '../lib/curb'))
require 'async'

puts "Testing simple fiber scheduler..."

if Async.respond_to?(:run)
  Async.run do
    puts "Fiber scheduler available: #{Curl::Multi.fiber_scheduler_available?}"
    
    multi = Curl::Multi.new
    easy = Curl::Easy.new("https://httpbin.org/delay/1")
    easy.on_complete { |curl| puts "Request completed: #{curl.response_code}" }
    
    multi.add(easy)
    puts "Starting perform..."
    multi.perform
    puts "Perform completed"
  end
else
  Async do
    puts "Fiber scheduler available: #{Curl::Multi.fiber_scheduler_available?}"
    
    multi = Curl::Multi.new
    easy = Curl::Easy.new("https://httpbin.org/delay/1")
    easy.on_complete { |curl| puts "Request completed: #{curl.response_code}" }
    
    multi.add(easy)
    puts "Starting perform..."
    multi.perform
    puts "Perform completed"
  end
end

puts "Done!"
