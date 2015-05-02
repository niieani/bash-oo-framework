shopt -s expand_aliases

alias try="( set -e; 
		   trap \"saveThrowLine \${LINENO}\" ERR;"
alias catch=" ); [[ \$? -eq 0 ]] || "

saveThrowLine() {
	export THROW_LINE=$1
}
