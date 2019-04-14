Bash Infinity
=============
[![Build Status](https://travis-ci.com/niieani/bash-oo-framework.svg?branch=master)](https://travis-ci.com/niieani/bash-oo-framework)
[![Build Status](https://api.cirrus-ci.com/github/niieani/bash-oo-framework.svg)](https://cirrus-ci.com/github/niieani/bash-oo-framework)
[![Join the chat at https://gitter.im/niieani/bash-oo-framework](https://badges.gitter.im/niieani/bash-oo-framework.svg)](https://gitter.im/niieani/bash-oo-framework?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Bash Infinity is a standard library and a boilerplate framework for writing tools using **bash**.
It's modular and lightweight, while managing to implement some concepts from C#, Java or JavaScript into bash.
The Infinity Framework is also plug & play: include it at the beginning of your existing script to import any of the individual features such as error handling, and start using other features gradually.

The aim of Bash Infinity is to maximize readability of bash scripts, minimize the amount of code repeat and create a central repository for well-written, and a well-tested standard library for bash.

Bash Infinity transforms the often obfuscated "bash syntax" to a cleaner, more modern syntax.

Disclaimer
==========

Some components are more sturdy than others, and as-it-stands the framework lacks good test coverage (we need your help!).

Due to the above and relatively high code-complexity, we have decided that it will make the most sense to do a rewrite for the next major version 3.0 (see discussion in #45), taking the best parts of the framework, while re-using established tools from bash community.

At this point, I would **not recommend starting major projects** based on the whole framework. Instead, copy and paste parts you need, ideally those you understand, if you found a particular feature useful.

Compatibility
=============

Not all of the modules work with earlier versions of bash, as I test with **bash 4**. However, it should be possible (and relatively easy) to [port non-working parts](#porting-to-bash-3) to earlier versions.

Quick-start
===========

Single-file release and dynamic loading is not available for v2.0 yet. To load the framework locally, [read on](#how-to-use).

Main modules
============

* automatic error handling with exceptions and visual stack traces (`util/exception`)
* named parameters in functions (instead of $1, $2...) (`util/namedParameters`)
* passing arrays and maps as parameters (`util/variable`)
* **try-catch** implementation (`util/tryCatch`)
* throwing custom **exceptions** (`util/exception`)
* **import** keyword for clever sourcing of scripts à la *require-js* (`oo-bootstrap`)
* handy aliases for **colors** and **powerline** characters to increase readability in the output of your scripts (`UI/Color`)
* well-formatted, colorful **logging** to *stderr* or custom delegate functions (`util/log`)
* **unit test** library (`util/test`)
* standard library for the type system with plenty of useful functions (`util/type`)
* operational chains for **functional programming** in bash (`util/type`)
* **type system** for object-oriented scripting (`util/class`)

All of the features are modular and it's easy to only import the ones you'd like to use, without importing the rest of the framework. For example, the named parameters or the try-catch modules are self-contained in individual files.

Error handling with exceptions and `throw`
==============================================

```
import util/exception
```

One of the highlight features is error handling that should work out of the box. If the script generates an error it will break and display a call stack:

![example call stack](https://raw.githubusercontent.com/niieani/bash-oo-framework/master/docs/exception.png "Example Call Stack")

You may also force an error by `throw`ing your own Exception:

```bash
e="The hard disk is not connected properly!" throw
```

It's useful for debugging, as you'll also get the call stack if you're not sure where the call is coming from.

**Exceptions** combined with *try & catch* give you safety without having to run with **-o errexit**.

If you do something wrong, you'll get a detailed exception backtrace, highlighting the command where it went wrong in the line from the source. The script execution will be halted with the option to continue or break.
On the other hand if you expect a part of block to fail, you can wrap it in a `try` block, and handle the error inside a `catch` block.

Named parameters in functions
=============================

```
import util/namedParameters
```

In any programing language, it makes sense to use meaningful names for variables for greater readability.
In case of Bash, that means avoiding using positional arguments in functions.
Instead of using the unhelpful `$1`, `$2` and so on within functions to access the passed in values, you may write:

```bash
testPassingParams() {

    [string] hello
    [string[4]] anArrayWithFourElements
    l=2 [string[]] anotherArrayWithTwo
    [string] anotherSingle
    [reference] table   # references only work in bash >=4.3
    [...rest] anArrayOfVariedSize

    test "$hello" = "$1" && echo correct
    #
    test "${anArrayWithFourElements[0]}" = "$2" && echo correct
    test "${anArrayWithFourElements[1]}" = "$3" && echo correct
    test "${anArrayWithFourElements[2]}" = "$4" && echo correct
    # etc...
    #
    test "${anotherArrayWithTwo[0]}" = "$6" && echo correct
    test "${anotherArrayWithTwo[1]}" = "$7" && echo correct
    #
    test "$anotherSingle" = "$8" && echo correct
    #
    test "${table[test]}" = "works"
    table[inside]="adding a new value"
    #
    # I'm using * just in this example:
    test "${anArrayOfVariedSize[*]}" = "${*:10}" && echo correct
}

fourElements=( a1 a2 "a3 with spaces" a4 )
twoElements=( b1 b2 )

declare -A assocArray
assocArray[test]="works"

testPassingParams "first" "${fourElements[@]}" "${twoElements[@]}" "single with spaces" assocArray "and more... " "even more..."

test "${assocArray[inside]}" = "adding a new value"
```

The system will automatically assign:
 * **$1** to **$hello**
 * **$anArrayWithFourElements** will be an array of params with values from $2 till $5
 * **$anotherArrayWithTwo** will be an array of params with values from $6 till $7
 * **$8** to **$anotherSingle**
 * **$table** will be a reference to the variable whose name was passed in as the 9th parameter
 * **$anArrayOfVariedSize** will be a bash array containing all the following params (from $10 on)

In other words, not only you can call your parameters by their names (which makes up for a more readable core), you can actually pass arrays easily (and references to variables - this feature needs bash >=4.3 though)! Plus, the mapped variables are all in the local scope.
This module is pretty light and works in bash 3 and bash 4 (except for references - bash >=4.3) and if you only want to use it separately from this project, get the file /lib/system/02_named_parameters.sh.

Note: For lengths between 2-10 there are aliases for arrays, such as ```[string[4]]```, if you need anything more, you need to use the syntax ```l=LENGTH [string[]]```, like shown in the above example. Or, make your own aliases :).

Using ```import```
==================

After bootstrapping, you may use `import` to load either the library files or your own files.
The command will ensure they're only loaded once. You may either use a relative path from the file you're importing, a path relative to the file that first included the framework, or an absolute path. `.sh` suffix is optional.
You can also load all the files inside of a directory by simply including the path to that directory instead of the file.

Using `try & catch`
=======================

```bash
import util/tryCatch
import util/exception # needed only for Exception::PrintException
```

Sample usage:

```bash
try {
    # something...
    cp ~/test ~/test2
    # something more...
} catch {
    echo "The hard disk is not connected properly!"
    echo "Caught Exception:$(UI.Color.Red) $__BACKTRACE_COMMAND__ $(UI.Color.Default)"
    echo "File: $__BACKTRACE_SOURCE__, Line: $__BACKTRACE_LINE__"

    ## printing a caught exception couldn't be simpler, as it's stored in "${__EXCEPTION__[@]}"
    Exception::PrintException "${__EXCEPTION__[@]}"
}
```

If any command fails (i.e. returns anything else than 0) in the ```try``` block, the system will automatically start executing the ```catch``` block.
Braces are optional for the ```try``` block, but required for ```catch``` if it's multiline.

Note: `try` is executed in a subshell, therefore you cannot assign any variables inside of it.

Using Basic Logging, Colors and Powerline Emoji
===============================================

```
import util/log
```

```bash
# using colors:
echo "$(UI.Color.Blue)I'm blue...$(UI.Color.Default)"

# enable basic logging for this file by declaring a namespace
namespace myApp
# make the Log method direct everything in the namespace 'myApp' to the log handler called DEBUG
Log::AddOutput myApp DEBUG

# now we can write with the DEBUG output set
Log "Play me some Jazz, will ya? $(UI.Powerline.Saxophone)"

# redirect error messages to STDERR
Log::AddOutput error STDERR
subject=error Log "Something bad happened."

# reset outputs
Log::ResetAllOutputsAndFilters

# You may also hardcode the use for the StdErr output directly:
Console::WriteStdErr "This will be printed to STDERR, no matter what."
```

Both the colors and the Powerline characters fallback gracefully on systems that don't support them.
To see Powerline icons, you'll need to use a powerline-patched font.

For the list of available colors and emoji's take a look into [lib/UI/Color.sh](https://github.com/niieani/bash-oo-framework/blob/master/lib/UI/Color.sh).
Fork and contribute more!

See [Advanced Logging](#advanced-logging) below to learn more about advanced logging capabilities.

Passing arrays, maps and objects as parameters
==============================================

```
import util/variable
```

The Variable utility offers lossless dumping of arrays and associative array (referred here to as `maps`) declarations by the use of the `@get` command.

Combined with the `util/namedParameters` module, you can pass in either as individual parameters.

A more readable way of specifying the will to pass a variable by it's declaration is to simply refer to the variable as `$var:yourVariableName`.

In bash >=4.3, which supports references, you may pass by reference. This way any changes done to the variable within the function will affect the variable itself. To pass a variable by reference, use the syntax: `$ref:yourVariableName`.

```bash
array someArray=( 'one' 'two' )
# the above is an equivalent of: declare -a someArray=( 'one' 'two' )
# except this one creates a $var:someArray method handler

passingArraysInput() {
  [array] passedInArray

  # chained usage, see below for more details:
  $var:passedInArray : \
    { map 'echo "${index} - $(var: item)"' } \
    { forEach 'var: item toUpper' }

  $var:passedInArray push 'will work only for references'
}

echo 'passing by $var:'

## 2 ways of passing a copy of an array (passing by it's definition)
passingArraysInput "$(@get someArray)"
passingArraysInput $var:someArray

## no changes yet
$var:someArray toJSON

echo
echo 'passing by $ref:'

## in bash >=4.3, which supports references, you may pass by reference
## this way any changes done to the variable within the function will affect the variable itself
passingArraysInput $ref:someArray

## should show changes
$var:someArray toJSON
```

Standard Library
================

```
import util/type
```

The framework offers a standard library for the primitive types, such as string or array manipulations to make common tasks simpler and more readable.

There are three ways to make use of the standard library.

### 1. Create variables by their handle-creating declaration

If you create your variables using the oo-framework's handle-creating declarations, you can execute methods of the standard library by referring to your variable as: `$var:yourVariable someMethod someParameter`.

Available handle-creating declarations:

* string
* integer
* array
* map
* boolean

Since bash doesn't support boolean variables natively, the boolean variable is a special case that always needs to be declared and modified using the handle-creating declaration.

Example:

```bash
# create a string someString
string someString="My 123 Joe is 99 Mark"

# saves all matches and their match groups for the said regex:
array matchGroups=$($var:someString getMatchGroups '([0-9]+) [a-zA-Z]+')

# lists all matches in group 1:
$var:matchGroups every 2 1

## group 0, match 1
$var:someString match '([0-9]+) [a-zA-Z]+' 0 1

# calls the getter - here it prints the value
$var:someString
```

### 2. Invoke the methods with `var:`

If you didn't create your variables with their handles, you can also use the method `var:` to access them.

Example:

```bash
# create a string someString
declare someString="My 123 Joe is 99 Mark"

# saves all matches and their match groups for the said regex:
declare -a matchGroups=$(var: someString getMatchGroups '([0-9]+) [a-zA-Z]+')

# lists all matches in group 1:
var: matchGroups every 2 1

## group 0, match 1
var: someString match '([0-9]+) [a-zA-Z]+' 0 1

# calls the getter - here it prints the value
var: someString
```

### 3. Pipe the variable declaration directly to the method

Finally, you can also pipe the variable declarations to the methods you wish to invoke.

Example:

```bash
# create a string someString
declare someString="My 123 Joe is 99 Mark"

# saves all matches and their match groups for the said regex:
declare -a matchGroups=$(@get someString | string.getMatchGroups '([0-9]+) [a-zA-Z]+')

# lists all matches in group 1:
@get matchGroups | array.every 2 1

## group 0, match 1
@get someString | string.match '([0-9]+) [a-zA-Z]+' 0 1

# prints the value
echo "$someString"
```

## Adding to the Standard Library

You can add your own, custom methods to the Standard Library by declaring them like:

```bash
string.makeCool() {
  @resolve:this ## this is required is you want to make use of the pipe passing
  local outValue="cool value: $this"
  @return outValue
}

string someString="nice"
$var:someString makeCool
# prints "cool value: nice"
```

See more info on writing classes below.

Functional/operational chains with the Standard Library and custom classes
==========================================================================

```
import util/type
```

The type system in Bash Infinity allows you to chain methods together in a similar fashion one might pipe the output from one command to the other, or chain methods in C#, Java or JavaScript (think JQuery's pseudo-monad style).

```bash
declare -a someArray=( 'one' 'two' )

var: someArray : \
  { map 'echo "${index} - $(var: item)"' } \
  { forEach 'var: item toUpper' }

# above command will result in a definition of an array:
# ( '0 - ONE' '1 - TWO' )
```

Methods available in the next chain depend on the return type of the previously executed method.

Writing your own classes
========================

It's really simple and straight-forward, like with most modern languages.

Keywords for definition:

* **class:YourName()** - defining a class

Keywords to use inside of the class definition:

* **method ClassName.FunctionName()** - Use for defining methods that have access to *$this*
* **public SomeType yourProperty** - define public properties (works in all types of classes)
* **private SomeType _yourProperty** - as above, but accessible only for internal methods
* **$this** - This variable is available inside the methods, used to refer to the current type
* **this** - Alias of $var:this, used to invoke methods or get properties of an object
* NOT YET IMPLEMENTED: **extends SomeClass** - inherit from a base class

After a class has been defined, you need to invoke `Type::Initialize NameOfYourType` or `Type::InitializeStatic NameOfYourStaticType` if you want to make your class a singleton.

Here's an example that shows how to define your own classes:

```bash
import util/namedParameters util/class

class:Human() {
  public string name
  public integer height
  public array eaten

  Human.__getter__() {
    echo "I'm a human called $(this name), $(this height) cm tall."
  }

  Human.Example() {
    [array]     someArray
    [integer]   someNumber
    [...rest]   arrayOfOtherParams

    echo "Testing $(var: someArray toString) and $someNumber"
    echo "Stuff: ${arrayOfOtherParams[*]}"

    # returning the first passed in array
    @return someArray
  }

  Human.Eat() {
    [string] food

    this eaten push "$food"

    # will return a string with the value:
    @return:value "$(this name) just ate $food, which is the same as $1"
  }

  Human.WhatDidHeEat() {
    this eaten toString
  }

  # this is a static method, hence the :: in definition
  Human::PlaySomeJazz() {
    echo "$(UI.Powerline.Saxophone)"
  }
}

# required to initialize the class
Type::Initialize Human

class:SingletonExample() {
  private integer YoMamaNumber = 150

  SingletonExample.PrintYoMama() {
    echo "Number is: $(this YoMamaNumber)!"
  }
}

# required to initialize the static class
Type::InitializeStatic SingletonExample
```

Now you can use both the `Human` and the `SingletonExample` classes:

```bash
# create an object called 'Mark' of type Human
Human Mark

# call the string.= (setter) method
$var:Mark name = 'Mark'

# call the integer.= (setter) method
$var:Mark height = 180

# adds 'corn' to the Mark.eaten array and echoes the output
$var:Mark Eat 'corn'

# adds 'blueberries' to the Mark.eaten array and echoes the uppercased output
$var:Mark : { Eat 'blueberries' } { toUpper }

# invoke the getter
$var:Mark

# invoke the method on the static instance of SingletonExample
SingletonExample PrintYoMama
```

Writing Unit Tests
==================

```
import util/test
```

![unit tests](https://raw.githubusercontent.com/niieani/bash-oo-framework/master/docs/unit.png "Unit tests for the framework itself")

Similarly to [Bats](https://github.com/sstephenson/bats), you can use the unit test module to test Bash scripts or any UNIX program.
Test cases consist of standard shell commands. Like Bats, Infinity Framework uses Bash's errexit (set -e) option when running test cases. Each test is run in a subshell, and is independent from one another. To quote from Bats:

> If every command in the test case exits with a 0 status code (success), the test passes. In this way, each line is an assertion of truth.

If you need to do more advanced testing, or need to be able to run your tests on shells other than bash 4, I'd still recommend Bats.

Example usage:

```bash
it 'should make a number and change its value'
try
    integer aNumber=10
    aNumber = 12
    test (($aNumber == 12))
expectPass

it "should make basic operations on two arrays"
try
    array Letters
    array Letters2

    $var:Letters push "Hello Bobby"
    $var:Letters push "Hello Maria"

    $var:Letters contains "Hello Bobby"
    $var:Letters contains "Hello Maria"

    $var:Letters2 push "Hello Midori,
                        Best regards!"

    $var:Letters2 concatAdd $var:Letters

    $var:Letters2 contains "Hello Bobby"
expectPass
```

Can you believe this is bash?! ;-)

Advanced Logging
================

```
import util/log
```

Here's an example of how to use the power of advanced logging provided by the Infinity Framework.

In every file you are logging from, you may name the logging scope (namespace).
If you won't do it, it'll be the filename, minus the extension.
It's better to name though, as filenames can conflict.
Thanks to scopes, you can specify exactly what and how you want to log.

```bash
namespace myApp

## ADD OUTPUT OF "myApp" TO DELEGATE STDERR
Log::AddOutput myApp STDERR

## LET'S TRY LOGGING SOMETHING:
Log "logging to stderr"
```

The above will simply print "logging to stderr" to STDERR.
As you saw we used the logger output called "STDERR". It is possible to create and register your own loggers:

```bash
## LET'S MAKE A CUSTOM LOGGER:
myLoggingDelegate() {
    echo "Hurray: $*"
}

## WE NEED TO REGISTER IT:
Log::RegisterLogger MYLOGGER myLoggingDelegate
```

Now, we can set it up so that it direct only logs from a specific function to the our custom logger output:

```bash
## WE WANT TO DIRECT ALL LOGGING WITHIN FUNCTION myFunction OF myApp TO MYLOGGER
Log::AddOutput myApp/myFunction MYLOGGER

## LET'S DECLARE THAT FUNCTION:
myFunction() {
    echo "Hey, I am a function!"
    Log "logging from myFunction"
}

## AND RUN:
myFunction
```

The above code should print:

```
Hey, I am a function!
Hurray: logging from myFunction
```

As you can see, logging automatically redirected the logger from our function from our previously registered STDERR to our more specifically defined MYLOGGER.
If you wish to keep logging to both loggers, you can disable the specificity filter:

```bash
Log::DisableFilter myApp
```

Now if we run the function ```myFunction```:

The output will be:

```
Hey, I am a function!
Hurray: logging from myFunction
logging from myFunction
```

We can be even more specific and redirect messages with specific *subjects* to other loggers, or mute them altogether:

```bash
## Assuming we're in the same file, let's reset first
Log::ResetAllOutputsAndFilters

Log::AddOutput myApp/myFunction MYLOGGER

myFunction() {
    echo "Hey, I am a function!"
    Log "logging from myFunction"
    subject="unimportant" Log "message from myFunction"
}
```

And let's change our custom logger a little, to support the subject:

```bash
myLoggingDelegate() {
    echo "Hurray: $subject $*"
}
```

Now when we run ```myFunction```, we should get:

```
Hey, I am a function!
Hurray:  logging from myFunction
Hurray: unimportant message from myFunction
```

To filter (or redirect) messages with subject ```unimportant``` within ```myFunction``` of ```myApp```'s file:

```bash
Log::AddOutput myApp/myFunction/unimportant VOID
```

To filter any messages with subject ```unimportant``` within ```myApp```'s file:

```bash
Log::AddOutput myApp/unimportant VOID
```

Or any messages with subject ```unimportant``` anywhere:

```bash
Log::AddOutput unimportant VOID
```

Now, running ```myFunction``` will print:

```
Hey, I am a function!
Hurray: logging from myFunction
```

How to use?
===========

1. Clone or download this repository. You'll only need the **/lib/** directory.
2. Make a new script just outside of that directory and at the top place this:

    ```shell
    #!/usr/bin/env bash
    source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/lib/oo-bootstrap.sh"
    ```

3. You may of course change the name of the **/lib/** directory to your liking, just change it in the script too.
4. Out-of-box you only get the import functionality.
   If you wish to use more features, such as the typing system, you'll need to import those modules as follows:

   ```shell
   # load the type system
   import util/log util/exception util/tryCatch util/namedParameters

   # load the standard library for basic types and type the system
   import util/class
   ```

5. To import the unit test library you'll need to ```import lib/types/util/test```.
   The first error inside of the test will make the whole test fail.

6. When using `util/exception` or `util/tryCatch` don't use ```set -o errexit``` or ```set -e``` - it's not necessary, because error handling will be done by the framework itself.

Contributing
============

Feel free to fork, suggest changes or new modules and file a pull request.
Because of limitations and unnecessary complexity of the current implementation we're currently brainstorming a 3.0 rewrite in #45.

The things that I'd love to add are:

* unit tests for all important methods
* port to bash 3 (preferably a dynamic port that imports the right file for the right version)
* a web generator for a single file version of the boilerplate (with an option to select modules of your choice)
* more functions for the standard library for primitive types (arrays, maps, strings, integers)
* useful standard classes are very welcome too

Porting to Bash 3
=================

The main challenge in porting to **bash 3** lays with creating a polyfill for associative arrays (probably by using every other index for the keys in an array), which are used by the type system. The other challenge would be to remove the global declarations (`declare -g`).

Acknowledgments
===============

If a function's been adapted or copied from the web or any other libraries out there, I always mention it in a comment within the code.

Additionally, in the making of the v1 of Bash Infinity I took some inspiration from object-oriented bash libraries:

* https://github.com/tomas/skull/
* https://github.com/domachine/oobash/
* https://github.com/metal3d/Baboosh/
* http://sourceforge.net/p/oobash/
* http://lab.madscience.nl/oo.sh.txt
* http://unix.stackexchange.com/questions/4495/object-oriented-shell-for-nix
* http://hipersayanx.blogspot.sk/2012/12/object-oriented-programming-in-bash.html

More bash goodness:

* http://wiki.bash-hackers.org
* http://kvz.io/blog/2013/11/21/bash-best-practices/
* http://www.davidpashley.com/articles/writing-robust-shell-scripts/
* http://qntm.org/bash
