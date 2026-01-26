# lib/tasks/aggregate_stats.rake
namespace :stats do
  desc "Aggregate all historical wait_times into daily_stats (bulk SQL)"
  task aggregate_all: :environment do
    puts "Starting bulk aggregation..."
    
    # Bulk insert daily stats using SQL aggregation
    puts "  Aggregating daily stats..."
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO daily_stats (hospital_id, date, min_wait, max_wait, avg_wait, sample_count, created_at, updated_at)
      SELECT 
        hospital_id,
        DATE(created_at) as date,
        MIN(value) as min_wait,
        MAX(value) as max_wait,
        AVG(value) as avg_wait,
        COUNT(*) as sample_count,
        NOW() as created_at,
        NOW() as updated_at
      FROM wait_times
      GROUP BY hospital_id, DATE(created_at)
      ON CONFLICT (hospital_id, date) 
      DO UPDATE SET
        min_wait = EXCLUDED.min_wait,
        max_wait = EXCLUDED.max_wait,
        avg_wait = EXCLUDED.avg_wait,
        sample_count = EXCLUDED.sample_count,
        updated_at = NOW()
    SQL
    puts "    Daily stats: #{DailyStat.count}"
    
    # Bulk insert hourly stats using SQL aggregation
    puts "  Aggregating hourly stats..."
    # Using interpolation to avoid quoting issues with 'hour' in DATE_TRUNC
    ActiveRecord::Base.connection.execute(%{
      INSERT INTO hourly_stats (hospital_id, hour, min_wait, max_wait, avg_wait, sample_count, created_at, updated_at)
      SELECT 
        hospital_id,
        DATE_TRUNC('hour', created_at) as hour,
        MIN(value) as min_wait,
        MAX(value) as max_wait,
        AVG(value) as avg_wait,
        COUNT(*) as sample_count,
        NOW() as created_at,
        NOW() as updated_at
      FROM wait_times
      GROUP BY hospital_id, DATE_TRUNC('hour', created_at)
      ON CONFLICT (hospital_id, hour) 
      DO UPDATE SET
        min_wait = EXCLUDED.min_wait,
        max_wait = EXCLUDED.max_wait,
        avg_wait = EXCLUDED.avg_wait,
        sample_count = EXCLUDED.sample_count,
        updated_at = NOW()
    })
    puts "    Hourly stats: #{HourlyStat.count}"
    
    puts "\nAggregation complete!"
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
