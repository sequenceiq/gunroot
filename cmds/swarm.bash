init() {
    deps-require swarm
    deps-require docker-machine
    
    cmd-export-ns swarm "Swarm namespace"
    cmd-export swarm-manager
    cmd-export swarm-generate-file
    cmd-export swarm-get-cert-opts

    : ${SWARM_DIR:=/tmp}
}

swarm-generate-file() {
  declare desc="Generates swarm file containing docker-machine started hosts"
  declare prefix=$1

  : ${prefix:?}
  
  debug $desc
  local machines=$(docker-machine ls -q | grep $prefix)
  debug machines=$machines

  debug generating $SWARM_DIR/$prefix.swarm ...
  for m in $machines; do 
    docker-machine url $m|sed s/^tcp...//
  done > $SWARM_DIR/$prefix.swarm
}

swarm-get-cert-opts() {
  declare desc="Gets certificate options from docker-machine"
  declare prefix=$1

  : ${prefix:?}
  local first=$(docker-machine ls -q | grep $prefix | head -1)

  debug getting CERT options for $first
  docker-machine config $first | sed "s/ /\n/g"|sed -n "/tls./ H; $ {x; s/\n/ /gp}"
}

swarm-manager() {
  declare desc="Strarts swarm manager with file: discovery"
  declare prefix=$1

  : ${prefix:?}

  if [ ! -e $SWARM_DIR/${prefix}.swarm ] ;then
    swarm-generate-file $prefix
  fi

  swarm-generate-docker-fn

  local certOpts=$(swarm-get-cert-opts $prefix)
  
  $GUN_ROOT/.gun/bin/swarm manage \
    -H tcp://0.0.0.0:3376 \
    --tlsverify \
    $certOpts \
    file://$SWARM_DIR/${prefix}.swarm

}

swarm-generate-docker-fn() {
  declare desc="Generates docker fn which talks to local swarm manager"
  declare prefix=$1

  local cacert=$(machine inspect boot-1| jq .CaCertPath -r)
  local certdir=${cacert%/*}
  debug certdir=$certdir
  
  echo === docker fn to talk to SWARM === | yellow
(cat <<EOF
docker() { 
  DOCKER_TLS_VERIFY='' \\
  DOCKER_CERT_PATH=$certdir \\
  /usr/local/bin/docker \\
    --tls \\
    -H tcp://127.0.0.1:3376 \\
    "\$@"
}
EOF
) | green

  echo ================================= | yellow

}
