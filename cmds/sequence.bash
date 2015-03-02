init() {
    
	cmd-export-ns seq "SequenceIQ namespace"
	cmd-export seq-update
    cmd-export seq-alias
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

seq-update() {
  declare desc="Updates the SequenceIQ glidergun modules and the binary from CircleCI"
  
  seq_update_modules
  seq_update_binary
}

seq-alias() {
  declare desc="Prints usefull aliases"

  cat<<EOF
alias gun='GUN_ROOT=~/.gunroot /usr/local/bin/gun' 
alias sgun='gun seq'
alias jump='gun jump run'
alias =''
EOF
}
