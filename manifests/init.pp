# = Class: lighttpd_secure_proxy
# 
# This class installs/configures the lighttpd web server to create secured proxies to your local web services.
# 
# == Parameters: 
#
# $certificate:: 
# $port:: Defaults to 443.
# $exports:: An array describing the resources to be exported through the proxy for a specific service. Defaults to []. Each elements have to be a hash with the keys: +path_regexp+, the regexp that represents the path of this service on the web server; +address+, the address of the service to be proxied; +port+, the port the service is listening on; +htpasswd_file+ the htpasswd file containing the users passwords for this service. The file should be created with lighttpd_secure_proxy::htpasswd_file. Only the filename should be precised.
#
# == Requires: 
# 
# lighttpd_secure_proxy::htpasswd_file
# 
# == Sample Usage:
#
#  class {'lighttpd_secure_proxy':
#    certificate => 'puppet:///modules/lighttpd_secure_proxy/lighttpd.pem',
#    exports => [
#      {
#        'path_regexp' => '^/bittorrent',
#        'address' => '127.0.0.1',
#        'port' => 9091,
#        'htpasswd_file' => 'bt.passwd',
#      },
#    ]
#  }
#
class lighttpd_secure_proxy (
  $certificate,
  $port = 443,
  $exports = [],
) {
  $config_path = "/etc/lighttpd"
  $htpasswd_path = $config_path

  package { 'lighttpd':
    ensure => installed,
  }

  if $certificate {
    $certfile = "${config_path}/lighttpd.pem"
    file { 'lighttpd.pem':
      path => "${config_path}/lighttpd.pem",
      ensure => file,
      require => Package['lighttpd'],
      before => File['lighttpd.conf'],
      source => $certificate,
    }
  }
  else
  {
    $certfile = undef
  }

  file { 'lighttpd.conf':
    path => "${config_path}/lighttpd.conf",
    ensure => file,
    require => Package['lighttpd'],
    content => template("${module_name}/lighttpd.conf.erb")
  }

  service { 'lighttpd':
    name => 'lighttpd',
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => File['lighttpd.conf'],
  }
}
