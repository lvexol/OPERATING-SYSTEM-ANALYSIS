require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestBasic < Test::Unit::TestCase
  include TestServerMethods
  
  def setup
    server_setup
  end
  
  def test_basic_request
    puts "\n=== Testing basic request ==="
    easy = Curl::Easy.new(TestServlet.url)
    easy.perform
    puts "Response code: #{easy.response_code}"
    puts "Body (first 100 chars): #{easy.body_str[0..100]}"
    assert_equal 200, easy.response_code
  end
  
  def test_slow_request
    puts "\n=== Testing slow request ==="
    url = TestServlet.url_to("/slow?seconds=0.1")
    puts "URL: #{url}"
    easy = Curl::Easy.new(url)
    easy.perform
    puts "Response code: #{easy.response_code}"
    puts "Body: #{easy.body_str}"
    assert_equal 200, easy.response_code
  end
end