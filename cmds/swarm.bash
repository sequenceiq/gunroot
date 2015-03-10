init() {
    deps-require swarm
    
    cmd-export-ns swarm "Swarm namespace"
    cmd-export swarm-manager
}

swarm-manager() {
  declare desc="Strarts swarm manager with file: discovery"
  declare prefix=$1

  : ${prefix:?}

  $(deps-dir)/bin/swarm help
}
