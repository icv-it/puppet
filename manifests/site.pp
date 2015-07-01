node 'vagrant-ubuntu-trusty-64' {
    notice("Hello world.")

#    class { 'postgresql::server':
#        listen_addresses           => 'localhost',
#    }

    $dbname = 'gugus'
    $dbuser = 'gitlab'    
    $dbpwd  = 'GHodkAhliESu0q69fsaz'

    postgresql::server::db { $dbname :
        user     => $dbuser,
        password => postgresql_password($dbuser, $dbpwd),
    }

    class { 'nginx': }



    class { 'gitlab':
        git_email         => 'it@i-cv.ch',
        git_comment       => 'GitLab',
        gitlab_domain     => 'gitlab.icv.ch',
        gitlab_dbtype     => 'pgsql',
        gitlab_dbname     => $dbname,
        gitlab_dbuser     => $dbuser,
        gitlab_dbpwd      => $dbpwd,
        ldap_enabled      => false,
    }


}
