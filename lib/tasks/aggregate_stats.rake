# lib/tasks/aggregate_stats.rake
namespace :stats do
  desc "Aggregate all historical wait_times into daily_stats and hourly_stats"
  task aggregate_all: :environment do
    puts "Starting full aggregation..."
    
    Hospital.find_each do |hospital|
      puts "  Processing #{hospital.name}..."
      
      # Get date range from wait_times
      first_record = hospital.wait_times.order(:created_at).first
      next unless first_record
      
      start_date = first_record.created_at.to_date
      end_date = Date.current
      
      # Aggregate daily stats
      daily_count = 0
      (start_date..end_date).each do |date|
        stat = DailyStat.aggregate_for_hospital(hospital, date)
        daily_count += 1 if stat
      end
      puts "    Created #{daily_count} daily stats"
      
      # Aggregate hourly stats
      hourly_count = 0
      current_hour = first_record.created_at.beginning_of_hour
      while current_hour <= Time.current
        stat = HourlyStat.aggregate_for_hospital(hospital, current_hour)
        hourly_count += 1 if stat
        current_hour += 1.hour
      end
      puts "    Created #{hourly_count} hourly stats"
    end
    
    puts "\nAggregation complete!"
    puts "  Daily stats: #{DailyStat.count}"
    puts "  Hourly stats: #{HourlyStat.count}"
  end

  desc "Aggregate stats for a specific date range (useful for backfills)"
  task :aggregate_range, [:start_date, :end_date] => :environment do |t, args|
    start_date = Date.parse(args[:start_date])
    end_date = Date.parse(args[:end_date])
    
    puts "Aggregating from #{start_date} to #{end_date}..."
    
    Hospital.find_each do |hospital|
      puts "  Processing #{hospital.name}..."
      
      (start_date..end_date).each do |date|
        DailyStat.aggregate_for_hospital(hospital, date)
        
        # Also aggregate hourly for each day
        24.times do |hour|
          HourlyStat.aggregate_for_hospital(hospital, date.to_time + hour.hours)
        end
      end
    end
    
    puts "Done!"
  end

  desc "Aggregate stats for today only (for cron jobs)"
  task aggregate_today: :environment do
    today = Date.current
    puts "Aggregating stats for #{today}..."
    
    Hospital.find_each do |hospital|
      DailyStat.aggregate_for_hospital(hospital, today)
      
      # Aggregate all hours up to current
      (0..Time.current.hour).each do |hour|
        HourlyStat.aggregate_for_hospital(hospital, today.to_time + hour.hours)
      end
    end
    
    puts "Done! Daily: #{DailyStat.where(date: today).count}, Hourly: #{HourlyStat.where('hour >= ?', today.beginning_of_day).count}"
  end
end
