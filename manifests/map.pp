# Define: postfix::map
#
# Adds a postfix lookup table
#
# Usage:
# postfix::map { 'canonical':
#   source => 'puppet:///modules/example42/postfix/canonical'
# }
#
define postfix::map(
  $source              = params_lookup( 'source' ),
  $template            = params_lookup( 'template' ),
  $path = "${postfix::config_dir}/${name}",
) {
  include postfix

  $manage_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }

  $manage_file_content = $template ? {
    ''        => undef,
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

