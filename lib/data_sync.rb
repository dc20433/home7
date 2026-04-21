require 'json'

# Path to your data file
FILE_PATH = Rails.root.join('patient_data_transfer.json')

def sync_patients
  unless File.exist?(FILE_PATH)
    puts "Error: #{FILE_PATH} not found. Please move the file from Home2."
    return
  end

  puts "--- Starting Patient Import ---"
  raw_data = JSON.parse(File.read(FILE_PATH))
  total_count = raw_data.count
  success_count = 0
  error_count = 0

  # Clear existing patients to prevent ID conflicts (Optional, but recommended for a clean sync)
  # Patient.delete_all 

  raw_data.each_with_index do |record, index|
    # We use .new(record) because your database columns now match the JSON keys exactly
    patient = Patient.new(record)

    # Use validate: false to bypass 'Regi must exist' or 'Chart must exist' 
    # for legacy records with missing associations.
    if patient.save(validate: false)
      success_count += 1
      print "." if (index % 10 == 0) # Progress indicator
    else
      puts "\n[!] Failed to save record #{index}: #{patient.errors.full_messages.join(', ')}"
      error_count += 1
    end
  end

  puts "\n--- Import Complete ---"
  puts "Total Records in JSON: #{total_count}"
  puts "Successfully Saved:    #{success_count}"
  puts "Errors:               #{error_count}"
  puts "Final Patient Count:  #{Patient.count}"
end

# Execute the sync
sync_patients