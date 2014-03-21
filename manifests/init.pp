#Basic puppet module to install scout-realtime monitor
class scout_realtime (
  $port     = '5555',
  $log_path = '/var/log/scout_realtime.log',
  $pid_path = '/var/run/scout_realtime.pid',
) {

  package { 'scout_realtime':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/init/scout_realtime.conf':
    ensure  => present,
    content => template('scout_realtime/upstart.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['scout_realtime'],
  }

  service { 'scout_realtime':
    ensure  => running,
    require => File['/etc/init/scout_realtime.conf'],
  }

}
