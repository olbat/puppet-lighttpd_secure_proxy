# = Class: lighttpd_secure_proxy
# 
# This class installs/configures the lighttpd web server to create secured proxies to your local web services.
# 
# == Parameters: 
#
# $servername:: The domain name related to this server, optional.
# $certificate:: The ssl certificate used to encrypt data (no ssl if not specified), usually a concatenation of a key and cert file (have to be in PEM format).
# $intermediate_ca:: Certificate(s) of intermediate certification authority(ies); more than one certificate can be concatenated in a single file (optional, have to be in PEM format).
# $port:: The port the server have to listen on. Defaults to 443.
# $exports:: An array describing the resources to be exported through the proxy for a specific service. Defaults to []. Each elements have to be a hash with the keys: +path_regexp+, the regexp that represents the path of this service on the web server; +address+, the address of the service to be proxied; +port+, the port the service is listening on; +htpasswd_file+ the htpasswd file containing the users passwords for this service (no password if the field is not precised); +trusted_net+ the address (CIDR) of a tructed network, no password will be asked when accessing the service from this network. The +htpasswd_file+ file should be created with lighttpd_secure_proxy::htpasswd_file. Only the filename should be precised.
#
# == Requires: 
# 
# lighttpd_secure_proxy::htpasswd_file
# 
# == Sample Usage:
#
#  class {'lighttpd_secure_proxy':
#    servername => 'www.domain.tld',
#    certificate => 'puppet:///modules/lighttpd_secure_proxy/www.domain.tld.pem',
#    intermediate_ca => 'puppet:///modules/lighttpd_secure_proxy/ca-inter.pem',
#    exports => [
#      {
#        'path_regexp' => '^/bittorrent',
#        'address' => '127.0.0.1',
#        'port' => 9091,
#        'htpasswd_file' => 'bt.passwd',
#        'trusted_net' => '192.168.0.0/24',
#      },
#    ]
#  }
#
class lighttpd_secure_proxy (
  $servername = undef,
  $certificate,
  $intermediate_ca = undef,
  $port = 443,
  $exports = [],
) {
  $config_path = "/etc/lighttpd"
  $htpasswd_path = $config_path

  package { 'lighttpd':
    ensure => installed,
  }

  if $certificate {
    if $servername == undef {
      $certfile = "${config_path}/lighttpd.pem"
    }
    else
    {
      $certfile = "${config_path}/${servername}.pem"
    }
    file { $certfile:
      ensure => file,
      require => Package['lighttpd'],
      owner => root,
      group => root,
      mode => 640,
      before => File['lighttpd.conf'],
      source => $certificate,
    }
    if $intermediate_ca {
      $cafile = "${config_path}/intermediate_ca.pem"
      file { $cafile:
        ensure => file,
        require => Package['lighttpd'],
        owner => root,
        group => root,
        mode => 644,
        before => File['lighttpd.conf'],
        source => $intermediate_ca,
      }
    }
  }
  else
  {
    $certfile = undef
  }

  file { 'lighttpd.conf':
    path => "${config_path}/lighttpd.conf",
    ensure => file,
    owner => root,
    group => root,
    mode => 644,
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
