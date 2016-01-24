#!/usr/bin/env bash

## BOOTSTRAP ##
NO_UNICODE=true source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

## MAIN ##

import lib/type-core
import lib/types/base
import lib/types/ui

## YOUR CODE GOES HERE ##

## NAME THE REFERENCE TO LOGGING FOR THIS FILE 
## (if you won't do it it'll be the filename without the extension)
## DO THIS IN EVERY FILE YOU WANT TO USE LOGGING FROM
## TO BE ABLE TO SPECIFY EXACTLY WHAT AND HOW YOU WANT TO LOG
namespace myApp

## ADD OUTPUT OF "myApp" TO STDERR
Log::AddOutput myApp STDERR

## LET'S TRY LOGGING SOMETHING:
Log "logging to stderr"

## LET'S MAKE A CUSTOM LOGGER:
myLoggingDelegate() {
	echo "Hurray: $*"
}

## WE NEED TO REGISTER IT:
Log::RegisterLogger MYLOGGER myLoggingDelegate

## WE WANT TO DIRECT ALL LOGGING WITHIN FUNCTION myFunction OF myApp TO MYLOGGER
Log::AddOutput myApp/myFunction MYLOGGER

## LET'S DECLARE THAT FUNCTION:
myFunction() {
	echo "Hey, I am a function!"
	Log "logging from myFunction"
}

## AND RUN:
myFunction

## IT SHOULD PRINT:
	## Hey, I am a function!
	## Hurray: logging from myFunction

## As you can see, logging automatically redirected the logger from our function from our previously registered STDERR to our more specifically defined MYLOGGER
## If you wish to keep logging to both loggers, you can disable the specificity filter:
Log::DisableFilter myApp

## Now if we run the function:
myFunction

## The output will be:
	## Hey, I am a function!
	## Hurray: logging from myFunction
	## logging from myFunction

## We can also be even more specific and redirect messages with specific subjects to other loggers or mute them
## Let's reset first
Log::ResetAllOutputsAndFilters

Log::AddOutput myApp/myFunction MYLOGGER

myFunction() {
	echo "Hey, I am a function!"
	Log "logging from myFunction"
	subject="unimportant" Log "message from myFunction"
}

## and let's change our custom logger a little, to support the subject:
myLoggingDelegate() {
	echo "Hurray: $subject $*"
}

## Now when we run:
myFunction

## Will print:
	## Hey, I am a function!
	## Hurray:  logging from myFunction
	## Hurray: unimportant message from myFunction

## To filter messages with subject "unimportant" within myFunction of myApp's file:
Log::AddOutput myApp/myFunction/unimportant VOID
## or any messages with subject "unimportant" within myApp's file:
Log::AddOutput myApp/unimportant VOID
## or any messages with subject "unimportant" anywhere
Log::AddOutput unimportant VOID

## Now when we run:
myFunction

## Will print:
	## Hey, I am a function!
	## Hurray: logging from myFunction


Log::AddOutput myApp INFO
Log::DisableFilter oo/func
Log::AddOutput oo/func DEBUG
Log::AddOutput oo/func/creation CUSTOM

func() {
	Log from-func
	
	subject=creation Log "from func with subject"
}

Log root
func