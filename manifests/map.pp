# = Define: postfix::map
#
# Adds a postfix lookup table
#
# == Parameters
#
# [*source*]
#   Sets the value of source parameter for the postfix lookup table
#
# [*template*]
#   Sets the value of content parameter for the postfix lookup table
#   Defaults to 'postfix/map.erb' if $maps is set.
#   Note: This option is alternative to the source one
#
# [*maps*]
#   Sets the value of content parameter for the postfix lookup table
#   Possible values are hashes, arrays, or arrays of arrays (see Usage).
#   Note: This option is alternative to the source one
#
# [*path*]
#   Where to create the file.
#   Defaults to "${postfix::config_dir}/${name}".
#
# [*mode*]
#   The file permissions of the file.
#   Defaults to $postfix::config_file_mode
#
# [*type*]
#   The type of the created map. Use to decide between reloading postfix
#   or just make a postmap
#
# == Usage:
# postfix::map { 'canonical':
#   source => 'puppet:///modules/example42/postfix/canonical'
# }
#
# postfix::map { 'transport':
#   template => 'example42/postfix/transport.erb'
# }
#
# postfix::map { 'virtual':
#   maps => {
#     'user1@virtual-alias.example.org' => 'address1',
#     'user2@virtual-alias.example.org' => ['address2', 'address3'],
#   }
# }
#
# Use arrays when order is important
#
# postfix::map { 'access':
#   maps => [
#     ['user1@example.org', 'OK'],
#     ['example.org', 'REJECT'],
#   ]
# }
#
define postfix::map (
  $source   = params_lookup( 'source' ),
  $template = params_lookup( 'template' ),
  $maps     = params_lookup( 'maps' ),
  $path     = "${postfix::config_dir}/${name}",
  $mode     = $postfix::config_file_mode,
  $type     = 'hash',
) {
  include postfix
  include postfix::reload

  $manage_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }

  $manage_file_content = $template ? {
    ''        => $maps ? {
      ''      => undef,
      default => template('postfix/map.erb'),
      },
    default   => template($template),
  }

  # CIDR and PCRE maps need a postfix reload, but not
  # a postmap.
  $manage_notify = empty(grep(['cidr', 'pcre'], $type)) ? {
    true    => Exec["postmap-${name}"],
    default => Class['::postfix::reload'],
  }

  file { "postfix::map_${name}":
    ensure  => present,
    path    => $path,
    mode    => $mode,
    owner   => $postfix::config_file_owner,
    group   => $postfix::config_file_group,
    require => Package['postfix'],
    source  => $manage_file_source,
    content => $manage_file_content,
    replace => $postfix::manage_file_replace,
    audit   => $postfix::manage_audit,
    notify  => $manage_notify,
  }

  exec { "postmap-${name}":
    command     => "/usr/sbin/postmap ${path}",
    require     => Package['postfix'],
    refreshonly => true,
  }

}
