#!/usr/bin/env bash
################################################
# 
# AUTHOR        godbod
# 
# DESCRIPTION : IntervalTree class
#               The interval tree contains functionalities
#               like inserting, printing and displaying the 
#               overlapping edges
# 
################################################

# source "$( cd "$( dirname "${BASH_SOURCE[0]%/}" )" && pwd )/lib/oo-bootstrap.sh"

import util/class util/namedParameters

class:IntervalTree() {

   public array intervals

   ##############################################
   IntervalTree.SearchOverlaps() {
      echo ''
      echo 'IntervalTree.SearchOverlaps'
      [string] interval_s
      local orr=($(echo $interval_s))
      local arr=($())
      j=0
      k=0

      for i in `this intervals toString`; do
         if [ $j -lt 2 ]; then
            arr[$k]=$i
            # echo ${arr[@]}
            j=$(($j + 1))
            k=$(($k + 1))
         else
            j=0
         fi
      done 

      # Testing...
      # for i in ${arr[@]}; do
      for i in `seq 1 ${#arr[@]}`; do
         j=$(($i * 2))
         if [ $j -le ${#arr[@]} ]; then
            # echo $j
            # echo ${orr[0]} ${orr[1]}
            r=`$var:interval Overlaps "${orr[0]} ${orr[1]}" "${arr[$(($j - 2))]} ${arr[$(($j - 1))]}"`
            echo $r
         fi
      done
   }

   ##############################################
   IntervalTree.Overlaps() {
      echo ''
      echo 'IntervalTree.Overlaps'
      [string] interval_i
      [string] interval_j  

      x=($(echo $interval_i))
      y=($(echo $interval_i))
      y=${y[1]}
      z=($(echo $interval_j))
      t=($(echo $interval_j))
      t=${t[1]}

      echo '(' $x $y ')' '<-?->' '(' $z $t ')'

      # overlap detection
      if [ $x -le $t -a $z -le $y ]; then
            echo 'true'
      else
         echo 'false'
      fi
   }

   ##############################################
   IntervalTree.InsertInterval() {
      echo ''
      echo 'IntervalTree.InsertInterval'
      [string] interval_i
      echo "$interval_i provided"
      this intervals push "$interval_i"
   }

   ##############################################
   IntervalTree.PrintIntervals() {
      echo ''
      echo 'IntervalTree.PrintIntervals'
      this intervals toString
   }
}
