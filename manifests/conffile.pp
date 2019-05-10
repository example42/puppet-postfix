# = Define: postfix::conffile
#
# Adds a postfix configuration file.
# It is mainly a file resource that also restarts postfix
#
# == Parameters
#
# [*ensure*]
#   Ensure parameter for the file resource. Defaults to 'present'
#
# [*source*]
#   Sets the value of the source parameter for the file
#
# [*template*]
#   Sets the value of content parameter for the postfix config file
#   Defaults to 'postfix/conffile.erb'.
#   Note: This option is alternative to the source and content one
#
# [*content*]
#   Sets the content of the postfix config file
#   Note: This option is alternative to the source and template one
#
# [*path*]
#   Where to create the file.
#   Defaults to "${postfix::config_dir}/${name}".
#
# [*mode*]
#   The file permissions of the file.
#   Defaults to $postfix::config_file_mode
#
# [*options*]
#   Hash with options to use in the template
#
# == Usage:
# postfix::conffile { 'ldapoptions.cf':
#   options            => {
#     server_host      => <ldapserver>,
#     bind             => 'yes',
#     bind_dn          => <bind_dn>,
#     bind_pw          => <bind_pw>,
#     search_base      => 'dc=example, dc=com',
#     query_filter     => 'mail=%s',
#     result_attribute => 'uid',
#   }
# }
#
# postfix::conffile { 'ldapoptions.cf':
#   source => 'puppet:///modules/postfix/ldapoptions.cf',
# }
#
define postfix::conffile (
  $ensure   = 'present',
  $source   = params_lookup('source'),
  $template = params_lookup('template'),
  $content  = params_lookup('content'),
  $path     = "${postfix::config_dir}/${name}",
  $mode     = $postfix::config_file_mode,
  $options  = {},
) {

  $manage_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }

  $manage_file_content = $template ? {
    ''      => $content ? {
      ''      => template('postfix/conffile.erb'),
      default => $content,
    },
    default => template($template),
  }

  file { "postfix::conffile_${name}":
    ensure  => $ensure,
    path    => $path,
    mode    => $mode,
    owner   => $postfix::config_file_owner,
    group   => $postfix::config_file_group,
    require => Package['postfix'],
    source  => $manage_file_source,
    content => $manage_file_content,
    replace => $postfix::manage_file_replace,
    audit   => $postfix::manage_audit,
    notify  => $postfix::manage_service_autorestart;
  }

}
