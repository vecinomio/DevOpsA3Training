class profile::jenkins {

    yumrepo { 'jenkins_repo':
      ensure   => present,
      name     => 'jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo',
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'https://jenkins-ci.org/redhat/jenkins-ci.org.key',
    }

    exec { 'yum-update':
      command => '/usr/bin/yum -y update',
      require => Yumrepo['jenkins_repo'],
    }

    package { 'jenkins':
      ensure => latest,
      require  => [Yumrepo['jenkins'],
                  Package['java-1.8.0-openjdk-devel.x86_64']],
    }

    service { 'jenkins':
      ensure => running,
    }

}
