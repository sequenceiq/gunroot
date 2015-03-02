init() {
    
	cmd-export-ns seq "SequenceIQ namespace"
	cmd-export seq-update
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
}

seq-update() {
  declare desc="Updates the SequenceIQ glidergun modules"
  
  seq_update_modules
  seq_update_binary
}
