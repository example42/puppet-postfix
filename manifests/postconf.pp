define postfix::postconf (
  $key = '',
  $value,
) {

  $real_key = $key?{
    ''      => $name,
    default => $key
  }

  $key_value = "${real_key} = ${value}"

  exec{"postconf_${real_key}":
    command => "postconf -e '${key_value}'",
    unless  => "test \"\$(postconf ${real_key})\" = '$key_value'",
    path    => $::path
  }
}
