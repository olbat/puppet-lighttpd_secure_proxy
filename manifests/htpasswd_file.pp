# = lighttpd_secure_proxy::htpasswd_file
# 
# Copy htpasswd files in the lighttpd install directory.
# 
# == Parameters: 
#
# $srcfile:: the file that have to be copied
# $destfile:: the filename of the file in the destination directory (the lighttpd configuration path)
#
# == Requires: 
# 
# Nothing.
# 
# == Sample Usage:
#
#  lighttpd_secure_proxy::htpasswd_file{'bt.passwd':
#    srcfile => 'puppet:///modules/lighttpd_secure_proxy/bt.passwd',
#    destfile => 'bt.passwd',
#  }
#
define lighttpd_secure_proxy::htpasswd_file($srcfile,$destfile) {
  include lighttpd_secure_proxy

  file { $destfile:
    path => "${lighttpd_secure_proxy::htpasswd_path}/${destfile}",
    ensure => file,
    require => Package['lighttpd'],
    source => $srcfile,
  }
}
