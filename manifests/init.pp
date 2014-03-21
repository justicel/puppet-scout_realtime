#Basic puppet module to install scout-realtime monitor
class scout_realtime (
  $port        = '5555',
  $log_path    = '/var/log/scout_realtime.log',
  $pid_path    = '/var/run/scout_realtime.pid',
  $use_ruby191 = false,
  $version     = '1.0.3',
) {

  if $use_ruby191 {
    exec { 'scout_realtime':
      command => 'gem1.9.1 install scout_realtime',
      unless  => "gem1.9.1 list --local | grep scout_realtime | grep ${version}",
      path    => ['/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    }
  }
  else {
    package { 'scout_realtime':
      ensure   => $version,
      provider => 'gem',
    }
  }

  file { '/etc/init/scout_realtime.conf':
    ensure  => present,
    content => template('scout_realtime/upstart.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $require_scout = $use_ruby191 ? {
    true    => Exec['scout_realtime'],
    default => Package['scout_realtime'],
  }
  service { 'scout_realtime':
    ensure  => running,
    require => $require_scout,
  }

}
