users = {
  "dc20433@gmail.com" => "11Danielz@",
  "jz2043@yahoo.com"  => "11Danielz@",
  "bzhang@hotmail.com" => "bz123876",
  "cindyxz@hotmail.com" => "cz123876"
}

users.each do |email, password|
  user = User.find_or_initialize_by(email: email)
  user.password = password
  user.role = (email.include?('jz') || email.include?('dc') ? 2 : 1)
  user.save!
end
