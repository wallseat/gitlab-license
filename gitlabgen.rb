require 'openssl'
require 'gitlab/license'

# Generate a key pair. You should do this only once.
key_pair = OpenSSL::PKey::RSA.generate(2048)

# Write it to a file to ship along with the main application.
File.open("/opt/gitlab/embedded/service/gitlab-rails/.license_encryption_key.pub", "w") { 
  |f| f.write(key_pair.public_key.to_pem) 
}

Gitlab::License.encryption_key =  OpenSSL::PKey::RSA.new key_pair.to_pem

# Build a new license.
license = Gitlab::License.new
license.licensee = {
  "Name"    => ENV['GITLAB_LICENSE_NAME'],
  "Company" => ENV['GITLAB_LICENSE_COMPANY'],
  "Email"   => ENV['GITLAB_LICENSE_EMAIL']
}
license.starts_at = Date.today

license.restrictions = {
  :plan => "ultimate", 
  :id   => rand(1000..99999999)
}

# Export the license, which encrypts and encodes it.
data = license.export

puts "Exported license to file '#{company}.gitlab-license'"
File.open("#{company}.gitlab-license", 'w') { |file| file.write(data) }