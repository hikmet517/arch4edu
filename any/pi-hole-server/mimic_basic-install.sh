source "/etc/pihole/setupVars.conf"
PI_HOLE_BIN_DIR="/usr/bin"

webroot="/srv/http/pihole"

# from official basic-install.sh
valid_ip() {
    # Local, named variables
    local ip=${1}
    local stat=1

    # Regex matching one IPv4 component, i.e. an integer from 0 to 255.
    # See https://tools.ietf.org/html/rfc1340
    local ipv4elem="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]?|0)";
    # Regex matching an optional port (starting with '#') range of 1-65536
    local portelem="(#(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|[1-9][0-9]{0,3}|0))?";
    # Build a full IPv4 regex from the above subexpressions
    local regex="^${ipv4elem}\.${ipv4elem}\.${ipv4elem}\.${ipv4elem}${portelem}$"

    # Evaluate the regex, and return the result
    [[ $ip =~ ${regex} ]]

    stat=$?
    return "${stat}"
}

valid_ip6() {
    local ip=${1}
    local stat=1

    # Regex matching one IPv6 element, i.e. a hex value from 0000 to FFFF
    local ipv6elem="[0-9a-fA-F]{1,4}"
    # Regex matching an IPv6 CIDR, i.e. 1 to 128
    local v6cidr="(\\/([1-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])){0,1}"
    # Regex matching an optional port (starting with '#') range of 1-65536
    local portelem="(#(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|[1-9][0-9]{0,3}|0))?";
    # Build a full IPv6 regex from the above subexpressions
    local regex="^(((${ipv6elem}))*((:${ipv6elem}))*::((${ipv6elem}))*((:${ipv6elem}))*|((${ipv6elem}))((:${ipv6elem})){7})${v6cidr}${portelem}$"

    # Evaluate the regex, and return the result
    [[ ${ip} =~ ${regex} ]]

    stat=$?
    return "${stat}"
}

# from official utils.sh
addOrEditKeyValPair() {
  local file="${1}"
  local key="${2}"
  local value="${3}"

  # touch file to prevent grep error if file does not exist yet
  touch "${file}"

  if grep -q "^${key}=" "${file}"; then
    # Key already exists in file, modify the value
    sed -i "/^${key}=/c\\${key}=${value}" "${file}"
  else
    # Key does not already exist, add it and it's value
    echo "${key}=${value}" >> "${file}"
  fi
}

addKey(){
  local file="${1}"
  local key="${2}"

  # touch file to prevent grep error if file does not exist yet
  touch "${file}"

  # Match key against entire line, using both anchors. We assume
  # that the file's keys never have bounding whitespace. Anchors
  # are necessary to ensure the key is considered absent when it
  # is a substring of another key present in the file.
  if ! grep -q "^${key}$" "${file}"; then
    # Key does not exist, add it.
    echo "${key}" >> "${file}"
  fi
}

removeKey() {
  local file="${1}"
  local key="${2}"
  sed -i "/^${key}/d" "${file}"
}