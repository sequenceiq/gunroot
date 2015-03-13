init() {
    deps-require swarm
    deps-require docker-machine
    
    cmd-export-ns lswarm "Local swarm namespace"
    cmd-export lswarm-manager
    cmd-export lswarm-generate-file
    cmd-export lswarm-kill-dockers
    cmd-export lswarm-start-dockers

    : ${SWARM_DIR:=/tmp}
}

lswarm-start-dockers() {
  declare desc="Starts the docker daemons locally (dind)"
  declare serverNum=${1:-5}

  debug $desc
  debug "number of servers: $serverNum"

  for n in {1..5}; do
      local container="swarm-dind-$n"
      debug starting container: $container
      
      docker run -d \
          --privileged \
          --name $container \
          -p 444$n:444$n \
          -e PORT=444$n \
          jpetazzo/dind
  done
}

lswarm-kill-dockers() {
    declare desc="Kills all docker container running dind"

    local containers=$(get-dind-containers)

    docker stop -t 0 $containers
    docker rm $containers
}

get-dind-containers() {
      docker inspect -f '{{.Id}} {{.Config.Image}}' \
          $(docker ps -qa) \
      | sed -n "/jpetazzo\/dind/ s/ .*//p"
}

lswarm-generate-file() {
  declare desc="Generates swarm file containing docker-machine started hosts"

  debug $desc
  containers=$(get-dind-containers)

  debug generating $SWARM_DIR/local.swarm ...
  for cont in $containers; do 
      local port=$(
        docker inspect -f '{{range .Config.Env}}{{.}} {{end}}' $cont \
            | sed "s/.*PORT=//; s/ .*//"
      )
      local ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' $cont )
      debug $ip:$port
      echo $ip:$port
  done > $SWARM_DIR/local.swarm
}

lswarm-manager() {
  declare desc="Strarts swarm manager with file: discovery"

  lswarm-generate-file
  lswarm-generate-docker-fn

  $GUN_ROOT/.gun/bin/swarm manage \
    --strategy random \
    -H tcp://0.0.0.0:3376 \
    file://$SWARM_DIR/local.swarm

}

lswarm-generate-docker-fn() {
  declare desc="Generates docker fn which talks to local swarm manager"
  
  echo === docker fn to talk to local swarm === | yellow
(cat <<EOF
docker() { 
  DOCKER_TLS_VERIFY='' \\
  /usr/local/bin/docker \\
    --tls=false \\
    -H tcp://127.0.0.1:3376 \\
    "\$@"
}
EOF
) | green

  echo ================================= | yellow

}
