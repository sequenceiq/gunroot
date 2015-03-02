init() {
    
	cmd-export-ns seq "SequenceIQ namespace"
	cmd-export seq-update
}

seq-update() {
  declare desc="Updates the SequenceIQ glidergun modules"

  if [[ -d $GUN_ROOT/.git ]]; then
      local remote=$(git remote -v|head -1|sed "s/^.*git@/git@/; s/ .*//")
      debug updating $GUN_ROOT from $remote
      cd $GUN_ROOT
      git stash
      git pull --rebase origin master
      cd -
  fi
}
