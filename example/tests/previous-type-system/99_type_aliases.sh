## INFO: aliases need to be loaded from outside, before the types are imported
## unfortunately types cannot import them, because they don't unfold in their scope

## KEYWORDS ##
alias extends="Type.Extend"

# it has to be reversed with ! and logical OR because otherwise we get an exception...
alias method="! [[ -z \$instance || \$instance = false ]] ||"
alias static="! [[ -z \$instance || \$instance = false ]] ||"

alias methods="if [[ -z \$instance ]] || [[ \$instance = false ]]; then "
alias ~methods="fi"

alias statics="if [[ -z \$instance ]] || [[ \$instance = false ]]; then "
alias ~statics="fi"

# it has to be reversed with ! and logical OR because otherwise we get an exception...
alias public="[[ \$instance != true ]] || __private__=false "
alias private="[[ \$instance != true ]] || __private__=true "
