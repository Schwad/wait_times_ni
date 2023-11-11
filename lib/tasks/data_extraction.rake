# lib/tasks/data_extraction.rake
desc 'Scrape data and update wait times'
task :scrape_data => :environment do
  DataExtractionJob.perform_now
end
