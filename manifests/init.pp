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
