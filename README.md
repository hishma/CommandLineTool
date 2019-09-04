# CommandLineTool

Example command line tool written in swift.


This uses the `SPMUtility` package that is part of the [Swift Pakcage Manager](https://swift.org/package-manager/) to process command line arguments in a type safe way (unlike getopt).

## Install and build

1. Download the repo and `cd` into the project directory in Terminal.app.
1. `swift package update`
1. `swift build`
1. `swift run CommandLineTool --help`

### Xcode

1. `swift package generate-xcodeproj`
1. `open CommandLineTool.xcodeproj`
