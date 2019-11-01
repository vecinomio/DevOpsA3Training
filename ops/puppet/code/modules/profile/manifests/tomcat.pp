class profile::tomcat {

    func::ami_extras { 'tomcat8.5':
      ensure => present,
    }

    service { 'tomcat':
      ensure => running,
      require => Exec['amazon-linux-extras install -y tomcat8.5'],
    }

}
