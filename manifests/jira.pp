node vagrant-ubuntu-trusty-64 {
notice("Installing gitlab")

# gitlab part

    include redis

    $dbname = 'gitlabhq_production'
    $dbuser = 'gitlab'
    $dbpwd  = 'GHodkAhliESu0q69fsaz'
    $dbrootpwd = '13rbQK9jQJHQO49IhI8b'

    class { 'ruby':
        gems_version  => 'latest'
    }

    class { '::mysql::server':
        root_password           => $dbrootpwd,
        remove_default_accounts => true,
        override_options        => $override_options,
    }

    mysql::db { $dbname:
        user     => $dbuser,
        password => $dbpwd,
        host     => 'localhost',
        grant    => ['ALL'],
    }


->

    class { 'nginx': }


    class { 'gitlab':
        git_email         => 'it@i-cv.ch',
        git_comment       => 'GitLab',
        gitlab_domain     => 'gitlab.i-cv.ch',
        gitlab_dbtype     => 'mysql',
        gitlab_dbname     => $dbname,
        gitlab_dbuser     => $dbuser,
        gitlab_dbpwd      => $dbpwd,
        ldap_enabled      => false,
    }




# jira part

notice("Installing jira")
notice("ip-jira: $::ipaddress_eth1")
notice("Host: $host")


    $dbJname = 'jira_production'
    $dbJuser = 'jiraadm'
    $dbJpwd  = 'OpBVFNm0gjkZutH2Peda2'
    
    $serverIp     = '192.168.7.131'
    $jiraHostname = 'jira.i-cv.ch'


   file { '/opt/jira':
     ensure => 'directory',
   } ->

 
  deploy::file { 'jdk-7u67-linux-x64.tar.gz':
    target  => '/opt/java',
#    url     => 'http://jira.i-cv.ch',
    url     => 'http://localhost',
    strip   => true,
    require => Class['nginx::service'],
  } ->

  #atlassian-jira-5.1.7.tar.gz
  class { 'jira':
    downloadURL => 'https://downloads.atlassian.com/software/jira/downloads',
    javahome    => '/opt/java',
    version     => '6.4.7',
    proxy       => {
      scheme    => 'http',
      proxyName => $::ipaddress_eth1,
      proxyPort => '80',
    },
    db          => 'mysql',
    dbuser      => $dbJuser,
    dbpassword  => $dbJpwd,
    dbserver    => 'localhost',
    dbname      => $dbJname,

    #    staging_or_deploy => 'deploy',
  }

#notice("ip-jira: ${::ipaddress_jira}")
#notice("Hostname: ${hostname}")
#notice("FQDN: ${fqdn}")

  nginx::resource::vhost { 'all' :
    server_name      => [ 'localhost', '127.0.0.1' ],
    www_root         => '/vagrant/files',
  }

  nginx::resource::upstream { 'jira':
    ensure  => present,
    members => [ 'localhost:8080' ],
  }

  nginx::resource::vhost { $jiraHostname :
    ensure               => present,
    server_name          => [ $::ipaddress_eth1, $jiraHostname ],
    listen_port          => '80',
#    proxy                => 'http://jira.i-cv.ch',
    proxy                => 'http://jira',
    proxy_read_timeout   => '300',
    location_cfg_prepend => {
      'proxy_set_header X-Forwarded-Host'   => '$host',
      'proxy_set_header X-Forwarded-Server' => '$host',
      'proxy_set_header X-Forwarded-For'    => '$proxy_add_x_forwarded_for',
      'proxy_set_header Host'               => '$host',
      'proxy_redirect'                      => 'off',
    },
#    www_root              => "/vagrant/files",
  }
   
#    mysql::db { $dbJname:
#       user     => $dbJuser,
#        password => $dbJpwd,
#        host     => 'localhost',
#        grant    => ['ALL'],
#    }

}
