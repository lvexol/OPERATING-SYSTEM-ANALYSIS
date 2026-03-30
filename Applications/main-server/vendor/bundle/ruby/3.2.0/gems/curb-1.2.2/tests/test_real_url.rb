require File.expand_path(File.join(File.dirname(__FILE__), '../lib/curb'))
require 'async'

puts "Testing fiber scheduler with real URLs..."

# Test without fiber scheduler
puts "\n1. Without fiber scheduler:"
start = Time.now
multi = Curl::Multi.new

easies = []
3.times do |i|
  easy = Curl::Easy.new("https://httpbin.org/delay/1")
  easy.on_complete { |curl| puts "Request #{i} completed: #{curl.response_code}" }
  multi.add(easy)
  easies << easy
end

multi.perform
elapsed = Time.now - start
puts "Total time: #{elapsed.round(2)}s"

# Test with fiber scheduler
puts "\n2. With fiber scheduler:"
if Async.respond_to?(:run)
  Async.run do
    puts "Fiber scheduler available: #{Curl::Multi.fiber_scheduler_available?}"
    
    start = Time.now
    multi = Curl::Multi.new
    
    easies = []
    3.times do |i|
      easy = Curl::Easy.new("https://httpbin.org/delay/1")
      easy.on_complete { |curl| puts "Request #{i} completed: #{curl.response_code}" }
      multi.add(easy)
      easies << easy
    end
    
    multi.perform
    elapsed = Time.now - start
    puts "Total time: #{elapsed.round(2)}s"
  end
else
  Async do
    puts "Fiber scheduler available: #{Curl::Multi.fiber_scheduler_available?}"
    
    start = Time.now
    multi = Curl::Multi.new
    
    easies = []
    3.times do |i|
      easy = Curl::Easy.new("https://httpbin.org/delay/1")
      easy.on_complete { |curl| puts "Request #{i} completed: #{curl.response_code}" }
      multi.add(easy)
      easies << easy
    end
    
    multi.perform
    elapsed = Time.now - start
    puts "Total time: #{elapsed.round(2)}s"
  end
end

puts "\nDone!"
