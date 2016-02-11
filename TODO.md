# TODO

* #magic beans: it's like magic for your bash script needs. turn your bash scripts from this: to this: (extensive example)
* false boolean should return fail when invoked as a property
* redirect throws to 3 or somewhere else and redirect that else to stderr, so they can't be supressed
* md5sum in external imports
* don't depend on mktemp (http://www.linuxsecurity.com/content/view/115462/151/#mozTocId316364)
* save previous trap state before setting a new one and restore when unsetting
* await/async for bash (perhaps coproc http://stackoverflow.com/questions/20017805/bash-capture-output-of-command-run-in-background & http://wiki.bash-hackers.org/syntax/keywords/coproc & http://www.ict.griffith.edu.au/anthony/info/shell/co-processes.hints or http://unix.stackexchange.com/a/116802/106138)
* [function] argument resolver, checking if a method exists or defining an anonymous method
* [commands/options] parser for params
* autodownload precompiled bash 4 when running bash <4.
* lib for mutex lock (http://wiki.bash-hackers.org/howto/mutex)
* some functionality from how-to (http://wiki.bash-hackers.org/start)
* md5sum of script requested online
* recommend some libs, e.g.:
* https://github.com/AsymLabs/realpath-lib
* https://github.com/themattrix/bash-concurrent
* https://github.com/jmcantrell/bashful

## import examples

```
import http://localhost:9000/test.sh
import github:themattrix/bash-concurrent/master/demo.sh
import github:avleen/bashttpd/master/bashttpd
import github:sstephenson/bats/master/libexec/bats
import github:AsymLabs/realpath-lib/master/make-generic-test.sh
```
