init() {
    deps-require jq 1.4
    deps-require peco
    cmd-export-ns gist "Github gist namespace"
    cmd-export gist-list
    cmd-export gist-search
}

gist-curl() {
  declare desc="Adds authentication to github api"
  declare path=$1
  shift

  local sep="?"
  [[ $path =~ \? ]] && sep="&"

  curl -s "https://api.github.com/${path}${sep}access_token=$GITHUB_TOKEN" "$@"
}

gist-search() {
    declare desc="Search in gists by file name matching with peco"

    gist-list | peco "$@"
}

gist-list() {
  declare desc="Lists private gists"

  env-import GITHUB_TOKEN
  user=$(gist-curl user |jq .login -r)

  echo "github user: $user" | green
  gist-curl "users/$user/gists?per_page=100" | jq ".[]|[.url, (.files|keys)[]]" -c
}
