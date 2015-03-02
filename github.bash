init() {
    
	cmd-export-ns gh "Github namespace"
	cmd-export gh-peco
    deps-require sqlite
    deps-require peco

    : ${DEFAULT_BROWSER:=safari}
}

chrome_history() {
  declare desc="lists github visited github.com urls from chrome history"

  debug $desc
  local tmpdb=/tmp/hist.db
  cp ~/Library/Application\ Support/Google/Chrome/Default/History $tmpdb
  sqlite3 $tmpdb "select url from urls where url like 'https://github.com/%';"
}
  
safari_history() {
  declare desc="lists github visited github.com urls from safari history"
  
  debug $desc
  local tmpdb=/tmp/hist.db
  cp ~/Library/Safari/History.db $tmpdb
  sqlite3 $tmpdb "select url from history_items where url like 'https://github.com/%';"
}

github_history() {
    debug DEFAULT_BROWSER=$DEFAULT_BROWSER
    case $DEFAULT_BROWSER in 
        safari) safari_history;;
        chrome) chrome_history;;
    esac
}

gh-peco() {
  declare desc="Interactivly selects a github repo from hist, and opens in a browser"
  declare query="$*"
  
  set -x
  
  github_history \
    | sed -n "s@https://github.com/\([^\/]*\)/\([^\/]*\)/.*@\1/\2@p" \
    | sort -u \
    | peco --query "$query " \
    | xargs -L 1 -I@ open https://github.com/@
  set +x
}

