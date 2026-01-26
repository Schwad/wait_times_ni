# app/jobs/data_extraction_job.rb
class DataExtractionJob < ApplicationJob
  queue_as :default

  def perform
    require 'mechanize'
    require 'nokogiri'

    url = 'https://www.nidirect.gov.uk/articles/emergency-department-average-waiting-times'
    agent = Mechanize.new
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
