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

    file { ['/var/lib/tomcat/webapps/ROOT/',
            $install_path]:
      ensure => directory,
      recurse => true,
      owner  => 'root',
      group  => 'tomcat',
      mode   => '0775',
    }

    archive { $filename:
      path          => "/tmp/${filename}",
      source        => 'https://devopsa3-simple-java-app.s3.amazonaws.com/java-tomcat-v3.zip',
      extract       => true,
      extract_path  => '/var/lib/tomcat/webapps/ROOT',
      creates       => "${install_path}/bin",
      cleanup       => true,
      user          => 'tomcat',
      group         => 'tomcat',
      require       => File["$install_path"],
    }

}
