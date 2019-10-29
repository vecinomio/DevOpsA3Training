class profile::tomcat {

    package { 'tomcat8':
      ensure  => installed,
      require  => Package['java-1.8.0-openjdk-devel.x86_64'],
    }

    service { 'tomcat8':
      ensure => running,
    }

}
