#!/usr/bin/env bash

## BOOTSTRAP ##
# source "$( cd "${BASH_SOURCE[0]%/*}/.." && pwd )/lib/oo-framework.sh"
# import lib/system/oo
declare -g __oo__libPath="$( cd "${BASH_SOURCE[0]%/*}/../lib" && pwd )"

evalIntoMain() {
	local blob
	local file
	
	for file in "$__oo__libPath"/oo-framework.sh "$__oo__libPath"/system/*.sh "$__oo__libPath"/system/oo/*.sh
	do
		blob+=$'\n'
		blob+=$(<"$file")
	done

	eval "main() { ${blob} " $'\n' " }"
}

evalIntoMain
declare -f main > out-$(git rev-parse --short HEAD).sh

# minify() {
# 	[string] filePath
# 	[string] outputPath
#
# 	{
# 		local IFS=
# 		while read -r line
# 		do
# 			[[ $line != "System::Bootstrap" ]] && echo "$line"
# 		done < "$filePath" >> "$outputFile"
# 	}
# }
#
#
# build() {
# 	[string] outputFile
#
# 	echo "#!/usr/bin/env bash" > "$outputFile"
# 	echo "# oo-framework version: $(git rev-parse --short HEAD)" >> "$outputFile"
#
# 	minify "$__oo__libPath"/oo-framework.sh "$outputFile"
#
# 	local file
# 	local path
# 	for file in "$__oo__libPath"/system/*.sh
# 	do
# 		# minify "$file" "$outputFile"
# 		cat "$file" >> "$outputFile"
# 		echo >> "$outputFile"
# 	done
# }

# build ./oo-framework.sh
