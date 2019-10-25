node default {

  class base {
  }

  class jenkins {
    yumrepo { 'jenkins':
      ensure   => present,
      name     => 'jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo',
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'https://jenkins-ci.org/redhat/jenkins-ci.org.key'
    }

    exec { 'yum-update':
      command => '/usr/bin/yum -y update'
      require => Yumrepo['jenkins'],
    }

    package { 'java-1.8.0-openjdk-devel.x86_64':
      ensure  => installed,
    }

    package { 'jenkins':
      ensure => latest,
      require  => [Yumrepo['jenkins'],
                  package['java-1.8.0-openjdk-devel.x86_64']],
    }

    service { 'jenkins':
      ensure => running,
    }
  }

  class java {
    package { 'java-1.8.0-openjdk-devel.x86_64':
      ensure  => installed
    }
  }

  class tomcat {
    package { 'java-1.8.0-openjdk-devel.x86_64':
      ensure  => installed
    }

    package { 'tomcat8':
      ensure  => installed,
      require  => package['java-1.8.0-openjdk-devel.x86_64']
    }
  }


}
