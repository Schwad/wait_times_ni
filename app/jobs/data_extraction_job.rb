# app/jobs/data_extraction_job.rb
class DataExtractionJob < ApplicationJob
  queue_as :default

  # Rotate user agents to avoid bot detection
  USER_AGENTS = [
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0'
  ].freeze

  # Random sampling rate: 1 in 3 chance to actually fetch (33%)
  # Makes scraping pattern look more organic, reduces server load
  SAMPLE_RATE = 3

  def perform
    # Random downsampling - only proceed 1 in SAMPLE_RATE times
    unless rand(SAMPLE_RATE) == 0
      Rails.logger.info "DataExtractionJob: Skipped (random downsample)"
      return
    end

    require 'mechanize'
    require 'nokogiri'

    # Use Cloudflare Worker proxy to avoid IP blocking
    # The worker fetches from different edge IPs each time
    url = 'https://ni-waittimes-proxy.schwad.workers.dev'
    agent = Mechanize.new
    
    # Set realistic browser headers to avoid 403
    agent.user_agent = USER_AGENTS.sample
    agent.request_headers = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language' => 'en-GB,en;q=0.9',
      'Accept-Encoding' => 'gzip, deflate, br',
      'Connection' => 'keep-alive',
      'Upgrade-Insecure-Requests' => '1',
      'Cache-Control' => 'max-age=0'
    }
    
    # Optional proxy support via ENV
    # Set PROXY_URL=http://user:pass@proxy.example.com:8080
    if ENV['PROXY_URL'].present?
      proxy = URI.parse(ENV['PROXY_URL'])
      agent.set_proxy(proxy.host, proxy.port, proxy.user, proxy.password)
      Rails.logger.info "Using proxy: #{proxy.host}:#{proxy.port}"
    end
    
    page = agent.get(url)

    # Find the table with the specified ID
    table = page.at('#emergency-department-average-waiting-times')

    # Initialize an array to store the extracted data
    data_array = []

    # Iterate through each row in the table
    table.search('tr')[1..-1].each do |row|
      wait_time = row.children[-2].text.split(" ")[0].to_i
      next if wait_time == 0 # It's not an integer, text casts to 0
      data_array << [row.children[1].text, wait_time]
    end

    data_array.each do |data|
      hospital_name = data[0]
      wait_time_value = data[1].to_i

      # Use the mapper to normalize hospital names and consolidate variants
      hospital = HospitalNameMapper.find_or_create_hospital(hospital_name)
      hospital.wait_times.create(value: wait_time_value)
    end

    # Aggregate stats for current hour and today
    aggregate_current_stats

    # Refresh the view cache
    url = URI.parse('https://12qwd.hatchboxapp.com/')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true if url.scheme == 'https'

    # Create a GET request
    request = Net::HTTP::Get.new(url.path)

    # Send the request
    response = http.request(request)

    # Check the response code
    if response.code.to_i == 200
      puts "Successfully pinged the URL."
    else
      puts "Failed to ping the URL. Response code: #{response.code}"
    end

  end

  private

  def aggregate_current_stats
    today = Date.current
    current_hour = Time.current.beginning_of_hour

    Hospital.find_each do |hospital|
      # Update daily aggregation for today
      DailyStat.aggregate_for_hospital(hospital, today)
      
      # Update hourly aggregation for current hour
      HourlyStat.aggregate_for_hospital(hospital, current_hour)
    end
  end
end
