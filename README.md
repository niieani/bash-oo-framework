Bash Infinity Framework
=======================

This is a boilerplate framework for writing tools using **bash**.
It's highly modular and lightweight, while managing to implement some concepts from C#, Java or JavaScript into bash. 
The Infinity Framework is also plug & play: include it at the beginning of your existing script to get the error handling benefits, and start using other features gradually.

Disclaimer: Tested only with **bash 4.3**, but should be easy to port to earlier versions.

Main features
=============

* automatic error handling with exceptions
* throwing custom **Exceptions**
* **try-catch** implementation
* *import* keyword for clever sourcing of scripts à la *require-js*
* handy aliases for **colors** and **powerline** characters to increase readability in the output of your scripts
* well-formatted, colorful **error logging** to *stderr*
* type system for *object-oriented* scripting (*optional* module)
* basic types, such as **Array** or **String** with many useful functions (*optional* module)
* unit test library (*optional* module)

Error handling with exceptions and ```throw```
==============================================

One of the highlight features is error handling that should work out of the box. If the script generates an error it will break and display a call stack:

![example call stack](https://raw.githubusercontent.com/niieani/bash-oo-framework/master/docs/exception.png "Example Call Stack")

You may force an error by ```throw```ing your own Exception:

```bash
throw "The hard disk is not connected properly!"
```

It's useful for debugging, as you'll also get the call stack if you're not sure where the call is coming from.

*Exceptions* combined with *try & catch* give you safety without having to run with **-o errexit**.
If you do something wrong, you'll get a detailed exception, highlighting the command where it went wrong in the line from the source, along with a backtrace the script will be halted with the option to continue of break.
On the other hand if you expect a part of block to fail, you can wrap it in a try block, and handle the error inside a catch block. 
   
Using ```import```
==================

You may use ```import``` to load your own files. 
It will ensure they're only loaded once. You may either use a relative path from the file you're importing, a path relative to the file that first included the framework, or an absolute path. ```.sh``` suffix is optional.
You can also load all the files inside of a directory by simply including the path to that directory instead of the file.

Using ```try & catch```
=======================

Simple usage:

```bash
try {
    cp ~/test ~/test2
} catch {
    echo "The hard disk is not connected properly!"
    echo "Caught Exception:$(UI.Color.Red) $__EXCEPTION__ $(UI.Color.Default)"
    echo "File: $__EXCEPTION_SOURCE__, Line: $__EXCEPTION_LINE__"
}
```

If any command fails (i.e. returns anything else than 0) in the ```try``` block, the system will automatically start executing the ```catch``` block.
Braces are optional for the ```try``` block, but required for ```catch``` if it's multiline.

Note: ```try``` is executed in a subshell, therefore you cannot assign any variables inside of it.

Using Logging, Colors and Powerline Emoji
=========================================

```bash
echo "$(UI.Color.Blue)I'm blue...$(UI.Color.Default)"
# show all debug messages below log level 2
Debug.Log.Enable 2
# write to debug log at level 1
Debug.Log 1 "Play me some Jazz, will ya? $(UI.Powerline.Saxophone)"
# disable visible logging
Debug.Log.Disable

Debug.Write "This will be printed to STDERR, no matter what logging level we're at."
```

Both the colors and the powerline characters fallback gracefully on systems that don't support them.
To see powerline, you'll need to use a powerline-patched font though.

For the list of available colors and emoji's take a look into [lib/system/ui.sh](https://github.com/niieani/bash-oo-framework/blob/master/lib/system/01_ui.sh).
Fork and contribute more!

Writing Unit Tests
==================

![unit tests](https://raw.githubusercontent.com/niieani/bash-oo-framework/master/docs/unit.png "Unit tests for the framework itself")

Example usage (taken from tests/run-tests.sh):
   
```bash
it 'should make a number and change its value'
try
    Number aNumber = 10
    aNumber = 12
    aNumber.Equals 12
finish

it "should make basic operations on two arrays"
try
    Array Letters
    Array Letters2

    Letters.Add "Hello Bobby"
    Letters.Add "Hello Maria"
    
    Letters.Contains "Hello Bobby"
    Letters.Contains "Hello Maria"

    Letters2.Add "Hello Midori,
                  Best regards!"

    lettersRef=$(Letters)
    Letters2.Merge "${!lettersRef}"

    Letters2.Contains "Hello Bobby"
finish
```

Can you believe this is bash?! ;-)

Named parameters in functions
=============================

Instead of using the unhelpful ```$1```, ```$2``` and so on within functions to accessed the passed values, you may write:

```bash
yourGreatFunction() {
    @mixed firstParam
    @mixed secondParam
    @String someString
    l=4 @Array someArray
    @params nameForYourParam
    
    ## your function goes here ##
    }
```

The system will automatically map:
 * *$1* to *$firstParam*
 * *$2* to *$secondParam*
 * If using the Type system described below, a String object will be created from *$3* (in the future will implement passing by reference)
 * *$someArray* will be an array of params with values from $4 till $8
 * *$nameForYourParam* will be a bash array containing all the following params


Using types
===========

```bash
(
    # create an object someString of type String and immediately call it's setter with a parameter
    String someString = "My 123 name is Bazyli"
    
    # prints Match nr. 0 for the said regex:
    someString.RegexMatch '([\d]+) name' 0
    
    # prints a sanitized version of the variable:
    someString.GetSanitizedVariableName
    
    # calls the getter - here it prints the value
    someString
)
# someString doesn't exist here
```

If you don't want the objects to fall through or collide, use them in a subshell.
For more, take a look at the examples inside of the unit tests above.


Writing your own classes
========================

It's really simple and straight-forward, like with most object-oriented languages.

Keywords for definition:

* **class:YourName()** - defining a class
* **static:YourName()** - defining a static class (singleton types)

Keywords to use inside of the class definition:

* **extends SomeClass** - As the name suggests - inherit from a base class
* **method ClassName::FunctionName()** - Use for defining methods that have access to *$this*
* **static ClassName.StaticFunctionName()** - static methods inside of non-static classes
* **public Type yourProperty** - define public properties (works in all types of classes)
* **private Type yourProperty** - as above, but accessible only for internal methods
* **$this** - Contains the name of the instance and makes it possible to call it's own methods or access it's own properties

If you want to call a base method that you overrode, just call it with the name of the base instead of **$this** and with ```::``` before method's name, instead of ```.```.

**IMPORTANT: If you don't load the classes with ```import``` you need to call ```Type.Load``` after you declare your classes. However, the order of loading will not be the order in which they were declared, so you may need to call it after every class definition so you may to inherit from previously loaded classes.** 

Here's an example that shows how to define your own classes:

```bash
import lib/types/base

class:Animal() {
    extends Object

    method Animal::__getter__() {
        echo "That is the animal"
    }
} 

class:Human() {
    extends Animal

    public Number Height
    public Array Eaten
    public String Name

    method Human::__toString__() {
        echo "I'm a human called $($this.Name), $($this.Height) cm tall."
    }

    method Human::__getter__() {
        $this.__toString__
    }
    
    method Human::CallBaseGetter() {
        Animal::__getter__
    }

    method Human::Eat() {
        @mixed food
                
        $this.Eaten.Add "$food"
        
        echo "$this is eating $food, which is the same as $1"
    }
    
    method Human::WhatDidYouEat() {
        $this.Eaten.List
    }

    method Human::Example() {
        @Array      someArray
        @Number     someNumber
        @params     arrayOfOtherParams
                
        echo "Testing $someArray and $someNumber"
        echo Stuff: "${arrayOfOtherParams[*]}"
    }

    method Human::__equals__() {
        echo 'TODO: Checking if $this equals $1'
    }

    method Human::__constructor__() {
        @String name
        @Number height
                
        $this.Name = "$name"
        $this.Height = "$height"
        
        Log.Write "Hello, I am the constructor! You have passed these arguments [ $@ ]"
    }
        
    static Human.PlaySomeJazz() {
        # this is a static method
        echo "$(UI.Powerline.Saxophone)"
    }
}

static:SingletonExample() {
    extends Var

    Number YoMamaNumber = 150

    Singleton::__constructor__() {
        echo "Yo Yo. I'm a singleton. Meaning. Static. Yo."
        Singleton = "Yo Mama!"
    }

    Singleton.PrintYoMama() {
        ## prints the stored value, which is set in the constructor above
        echo "$(SingletonExample) Number is: $(SingletonExample.YoMamaNumber)!"
    }
}
```

How to use?
===========

1. Clone or download this repository. You'll only need the **/lib/** directory.
2. Make a new script just outside of that directory and at the top place this:

    ```shell
    #!/usr/bin/env bash
    source "$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )/lib/oo-framework.sh"
    ```

3. You may of course change the name of the **/lib/** directory to your liking, just change it in the script too.
4. Out-of-box you'll get the core functionality described above, such as exceptions, try&catch, and so on.
   However, if you wish to add more features, like enable the typing system, you'll need to import those modules:
   
   ```shell
   # load the type system
   import lib/type-core
   
   # load some basic types, such as Var, Array or String
   import lib/types/base
   ```

5. To import the unit test library you'll need to ```import lib/types/util/test```.
   The first error inside of the test will make the whole test fail.
   
6. Don't use ```set -o errexit``` or ```set -e``` - it's not necessary, because error handling is done by the framework itself.  

Acknowledgments
===============

If a function's been adapted or copied from the web or any other libraries out there, I always mention it in a comment within the code.

Additionally, I took some inspiration from other object-oriented bash libraries:

* https://github.com/tomas/skull/
* https://github.com/domachine/oobash/
* https://github.com/metal3d/Baboosh/
* http://sourceforge.net/p/oobash/
* http://lab.madscience.nl/oo.sh.txt
* http://unix.stackexchange.com/questions/4495/object-oriented-shell-for-nix
* http://hipersayanx.blogspot.sk/2012/12/object-oriented-programming-in-bash.html

More bash goodness:

* http://kvz.io/blog/2013/11/21/bash-best-practices/
* http://www.davidpashley.com/articles/writing-robust-shell-scripts/
* http://qntm.org/bash
