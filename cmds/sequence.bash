init() {
    
	cmd-export-ns seq "SequenceIQ namespace"
	cmd-export seq-update
    cmd-export seq-alias
    seq_find_profile
}


seq_update_modules() {
  if [[ -d $GUN_ROOT/.git ]]; then
      local remote=$(git remote -v|head -1|sed "s/^.*git@/git@/; s/ .*//")
      debug updating $GUN_ROOT from $remote
      cd $GUN_ROOT
      git stash
      git pull --rebase origin master &> /dev/null
      cd - &> /dev/null
  fi
}

seq_update_binary() {
    local latest=$(cci-latest glidergun)

    debug latest binary: $latest
    curl -Lk $latest | tar -zxC /usr/local/bin
}

seq_find_profile() {
  [ -f ~/.profile ] && _PROFILE=~/.profile || _PROFILE=~/.bash_profile
}

seq-update() {
  declare desc="Updates the SequenceIQ glidergun modules and the binary from CircleCI"
  
  seq_update_modules
  seq_update_binary
}

seq_delete_aliases() {
  sed -i.bak '/gun_aliases()/,/^}/ d' ${_PROFILE}
}

seq_save_aliases() {
  cat >> ${_PROFILE} <<EOF
gun_aliases(){
  alias gun='GUN_ROOT=~/.gunroot /usr/local/bin/gun' 
  alias sgun='gun seq'
  alias jump='gun jump run'
  alias ghp='gun gh peco'
}; gun_aliases
EOF

}

seq-alias() {
  declare desc="Saves usefull aliases into .profile/.bash_profile"

  seq_delete_aliases
  seq_save_aliases

  echo "#####################" | yellow
  echo "reload your profile:" | yellow
  echo " " | yellow
  echo " source ${_PROFILE}" | green
  echo "#####################" | yellow
}
