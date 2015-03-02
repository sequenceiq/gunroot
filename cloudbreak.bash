init() {
    
	cmd-export-ns cb "Cloudbreak namespace"
	cmd-export cb-health
    cmd-export cb-consul-ui
    deps-require jq 1.4
}


cb-consul-ui() {
    declare desc="Opens consul-ui in yur default browser"
    
    local b2d=$(boot2docker ip)
    openbrowser "http://$b2d:8500/"

}

check-service() {
  declare service=$1

  local status=$(con health/checks/$service|jq '.[0].Status' -r)
  case "$status" in
      passing)
          echo "$status" | green;;
      critical)
          echo "$status" | red;;
      *)
          echo "$status" | yellow;;
  esac
}
cb-health() {
    declare desc="Lists cloudbreak components, with consul healthchecks"

	echo "Services:"
    for s in $(cn-serv|jq keys[] -r|grep -v consul); do
        printf " - %-15s:" "$s"
        check-service $s
    done
}

