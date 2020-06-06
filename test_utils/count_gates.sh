#!/bin/sh
cnots=$(grep -ow work.cnot $1 | wc -l)
ccnots=$(grep -ow work.ccnot $1 | wc -l)
peres=$(grep -ow work.peres $1 | wc -l)
echo "File ${1} used:"
echo "${cnots} cnots"
echo "${ccnots} ccnots"
echo "${peres} peres gates"