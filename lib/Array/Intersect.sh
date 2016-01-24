import util/namedParameters util/type

Array::Intersect() {
  @required [array] arrayA
  @required [array] arrayB

  array intersection

  # http://stackoverflow.com/questions/2312762/compare-difference-of-two-arrays-in-bash
  for i in "${arrayA[@]}"
  do
    local skip=
    for j in "${arrayB[@]}"
    do
      [[ "$i" == "$j" ]] && { skip=1; break; }
    done
    [[ -n $skip ]] || intersection+=("$i")
  done

  @get intersection
}
