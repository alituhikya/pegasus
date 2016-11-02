rebar eunit -C test.config suite=validator_tests

cassandra
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.cassandra.plist
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.cassandra.plist