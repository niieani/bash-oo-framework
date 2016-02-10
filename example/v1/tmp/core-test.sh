## usage ##
echo "[Creating Human Bazyli:]"

Object simpleObject

Human Bazyli
Bazyli.height = 100

echo "[Eating:]"

Bazyli.Eat strawberries
Bazyli.Eat lemon

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

Letters.Add "Hello Bobby"
Letters.Add "Hello Jean" "Hello Maria"
Letters2.Add "Hello Frank" "Bomba"
Letters2.Add "Dude,
              How are you doing?"

letters2=$(Letters2)
Letters.Merge "${!letters2}"

letters=$(Letters)
for letter in "${!letters}"; do
    echo ----
    echo "$letter"
done

## or simply:
Letters.List

Letters.Contains "Hello" && echo "This shouldn't happen"
Letters.Contains "Hello Bobby" && echo "Bobby was welcomed"

Bazyli.Example "one single sentence" two "and here" "we put" "some stuff"

Singleton.PrintYoMama
Singleton = "some value"
Singleton

Singleton.YoMamaNumber
Singleton.YoMamaNumber ++
Singleton.YoMamaNumber
Singleton.YoMamaNumber._storedVariableName

ExtensionTest specialVar
specialVar = "testing setter"

echo "Color Test: $(Color.Blue)Hello $(Color.White)There$(Color.Default)"