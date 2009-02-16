# Clippy

## A simple MacRuby script to post the contents of your clipboard to TwitPic

Currently the authentication is pretty stupid, just make a file named acct.yaml in the same directory as clippy with your username and password. See acct.example.yaml for the mind-bending complexities of this format.

Canonical use-pattern: cmd-ctrl-shift-4, `macruby clippy.rb this is teh awesome screenshot`.

## TODO

- give any indication of success or failure
- come up with an easy way to run this without dropping into terminal
- use keychain (`security`) to get your twitter acct/password