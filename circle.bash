init() {
    cmd-export-ns cci "CircleCI namespace"
	cmd-export cci-latest
    
    #echo colors=${!color_table[@]}
    #for color in "${!color_table[@]}"; do
        #eval "echo $color|$color"
    #done
    
}


debug() {
    [[ "$DEBUG" ]] && echo "[DEBUG] $@" | gray 1>&2 || true
}

cci-latest() {
    declare desc="Get latest build number from CircleCI"
    declare project=$1
    : ${project:?}

    local account=$(circle me|jq .name -r)
    debug account: $account
    
    local latest=$(circle "project/$account/$project/tree/master?filter=completed&limit=1" |jq .[0].build_num)
    debug latest build: $latest

    circle  "project/$account/$project/$latest/artifacts" | jq .[].url -r | grep -i $(uname)
}

circle() {
    declare path=$1
    : ${CIRCLE_TOKEN:? required}
    shift
    
    local url="https://circleci.com/api/v1/$path"
    debug CURL: $url
    
    local auth="circle-token=$CIRCLE_TOKEN"
    [[ $url =~ "?" ]] && url="$url&$auth" || url="$url?$auth"

    curl -s \
        -H "Accept: application/json" \
        "$url" "$@"
}
