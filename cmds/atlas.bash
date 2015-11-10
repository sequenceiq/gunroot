
init() {
  
  cmd-export-ns atlas "Hashicorp Atlas Artifact namespace"
  cmd-export atlas-show-last
  cmd-export atlas-get-last-yml
  
  env-import ATLAS_BASE_URL https://atlas.hashicorp.com/api/v1/artifacts/sequenceiq
  env-import ATLAS_ARTIFACT cbd
  : #{DEBUG:=1}
}

debug() {
  [[ "$DEBUG" ]] && echo "[DEBUG] $*" 1>&2
}

#alias r=". $BASH_SOURCE"

atlas-show-last() {
    declare desc="Displays last atlas artifact json"
    declare cloud_type=${1:? cloud_type requireed as 1. param, eg amazon.image or googlecompute.yml}

    curl -sL "$ATLAS_BASE_URL/$ATLAS_ARTIFACT/${cloud_type}/search" \
        | jq '.versions[0]'
}

atlas-get-last-yml() {
    declare desc="Displays latest yml artifact from choosen cloud: amazon/azure/googlecompute/openstack"
    declare cloud=${1:? cloud_type requireed as 1. param, eg amazon/azure/googlecompute/openstack}

    local ver=$(atlas-show-last ${cloud}.yml | jq .version)
    debug "last yml version: $ver"
    curl -sL "$ATLAS_BASE_URL/$ATLAS_ARTIFACT/${cloud}.yml/${ver}/file" \
        | tar -xzO
}

_in_last_hpur() {
     :#   |jq '.versions[]|select(.metadata.created_at > "'$(date -v-1d +%s)'" )'
}

