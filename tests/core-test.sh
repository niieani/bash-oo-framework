#!/bin/bash

#oo:debug:enable

## usage ##
echo "[Creating Human Bazyli:]"

Object simpleObject

Human Bazyli
Bazyli.height = 100

echo "[Eating:]"

Bazyli.eat strawberries
Bazyli.eat lemon

echo "[Who is he?]"

Bazyli

# empty
Bazyli.name

# set value
Bazyli.name = "Bazyli Brzóska"

if Bazyli == Bazyli
then
    echo equals checking passed
fi

# set height
Bazyli.height = 170

# if you want to use a parametrized constructor, create an object and use the double tilda ~~ operator
Human Mambo ~~ Mambo Jumbo 150 960

echo $(Bazyli.name) is $(Bazyli.height) cm tall.

# throws an error
Bazyli = "house"

Array Letters
Array Letters2

Letters.add "Hello Bobby"
Letters.add "Hello Jean" "Hello Maria"
Letters2.add "Hello Frank" "Bomba"
Letters2.add "Dude,
              How are you doing?"

letters2=$(Letters2)
Letters.merge "${!letters2}"

letters=$(Letters)
for letter in "${!letters}"; do
    echo ----
    echo "$letter"
done

## or simply:
Letters.list

Letters.contains "Hello" && echo "This shouldn't happen"
Letters.contains "Hello Bobby" && echo "Bobby was welcomed"

Bazyli.example "one single sentence" two "and here" "we put" "some stuff"