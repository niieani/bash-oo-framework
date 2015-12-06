#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}/.." && pwd )/lib/oo-framework.sh"

minify() {
	@var filePath
	@var outputPath
	
	{
		local IFS=
		while read -r line
		do
			[[ $line != "System.Bootstrap" ]] && echo "$line"
		done < "$filePath" >> "$outputFile"
	}
}

build() {
	@var outputFile
	
	echo "#!/usr/bin/env bash" > "$outputFile"
	echo "# oo-framework version: $(git rev-parse --short HEAD)" >> "$outputFile"
	
	minify "$__oo__libPath"/oo-framework.sh "$outputFile"
	
	local file
	local path
	for file in "$__oo__libPath"/system/*.sh
	do
		# minify "$file" "$outputFile"
		cat "$file" >> "$outputFile"
		echo >> "$outputFile"
	done
}

build ./oo-framework.sh