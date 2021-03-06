node 'vagrant-ubuntu-trusty-64' {

    notice("Hello world.")

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

}


