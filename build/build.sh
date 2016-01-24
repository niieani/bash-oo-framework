#!/usr/bin/env bash

## BOOTSTRAP ##
# source "$( cd "${BASH_SOURCE[0]%/*}/.." && pwd )/lib/oo-bootstrap.sh"
# import lib/system/oo
declare -g __oo__libPath="$( cd "${BASH_SOURCE[0]%/*}/../lib" && pwd )"

concat() {
	local outputPath="$1"
	local -a inputFiles=("${@:2}")

	local blob
	local file

	for file in "${inputFiles[@]}"
	do
		blob+=$'\n'
		blob+=$(<"$file")
	done

	eval "main() { ${blob} " $'\n' " }"

	[[ ! -z "${replaceAliases+x}" ]] && main

	local body=$(declare -f main)
	body="${body#*{}" # trim start definition
	body="${body%\}}" # trim end definition

	printf %s "#!/usr/bin/env bash" > "$outputPath"

	while IFS= read -r line
	do
		## NOTE: might mess up herestrings that start with spaces
		[[ "$line" == '    '* ]] && line="${line:4}"
		[[ "$line" == 'namespace '* ]] && continue
	  printf %s "$line" >> "$outputPath"
		printf "\n" >> "$outputPath"
	done <<< "$body"

	# printf %s "#!/usr/bin/env bash${body}" > "$outputPath"
}

concat "out-$(git rev-parse --short HEAD).sh" "$__oo__libPath"/oo-bootstrap.sh "$__oo__libPath"/system/*.sh "$__oo__libPath"/system/oo/*.sh


# evalIntoMain
# declare -f main > out-$(git rev-parse --short HEAD).sh

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
# 	minify "$__oo__libPath"/oo-bootstrap.sh "$outputFile"
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

# build ./oo-bootstrap.sh
