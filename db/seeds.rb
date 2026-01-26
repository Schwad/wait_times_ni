# db/seeds.rb
# Generates realistic hospital wait time data for demo purposes

puts "🏥 Seeding Wait Times NI with realistic demo data..."

# Real NI hospitals
HOSPITALS = [
  "Royal Victoria Hospital",
  "Ulster Hospital",
  "Antrim Area Hospital",
  "Craigavon Area Hospital",
  "Altnagelvin Area Hospital",
  "Causeway Hospital",
  "Daisy Hill Hospital",
  "South West Acute Hospital",
  "Mater Hospital",
  "Lagan Valley Hospital"
]

# Create hospitals
hospitals = HOSPITALS.map do |name|
  Hospital.find_or_create_by!(name: name)
end

puts "✅ Created #{hospitals.count} hospitals"

# Base wait times vary by hospital (some are busier)
BASE_WAIT_TIMES = {
  "Royal Victoria Hospital" => 85,      # Major trauma center, busiest
  "Ulster Hospital" => 75,
  "Antrim Area Hospital" => 65,
  "Craigavon Area Hospital" => 70,
  "Altnagelvin Area Hospital" => 60,
  "Causeway Hospital" => 45,
  "Daisy Hill Hospital" => 50,
  "South West Acute Hospital" => 55,
  "Mater Hospital" => 40,
  "Lagan Valley Hospital" => 35        # Smallest, shortest waits
}

# Time patterns (multipliers)
def hour_multiplier(hour)
  case hour
  when 2..6   then 0.5   # Very quiet
  when 7..8   then 0.7   # Morning pickup
  when 9..11  then 1.0   # Normal
  when 12..14 then 1.1   # Lunch rush
  when 15..17 then 1.2   # Afternoon
  when 18..21 then 1.4   # Evening peak (accidents, after work)
  when 22..23 then 1.1   # Late night
  else 0.6               # Early morning
  end
end

def day_multiplier(wday)
  case wday
  when 0 then 1.3  # Sunday - weekend injuries
  when 1 then 1.1  # Monday - weekend backlog
  when 5 then 1.2  # Friday - party injuries start
  when 6 then 1.25 # Saturday - peak weekend
  else 1.0         # Midweek normal
  end
end

def seasonal_multiplier(month)
  case month
  when 1..2  then 1.3  # Winter flu season
  when 3     then 1.1  # Spring transition
  when 6..8  then 0.9  # Summer (slightly less)
  when 11..12 then 1.2 # Pre-Christmas + winter illness
  else 1.0
  end
end

# Generate data - last 2 years for demo (4 years would be massive)
start_date = 2.years.ago.beginning_of_day
end_date = Time.current

# For seeding, we'll create summarized daily data and a sample of raw wait times
puts "📊 Generating historical data from #{start_date.to_date} to #{end_date.to_date}..."

hospitals.each_with_index do |hospital, idx|
  base_wait = BASE_WAIT_TIMES[hospital.name] || 60
  
  current_time = start_date
  daily_readings = []
  
  while current_time < end_date
    # Generate 4 readings per hour (every 15 min) but we'll aggregate daily
    hour = current_time.hour
    wday = current_time.wday
    month = current_time.month
    
    # Calculate wait time with patterns + noise
    multiplier = hour_multiplier(hour) * day_multiplier(wday) * seasonal_multiplier(month)
    noise = rand(-15..15)
    wait_time = [(base_wait * multiplier + noise).round, 5].max
    
    daily_readings << {
      hospital_id: hospital.id,
      value: wait_time,
      created_at: current_time,
      updated_at: current_time
    }
    
    # Move forward 15 minutes
    current_time += 15.minutes
    
    # Batch insert every day's worth of data
    if daily_readings.size >= 96 # ~24 hours of readings
      WaitTime.insert_all(daily_readings)
      daily_readings = []
    end
  end
  
  # Insert remaining readings
  WaitTime.insert_all(daily_readings) if daily_readings.any?
  
  print "  ✅ #{hospital.name} (#{idx + 1}/#{hospitals.count})\n"
end

puts "\n📈 Generating aggregated statistics..."

# Generate daily stats from raw data
Hospital.find_each do |hospital|
  dates = hospital.wait_times.pluck(Arel.sql("DATE(created_at)")).uniq
  
  dates.each do |date|
    DailyStat.aggregate_for_hospital(hospital, date)
  end
  
  print "  ✅ Daily stats for #{hospital.name}\n"
end

# Generate hourly stats for recent data only (last 90 days)
recent_start = 90.days.ago.beginning_of_day
Hospital.find_each do |hospital|
  hours = hospital.wait_times
                  .where("created_at >= ?", recent_start)
                  .pluck(Arel.sql("DATE_TRUNC('hour', created_at)"))
                  .uniq
  
  hours.each do |hour|
    HourlyStat.aggregate_for_hospital(hospital, hour)
  end
  
  print "  ✅ Hourly stats for #{hospital.name}\n"
end

total_wait_times = WaitTime.count
total_daily_stats = DailyStat.count
total_hourly_stats = HourlyStat.count

puts "\n🎉 Seeding complete!"
puts "   • #{Hospital.count} hospitals"
puts "   • #{total_wait_times.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} wait time records"
puts "   • #{total_daily_stats.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} daily stats"
puts "   • #{total_hourly_stats.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} hourly stats"
