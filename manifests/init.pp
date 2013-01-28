class pbuilder ($ensure = "present",
    $runas = "jetty",
    $aptmirror = "ftp-stud.hs-esslingen.de",
    $cachedir = "/work/tmp/pbuilder",
    $conffile = "/etc/pbuilderrc") {
    package {
        ["pbuilder", "ccache", "cowbuilder", "devscripts"] :
            ensure => $ensure,
    }
    File {
        require => Package["pbuilder"],
        ensure => $ensure,
        owner => "jetty",
    }
    $ensure_dir = $ensure ? {
        "present" => directory,
        default => $ensure,
    }
    file {
        "${cachedir}" :
            ensure => $ensure_dir,
    }
    file {
        "${cachedir}/debian" :
            ensure => $ensure_dir,
            require => File["${cachedir}"],
    }
    file {
        "${conffile}" :
            content => template("pbuilder/pbuilderrc.erb"),
    }
    $runner = "${cachedir}/run_pbuilder.sh"
    file {
        "${runner}" :
            source => "puppet:///modules/pbuilder/run_pbuilder.sh",
            mode => 4755,
            owner => "root",
            group => "root",
    }
    file {
        "/var/cache/pbuilder" :
            ensure => "absent",
            force => true,
            backup => false,
    }
    sudoers {
        "pbuilder::sudoers-${runas}" :
            hosts => "ALL",
            users => "${runas}",
            commands => "(root) NOPASSWD: ${runner} *",
            ensure => $ensure,
    }
    Pbuilder::Chrootenv {
        ensure => $ensure,
        require => [Package["pbuilder"], File["${conffile}"]],
    }
    pbuilder::chrootenv {
        "ubuntu-lucid-i386" :
            arch => "i386",
            dist => "lucid" ;

        "ubuntu-lucid-amd64" :
            arch => "amd64",
            dist => "lucid" ;

        "debian-squeeze-i386" :
            arch => "i386",
            dist => "squeeze" ;

        "debian-squeeze-amd64" :
            arch => "amd64",
            dist => "squeeze" ;

        "ubuntu-maverick-i386" :
            arch => "i386",
            dist => "maverick" ;

        "ubuntu-maverick-amd64" :
            arch => "amd64",
            dist => "maverick" ;

        "ubuntu-natty-i386" :
            arch => "i386",
            dist => "natty" ;

        "ubuntu-natty-amd64" :
            arch => "amd64",
            dist => "natty" ;

        "debian-lenny-i386" :
            arch => "i386",
            dist => "lenny" ;

        "debian-lenny-amd64" :
            arch => "amd64",
            dist => "lenny" ;
    }
    define chrootenv ($ensure = "present",
        $arch = $architecture,
        $dist = $lsbdistid) {
        tag("pbuilder") if $ensure == "present" {
            notify {
                "chrootenv::${arch}::${dist}::${ensure}" :
            }
            exec {
                "chrootenv::${ensure}::${arch}::${dist}" :
                    command => "/usr/sbin/pbuilder --create",
                    environment => ["ARCH=${arch}", "DIST=${dist}"],
                    logoutput => true,
                    unless =>
                    "test -e ${cachedir}/debian/.${dist}-${arch}.setup",
                    require => [File["${conffile}"]],
                    timeout => 7200,
            }
            exec {
                "chrootenv::${arch}::${dist}::update_monthly" :
                    command =>
                    "ARCH=${arch} DIST=${dist} /usr/sbin/pbuilder --update",
                    schedule => "monthly",
                    timeout => 7200,
            }
            file {
                "${cachedir}/debian/.${dist}-${arch}.setup" :
                    require => Exec["chrootenv::${ensure}::${arch}::${dist}"],
                    ensure => $ensure,
            }
        }
        else {
            file {
                ["${cachedir}/debian/${dist}-${arch}",
                "${cachedir}/debian/.${dist}-${arch}.setup"] :
                    recurse => true,
                    force => true,
                    backup => false,
                    ensure => $ensure,
            }
        }
    }
}


