#
# This class executes a reload of postfix
#
class postfix::reload {
  exec {'postfix_reload':
    command     => '/usr/sbin/postfix reload',
    refreshonly => true,
    onlyif      => '/usr/sbin/postfix status',
  }
}
