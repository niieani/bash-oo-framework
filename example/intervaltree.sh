#!/usr/bin/env bash
################################################
# 
# AUTHOR        godbod
# 
# DESCRIPTION : Testing the intervals after filling
#               the interval tree
#               Printing the intervals inside the tree
# 
################################################

source "$( cd "$( dirname "${BASH_SOURCE[0]%/}" )" && pwd )/../lib/oo-bootstrap.sh"

# dependency
import IntervalTree/Intervaltree

# required to initialize the class
Type::Initialize IntervalTree

# create an object called 'interval' of type IntervalTree
IntervalTree interval

# Insertion is made by calling the function InsertInterval "coordinate_start coordinate_end edge_Id"
$var:interval InsertInterval "0 2 e0"
$var:interval InsertInterval "1 3 e1"
$var:interval InsertInterval "1 4 e2"
$var:interval InsertInterval "5 3 e3"
$var:interval InsertInterval "1 7 e4"

# SearchOverlaps will find the overlapping intervals and display them
$var:interval SearchOverlaps "1 2"
$var:interval SearchOverlaps "5 6"

# Print will display all the intervals
$var:interval PrintIntervals
