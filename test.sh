#!/bin/sh
#This is a shell script to automate building and testing with VHDL/GHDL
#It was written on OSX and should work on Linux

#Create variables
work=vhdl_source/work
ghdl=ghdl-master/build/bin/ghdl
top=$1
shift

#Create generics
gens=''
for arg
do gens="${gens} -g${arg}"
done

#Flag string used to name netlists
flags=$(echo $gens | sed 's/\-g//g' | tr ' ' '_' | tr -d '=')

#The first command-line argument is expected to be the name of the
#top-level entity in your design- for example, cnot_tb (a test bench) is
#the top-level entity used to test the cnot design
if ! [ -z "$1" ]
then

	#Right now, these three commands import all vhdl sources,
	#analyzes the designs with a makefile approach, and
	#elaborates and runs the specified simulation

	#Import all sources- this has the drawback of requiring source files
	#to be parseable (error-free) even if they are not in the design
	#hierarchy
	$ghdl -i --std=08 --workdir=$work vhdl_source/*.vhdl

	if [[ ${top} == *_tb ]]
		#Detected a substring indicating this is a test bench
	then
		$ghdl -i --std=08 --workdir=$work vhdl_source/test_bench/$top.vhdl
		#This uses a makefile approach to update the analysis of modified files
		$ghdl -m --std=08 --ieee=standard --workdir=$work $top

		#Running the simulation doesn't do much of anything without test inputs
		#and outputs- this section is largely for testing, not synthesis
		$ghdl -r --std=08 --ieee=standard --workdir=$work $top `echo $gens`
	else
		#This uses a makefile approach to update the analysis of modified files
		$ghdl -m --std=08 --ieee=standard --workdir=$work $top
		#Synthesize top-level module and output netlist
		$ghdl --synth `echo $gens` --std=08 --workdir=$work $top > netlists/${top}_${flags}.net
		#Generate gatecount for netlist automatically
		sh test_utils/count_gates.sh netlists/${top}_${flags}.net > netlists/${top}_${flags}.gc
	fi
else
	#Specify top-level module as a command line argument by entity name
	echo "ERROR: Need to provide a top-level module entity name"
fi