require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require 'async'

class TestFiberSimple < Test::Unit::TestCase
  include TestServerMethods
  
  def setup
    server_setup
  end
  
  def test_simple_concurrent
    puts "\n=== Testing simple concurrent requests ==="
    
    results = []
    
    if Async.respond_to?(:run)
      Async.run do |task|
        puts "Fiber scheduler available: #{Curl::Multi.fiber_scheduler_available?}"
        
        multi = Curl::Multi.new
        
        # Add 3 requests
        3.times do |i|
          easy = Curl::Easy.new(TestServlet.url_to("/slow?seconds=0.2&id=#{i}"))
          easy.on_complete { |curl| 
            results << { id: i, code: curl.response_code }
            puts "Request #{i} completed"
          }
          multi.add(easy)
        end
        
        puts "Starting perform..."
        start_time = Time.now
        multi.perform  # No block
        elapsed = Time.now - start_time
        puts "Perform completed in #{elapsed.round(2)}s"
      end
    else
      Async do |task|
      puts "Fiber scheduler available: #{Curl::Multi.fiber_scheduler_available?}"
      
      multi = Curl::Multi.new
      
      # Add 3 requests
      3.times do |i|
        easy = Curl::Easy.new(TestServlet.url_to("/slow?seconds=0.2&id=#{i}"))
        easy.on_complete { |curl| 
          results << { id: i, code: curl.response_code }
          puts "Request #{i} completed"
        }
        multi.add(easy)
      end
      
      puts "Starting perform..."
      start_time = Time.now
      multi.perform  # No block
      elapsed = Time.now - start_time
      puts "Perform completed in #{elapsed.round(2)}s"
      end
    end
    
    assert_equal 3, results.size
    results.each { |r| assert_equal 200, r[:code] }
  end
end
