# = Define: postfix::map
#
# Adds a postfix lookup table
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
define postfix::map(
  $source   = params_lookup( 'source' ),
  $template = params_lookup( 'template' ),
  $maps     = params_lookup( 'maps' ),
  $path     = "${postfix::config_dir}/${name}",
) {
  include postfix

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

  file {
    "postfix::map_${name}":
      ensure  => present,
      path    => $path,
      mode    => $postfix::config_file_mode,
      owner   => $postfix::config_file_owner,
      group   => $postfix::config_file_group,
      require => Package['postfix'],
      notify  => Exec["postmap-${name}"],
      source  => $manage_file_source,
      content => $manage_file_content,
      replace => $postfix::manage_file_replace,
      audit   => $postfix::manage_audit,
  }
  exec {
    "postmap-${name}":
      command => "/usr/sbin/postmap ${path}",
      require => Package['postfix'],
      creates => "${path}.db";
  }
}

