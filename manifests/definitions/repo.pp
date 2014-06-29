# Module:: oar
# Manifest:: definitions/repo.pp
#

# Define:: oar::configure_repo
# Args:: $version
#
define oar::configure_repo($version, $snapshots) {

  case $operatingsystem {
    debian,ubuntu: {
      file {
        "/etc/apt/sources.list.d/oar.list":
          ensure  => file,
          mode    => 644, owner => root, group => root,
          content => $snapshots ? {
            true => template("oar/repos/debian/oar-snapshots.list.erb"),
            false => template("oar/repos/debian/oar.list.erb"),
          },
          notify  => Exec["OAR APT sources update"],
          require => Exec["Add APT key"];
      }

      exec {
        "OAR APT sources update":
          path        => "/usr/bin:/usr/sbin:/bin",
          command     => "apt-get update",
          refreshonly => true;
        "Add APT key":
          path        => "/usr/bin:/usr/sbin:/bin",
          command     => "wget http://oar-ftp.imag.fr/oar/oarmaster.asc && sudo apt-key add /tmp/oarmaster.asc",
          unless      => "apt-key list | grep oar",
          cwd         => "/tmp",
          notify      => Exec["OAR APT sources update"];
      }
    }
    CentOS:{
      file {
        "/etc/yum.repos.d/oar.repo":
          ensure  => file,
          mode    => 644, owner => root, group => root,
          content => template("oar/repos/centos/oar.repo.erb"),
          notify  => Exec["OAR YUM makecache"];
      }

      exec {
        "OAR YUM makecache":
          path        => "/usr/bin:/usr/sbin:/bin",
          command     => "yum makecache",
          refreshonly => true;
      }
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Define: oar::configure_repo

