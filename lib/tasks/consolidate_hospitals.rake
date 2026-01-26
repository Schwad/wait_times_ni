# lib/tasks/consolidate_hospitals.rake
namespace :hospitals do
  desc "Consolidate duplicate hospital names into canonical versions"
  task consolidate: :environment do
    puts "Starting hospital consolidation..."
    
    # Get all current hospital names
    hospitals = Hospital.all.to_a
    consolidated_count = 0
    
    hospitals.each do |hospital|
      canonical_name = HospitalNameMapper.normalize(hospital.name)
      
      # Skip if already canonical and no duplicate exists
      next if hospital.name == canonical_name
      
      puts "  Mapping '#{hospital.name}' -> '#{canonical_name}'"
      
      # Find or create the canonical hospital
      canonical_hospital = Hospital.find_or_create_by(name: canonical_name)
      
      # If it's a different hospital record, move the wait_times
      if canonical_hospital.id != hospital.id
        # Move all wait_times to canonical hospital
        hospital.wait_times.update_all(hospital_id: canonical_hospital.id)
        
        # Move daily_stats if they exist
        if hospital.respond_to?(:daily_stats)
          hospital.daily_stats.update_all(hospital_id: canonical_hospital.id)
        end
        
        # Move hourly_stats if they exist  
        if hospital.respond_to?(:hourly_stats)
          hospital.hourly_stats.update_all(hospital_id: canonical_hospital.id)
        end
        
        # Delete the duplicate hospital
        hospital.destroy
        consolidated_count += 1
        puts "    ✓ Moved #{hospital.wait_times.count} records, deleted duplicate"
      end
    end
    
    puts "\nConsolidation complete!"
    puts "  Consolidated: #{consolidated_count} duplicate hospitals"
    puts "  Remaining: #{Hospital.count} hospitals"
    puts "\nCurrent hospitals:"
    Hospital.order(:name).pluck(:name).each { |n| puts "  - #{n}" }
  end

  desc "List all current hospital names and their canonical mappings"
  task list_mappings: :environment do
    puts "Current hospital names and their canonical mappings:\n\n"
    
    Hospital.order(:name).each do |hospital|
      canonical = HospitalNameMapper.normalize(hospital.name)
      status = hospital.name == canonical ? "✓" : "→"
      
      if hospital.name == canonical
        puts "#{status} #{hospital.name}"
      else
        puts "#{status} #{hospital.name}"
        puts "  → #{canonical}"
      end
    end
    
    puts "\n#{Hospital.count} total hospitals in database"
  end
end
