#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}/.." && pwd )/lib/oo-bootstrap.sh"

minify() {
	[string] filePath
	[string] outputPath
	
	{
		local IFS=
		while read -r line
		do
			[[ $line != "System::Bootstrap" ]] && echo "$line"
		done < "$filePath" >> "$outputFile"
	}
}

build() {
	[string] outputFile
	
	echo "#!/usr/bin/env bash" > "$outputFile"
	echo "# oo-framework version: $(git rev-parse --short HEAD)" >> "$outputFile"
	
	minify "$__oo__libPath"/oo-bootstrap.sh "$outputFile"
	
	local file
	local path
	for file in "$__oo__libPath"/system/*.sh
	do
		# minify "$file" "$outputFile"
		cat "$file" >> "$outputFile"
		echo >> "$outputFile"
	done
}

build ./oo-bootstrap.sh