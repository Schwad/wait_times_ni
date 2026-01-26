# app/services/hospital_name_mapper.rb
# Maps scraped hospital names to canonical names
# NI Direct frequently changes hospital names (adds "PHONE FIRST", phone numbers, 
# changes punctuation, etc.) This mapper consolidates them.
class HospitalNameMapper
  # Canonical hospital names (the "real" names we want to use)
  CANONICAL_NAMES = [
    "Altnagelvin Area Hospital Emergency Department",
    "Antrim Area Hospital Emergency Department",
    "Causeway Area Hospital Emergency Department",
    "Craigavon Area Hospital Emergency Department",
    "Daisy Hill Hospital Emergency Department",
    "Downe Hospital Urgent Care Centre",
    "Lagan Valley Hospital Emergency Department",
    "Mater Hospital Emergency Department",
    "Mid Ulster Hospital Minor Injury Unit",
    "Royal Childrens Hospital Emergency Department",
    "Royal Victoria Hospital Emergency Department",
    "South Tyrone Hospital Minor Injury Unit",
    "South West Acute Hospital Emergency Department",
    "Ulster Hospital Emergency Department"
  ].freeze

  # Patterns to match scraped names to canonical names
  # Order matters - more specific patterns should come first
  PATTERNS = {
    # Altnagelvin
    /altnagelvin/i => "Altnagelvin Area Hospital Emergency Department",
    
    # Antrim
    /antrim\s*(area)?\s*hospital/i => "Antrim Area Hospital Emergency Department",
    
    # Causeway
    /causeway/i => "Causeway Area Hospital Emergency Department",
    
    # Craigavon
    /craigavon/i => "Craigavon Area Hospital Emergency Department",
    
    # Daisy Hill
    /daisy\s*hill/i => "Daisy Hill Hospital Emergency Department",
    
    # Downe
    /downe/i => "Downe Hospital Urgent Care Centre",
    
    # Lagan Valley
    /lagan\s*valley/i => "Lagan Valley Hospital Emergency Department",
    
    # Mater
    /mater\s*hospital/i => "Mater Hospital Emergency Department",
    
    # Mid Ulster
    /mid\s*ulster/i => "Mid Ulster Hospital Minor Injury Unit",
    
    # Royal Childrens (note: various apostrophe styles)
    /royal\s*child/i => "Royal Childrens Hospital Emergency Department",
    
    # Royal Victoria
    /royal\s*victoria/i => "Royal Victoria Hospital Emergency Department",
    
    # South Tyrone
    /south\s*tyrone/i => "South Tyrone Hospital Minor Injury Unit",
    
    # South West Acute
    /south\s*west\s*acute/i => "South West Acute Hospital Emergency Department",
    
    # Ulster
    /ulster\s*hospital/i => "Ulster Hospital Emergency Department"
  }.freeze

  class << self
    # Takes a scraped hospital name and returns the canonical name
    # @param scraped_name [String] The name as scraped from NI Direct
    # @return [String] The canonical hospital name
    def normalize(scraped_name)
      return scraped_name if scraped_name.blank?
      
      # Try to match against our patterns
      PATTERNS.each do |pattern, canonical_name|
        return canonical_name if scraped_name.match?(pattern)
      end
      
      # If no match found, log it and return the original
      # This helps us identify new hospitals or name changes we need to handle
      Rails.logger.warn "HospitalNameMapper: Unknown hospital name '#{scraped_name}'"
      scraped_name
    end

    # Find or create a hospital using the canonical name
    # @param scraped_name [String] The name as scraped from NI Direct
    # @return [Hospital] The hospital record
    def find_or_create_hospital(scraped_name)
      canonical_name = normalize(scraped_name)
      Hospital.find_or_create_by(name: canonical_name)
    end

    # Returns all canonical hospital names
    def canonical_names
      CANONICAL_NAMES
    end

    # Check if a name is already canonical
    def canonical?(name)
      CANONICAL_NAMES.include?(name)
    end
  end
end
