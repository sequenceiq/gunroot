init() {
    deps-require swarm
    deps-require docker-machine
    
    cmd-export-ns swarm "Swarm namespace"
    cmd-export swarm-manager
    cmd-export swarm-generate-file

    : ${SWARM_DIR:=/tmp}
}

swarm-generate-file() {
  declare desc="Generates swarm file containing docker-machine started hosts"
  declare prefix=$1

  : ${prefix:?}
  
  local machines=$(docker-machine ls -q | grep $prefix)
  debug machines=$machines

  debug generating $SWARM_DIR/$prefix.swarm ...
  for m in $machines; do 
    docker-machine url $m|sed s/^tcp...//
  done > $SWARM_DIR/$prefix.swarm
}

swarm-manager() {
  declare desc="Strarts swarm manager with file: discovery"
  declare prefix=$1

  : ${prefix:?}

  $(deps-dir)/bin/swarm help
}
