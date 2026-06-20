# /home/jz/rails/home7/db_setup.rb
ActiveRecord::Base.connection.schema_cache.clear!
User.reset_column_information

manager_data = [
  { email: "bzhang@hotmail.com", password: "bz123876", role: "manager" },
  { email: "czhang@hotmail.com", password: "cz123876", role: "manager" },
  { email: "manager@example.com", password: "pw!!!23456", role: "manager" }
]

manager_data.each do |data|
  next if data[:email].blank?
  user = User.find_or_initialize_by(email: data[:email].downcase)
  user.update!(password: data[:password], role: data[:role], is_active: true)
end

admin = User.find_by("lower(email) = ?", "jz2043@yahoo.com")
if admin
  admin.update!(password: "11Danielz@", role: "admin")
end