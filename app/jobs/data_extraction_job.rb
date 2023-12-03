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

      hospital = Hospital.find_or_create_by(name: hospital_name)
      hospital.wait_times.create(value: wait_time_value)
    end


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
end
