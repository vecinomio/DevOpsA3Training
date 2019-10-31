class profile::java {

  package { 'java-1.8.0-openjdk-devel.x86_64':
    ensure  => installed,
  }

}
