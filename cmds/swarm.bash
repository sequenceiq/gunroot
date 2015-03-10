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

  local certOpts=$(swarm-get-cert-opts $prefix)
  
  $GUN_ROOT/.gun/bin/swarm manage \
    -H tcp://0.0.0.0:3376 \
    --tlsverify \
    $certOpts \
    file://$SWARM_DIR/${prefix}.swarm

}
