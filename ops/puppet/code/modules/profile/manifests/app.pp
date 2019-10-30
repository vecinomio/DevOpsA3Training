class profile::app {

$dirname = 'java-tomcat-v3'
$filename = "${dirname}.zip"
$install_path = "/var/lib/tomcat/webapps/ROOT/${dirname}"

    package { 'wget':
      ensure => present,
    }

    package { 'unzip':
      ensure => present,
    }

    file { $install_path:
      ensure => directory,
      owner  => 'tomcat',
      group  => 'tomcat',
      mode   => '0755',
    }

    archive { $filename:
      path          => "/tmp/${filename}",
      source        => 'https://devopsa3-simple-java-app.s3.amazonaws.com/java-tomcat-v3.zip',
#      checksum      => 'f2aaf16f5e421b97513c502c03c117fab6569076',
      checksum_type => 'sha1',
      extract       => true,
      extract_path  => '/var/lib/tomcat/webapps/ROOT',
      creates       => "${install_path}/bin",
      cleanup       => true,
      user          => 'tomcat',
      group         => 'tomcat',
      require       => File[$install_path],
    }

}
