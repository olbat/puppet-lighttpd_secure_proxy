define lighttpd_secure_proxy::htpasswd_file($srcfile,$destfile) {
  include lighttpd_secure_proxy

  file { $destfile:
    path => "${lighttpd_secure_proxy::htpasswd_path}/${destfile}",
    ensure => file,
    require => Package['lighttpd'],
    source => $srcfile,
  }
}
