init() {
    BRIDGE_IP=$(boot2docker ip)
    cmd-export-ns cn "Consul namespace"
    cmd-export cn-serv
    cmd-export cn-dh
    cmd-export cn-dp
    cmd-export cn-dhp
}

con() {
  declare path="$1"
  shift
  local consul_ip=$(dig @${BRIDGE_IP} +short consul.service.consul)
  curl -s ${consul_ip}:8500/v1/${path} "$@"
}

cn-serv(){
  declare desc="Lists services registered in consul"
  [ $# -gt 0 ] && path=service/$1 || path=services
  con catalog/$path -s |jq .
}

# dig service host ip
cn-dh() {
  declare desc="Digs service host"
  declare service=$1
  :${service?: required}
  dig @${BRIDGE_IP} +short $service.service.consul
}

# dig service port
cn-dp() {
  declare desc="Digs service port"
  declare service=$1
  :${service?: required}
  dig @${BRIDGE_IP} +short $service.service.consul SRV | cut -d" " -f 3
}

# dig host:port
cn-dhp(){
  declare desc="dig host:port of a service"
  declare service=$1
  :${service?: required}
  
  echo $(cn-dh $service):$(cn-dp $service)
}
