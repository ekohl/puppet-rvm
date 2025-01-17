# Install RVM, create system user a install system level rubies
class rvm (
  $version=undef,
  $install_from=undef,
  $install_rvm=true,
  $install_dependencies=false,
  $manage_rvmrc=$rvm::params::manage_rvmrc,
  $system_users=[],
  $system_rubies= {},
  $rvm_gems= {},
  $proxy_url=$rvm::params::proxy_url,
  $no_proxy=$rvm::params::no_proxy,
  $gnupg_key_id=$rvm::params::gnupg_key_id,
) inherits rvm::params {
  if $install_rvm {
    # rvm has now autolibs enabled by default so let it manage the dependencies
    if $install_dependencies {
      class { 'rvm::dependencies':
        before => Class['rvm::system'],
      }
    }

    if $manage_rvmrc {
      ensure_resource('class', 'rvm::rvmrc')
    }

    class { 'rvm::system':
      version      => $version,
      proxy_url    => $proxy_url,
      no_proxy     => $no_proxy,
      gnupg_key_id => $gnupg_key_id,
      install_from => $install_from,
    }
  }

  rvm::system_user { $system_users: }
  create_resources('rvm_system_ruby', $system_rubies, { 'ensure' => present, 'proxy_url' => $proxy_url, 'no_proxy' => $no_proxy })
  if $rvm_gems != {} {
    validate_hash($rvm_gems)
    create_resources('rvm_gem', $rvm_gems )
  }
}
