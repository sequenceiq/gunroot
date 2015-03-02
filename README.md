Internal tool based https://github.com/gliderlabs/glidergun

## Install

```
curl https://circle-artifacts.com/gh/lalyos/glidergun/36/artifacts/0/tmp/circle-artifacts.hJ6WcXt/gun-darwin.tgz | tar -zxC /usr/local/bin
git clone git@github.com:sequenceiq/gunroot.git ~/.gunroot
alias gun='GUN_ROOT=~/.gunroot /usr/local/bin/gun' 
alias sgun='gun seq'
alias jump='gun jump run'
```

## Permanent aliases

You can save the aliases in your `~/.profile` or `~/.bash_profile`
