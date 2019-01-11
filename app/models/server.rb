class Server < ApplicationRecord
  validates :name, :cpu_cores, :ram_mb, :storage_mb, :mac_address, :fqdn, presence: true
  validates :ipv4_address, presence: { unless: :ipv6_address? }
  validates :ipv6_address, presence: { unless: :ipv4_address? }
  serialize :installed_software, Array

  validates :cpu_cores, numericality: { greater_than: 0 }
  validates :ram_mb, numericality: { greater_than: 0 }
  validates :storage_mb, numericality: { greater_than: 0 }
  
  validates :ipv4_address, format: { 
  	with: /(^$)|((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/,
	message: "Not a valid IPv4 address" 
	}
  validates :ipv6_address, format: { 
  	with: /(^$)|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/,
	message: "Not a valid IPv6 address" 
	}
  validates :mac_address, format: { 
  	with: /([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/,
	message: "Not a valid MAC address" 
	}

end
