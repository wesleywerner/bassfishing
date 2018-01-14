# release process
* toggle the "debug" flag in game.lua
* update the version number in game.lua
* append (and edit!) the changlog:

        # output log since tag "v1", titles only and in commit order
        git log --pretty=format:%s v1..HEAD | tac >> CHANGELOG.md

*commit and tag:

        git add . & git commit
        git tag -a "v1"
        git push --tags

zip the source into the builds directory:

    src$ zip -r ../builds/game.love *
