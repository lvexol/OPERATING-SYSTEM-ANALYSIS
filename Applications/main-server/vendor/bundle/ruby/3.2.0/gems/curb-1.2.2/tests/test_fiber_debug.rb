require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require 'async'

class TestFiberDebug < Test::Unit::TestCase
  include TestServerMethods
  
  def setup
    server_setup
  end
  
  def test_simple_fiber_request
    puts "\n=== Starting simple fiber request test ==="
    
    run_async do |task|
      puts "Inside Async block"
      puts "Fiber scheduler available: #{Curl::Multi.fiber_scheduler_available?}"
      
      multi = Curl::Multi.new
      easy = Curl::Easy.new(TestServlet.url)
      easy.on_complete { |curl| puts "Request completed: #{curl.response_code}" }
      
      multi.add(easy)
      puts "Added easy handle to multi"
      
      # Perform without block first
      puts "Calling perform..."
      multi.perform
      puts "Perform completed"
    end
    
    puts "Test completed"
  end
  
  def test_fiber_with_block
    puts "\n=== Starting fiber with block test ==="
    
    run_async do |task|
      puts "Inside Async block"
      
      multi = Curl::Multi.new
      easy = Curl::Easy.new(TestServlet.url_to("/slow?seconds=0.1"))
      easy.on_complete { |curl| puts "Request completed: #{curl.response_code}" }
      
      multi.add(easy)
      
      block_calls = 0
      multi.perform do
        block_calls += 1
        puts "Block called: #{block_calls}"
        if block_calls < 5  # Limit iterations to prevent infinite loop
          Async::Task.yield
        end
      end
      
      puts "Perform completed, block called #{block_calls} times"
    end
    
    puts "Test completed"
  end

  private
  def run_async(&block)
    if defined?(Async) && Async.respond_to?(:run)
      Async.run(&block)
    else
      Async(&block)
    end
  end
end
