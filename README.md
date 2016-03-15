# Trevi-sys

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Mac OS X](https://img.shields.io/badge/platform-osx-lightgrey.svg?style=flat)](https://developer.apple.com/swift/)
[![Ubuntu](https://img.shields.io/badge/platform-linux-lightgrey.svg?style=flat)](http://www.ubuntu.com/)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

## Overview
This is the TreviSys module for Trevi project.

## Swift version
Trevi works with the latest version of Swift 2.2 Snapshot. You can download Swift binaries on [here](https://swift.org/download/#latest-development-snapshots).

## Installation (Ubuntu; APT-based linux)
1. Update your local package index first.
    ```bash
    $ sudo apt-get update && sudo apt-get upgrade
    ```
    
2. Install Swift dependencies on linux:
    ```bash
    $ sudo apt-get install clang libicu-dev
    ```
    
3. Install Swift depending on your platform on the follow [link](https://swift.org/download) (The latest version are recommended).

4. After installation of Swift, check your PATH environment variable whether Swift binary path is set or not. If it is not set execute below.:
    ```bash
    $ export PATH=/path/to/swift/installed/usr/bin:"${PATH}"
    ```
    
    More details : 'Linux' on [here](https://swift.org/download)
    
5. Install git to clone libuv:
    ```bash
    $ sudo apt-get install git
    ```
    
6. Install libuv dependencies on linux:
    ```bash
    $ sudo apt-get install autoconf automake make build-essential libtool gcc g++
    ```
    
7. Clone libuv:
    ```bash
    $ git clone https://github.com/libuv/libuv.git
    ```
    
6. Install libuv:
    ```bash
    $ cd libuv
    $ sh autogen.sh
    $ ./configure
    $ make
    $ make check
    $ sudo make install
    ```
    
    More details : Build Instructions on [libuv](https://github.com/libuv/libuv)

## Installation (OS X)
1. Install Swift depending on your platform on the follow [link](https://swift.org/download) (The latest version are recommended).

2. After installation of Swift, check your PATH environment variable whether Swift binary path is set or not. If it is not set execute below.:
    ```bash
    $ export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
    ```
    
    More details : 'Apple Platforms' on [here](https://swift.org/download)
    
3. Clone libuv:
    ```bash
    $ git clone https://github.com/libuv/libuv.git
    ```
    
4. Install libuv:
    ```bash
    $ cd libuv
    $ sh autogen.sh
    $ ./configure
    $ make
    $ make check
    $ sudo make install
    ```
    
    or using Homebrew:
    
    ```bash
    $ brew install --HEAD libuv
    ```
    
    More details : Build Instructions on [libuv](https://github.com/libuv/libuv)
    
## Versioning
TreviSys follows the semantic versioning scheme. The API change and backwards compatibility rules are those indicated by SemVer.

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).

```
Copyright 2015 Trevi Community

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
