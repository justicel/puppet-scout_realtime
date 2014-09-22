# == Class: scout_realtime
#
# This module installs the scout realtime ruby gem. This gem allows you to have a local 'top' 
# service on your system. It generally (by default) runs on port 5555 and depends on ruby
# greater than 1.8.
#
# === Parameters
# [*ensure*]
#   Default to present. This sets the package as installed or uninstalled and affects the config as well.
#   Can be present or absent.
# [*port*]
#   The port number to run scout_realtime on. Defaults to port 5555 (default gem port number as well).
# [*log_path*]
#   Where to store log-file entries for the scout_realtime service.
# [*pid_path*]
#   Location to place the pid file for scout_realtime
# [*non_system_ruby*]
#   True/False to use a non-standard gem installation command for the scout_realtime service
# [*gem_command*]
#   Command to use for installation and version checking of the scout_realtime gem. Not used
#   unless non_system_ruby is set to true
# [*version*]
#   Version number of scout_realtime gem to install. Version is 1.0.5 as of the time of writing.
#
# === Examples
#
#  class { 'scout_realtime':
#    ensure => present,
#    port   => '5555',
#  }
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
#
# === Copyright
#
# Copyright 2014 Justice London, unless otherwise noted.
#
class scout_realtime (
  $ensure          = present,
  $port            = '5555',
  $log_path        = '/var/log/scout_realtime.log',
  $pid_path        = '/var/run/scout_realtime.pid',
  $non_system_ruby = false,
  $gem_command     = 'gem1.9.1',
  $version         = '1.0.5',
) {

  #Variable verifications
  validate_re($ensure, '^present$|^absent$')
  validate_re($port, '^[0-9]+$')
  validate_absolute_path($log_path)
  validate_absolute_path($pid_path)
  validate_bool($non_system_ruby)
  validate_string($gem_command)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')

  #Set present/absent to version or absent
  $real_version = $ensure ? {
    present => $version,
    default => 'absent',
  }
  $pres_2bool = $ensure ? {
    present => true,
    default => false,
  }

  if $non_system_ruby {
    exec { 'scout_realtime':
      command => "${gem_command} install scout_realtime",
      unless  => "${gem_command} list scout_realtime | grep ${version}",
      path    => ['/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    }
  }
  else {
    ensure_packages('scout_realtime', {
      ensure => $real_version,
      provider => 'gem',
    } )
    }
  }

  file { '/etc/init/scout_realtime.conf':
    ensure  => $ensure,
    content => template('scout_realtime/upstart.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  #Set requirements for service if using a non-system ruby version.
  $require_scout = $non_system_ruby ? {
    true    => Exec['scout_realtime'],
    default => Package['scout_realtime'],
  }

  $runstate = $ensure
  service { 'scout_realtime':
    ensure  => $pres_2bool,
    require => [ $require_scout, File['/etc/init/scout_realtime.conf'], ],
  }

}
