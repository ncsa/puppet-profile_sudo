# @summary Set default sudo config and allowed users/groups
#
# Set default sudo config and allowed users/groups
#
# @param configs
#   See: https://forge.puppet.com/saz/sudo
#   Default: (see data-in-module)
#
# @param users
#   Hash where key is username and value is "content"
#   where content is a string appropriate for sudo::conf.
#   If value is not present, it will default to
#
#   `ALL=(ALL) NOPASSWD: ALL`
#
#   This is the most common use case.
#
#   Example:
#   ```
#   profile_sudo::users:
#     userone:
#     usertwo: "beta.database_server.com=(cat) /usr/bin/command1"
#   ```
#   This would result in the following:
#   ```
#     userone ALL=(ALL) NOPASSWD: ALL
#     usetwo beta.database_server.com=(cat) /usr/bin/command1
#   ```
#   
#   Default: (empty list)
#
#   See also: https://forge.puppet.com/saz/sudo
#
# @param groups
#   Same as `users` (above) but where hash key is a groupname.
#
# @example
#   include profile_sudo
class profile_sudo  (
  Hash $configs,
  Hash $users,
  Hash $groups,
) {

  class { 'sudo' :
    config_file_replace => true,
    purge               => true,
    configs             => $configs,
    content             => 'profile_sudo/sudoers.erb',
  }

  # ALLOW GROUPS
  $groups.each |String $group, String $value| {
    $snippet = $value ? {
      String[1] => $value,
      default   => 'ALL=(ALL) NOPASSWD: ALL',
    }
    sudo::conf { "sudo for group ${group}":
      content  => "%${group} ${snippet}",
    }
    pam_access::entry { "Allow sudo for group ${group}":
      group      => $group,
      origin     => 'LOCAL',
      permission => '+',
      position   => '-1',
    }
  }

  # ALLOW USERS
  $users.each |String $user, String $value| {
    $snippet = $value ? {
      String[1] => $value,
      default   => 'ALL=(ALL) NOPASSWD: ALL',
    }
    sudo::conf { "sudo for user ${user}":
      content  => "%${user} ${snippet}",
    }
    pam_access::entry { "Allow sudo for user ${user}":
      user       => $user,
      origin     => 'LOCAL',
      permission => '+',
      position   => '-1',
    }
  }

}
