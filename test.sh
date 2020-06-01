#!/bin/sh
#This is a shell script to automate building and testing with VHDL/GHDL
#It was written on OSX and should work on Linux

#Create variables
work=vhdl_source/work
if ! [ -z "$2" ]
then
	#Specify the "size" generic in the top-level module to be
	#the second command-line argument
	size="-gSIZE=$2"
fi

#Temporary extension to allow testing CORDIC stages
if ! [ -z "$3" ]
then
	index="-gSTAGES=$3"
fi

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
	ghdl-0.37/bin/ghdl -i --std=08 --workdir=$work vhdl_source/*.vhdl

	if [[ "$1" == *_tb ]]
		#Detected a substring indicating this is a test bench
	then
		ghdl-0.37/bin/ghdl -i --std=08 --workdir=$work vhdl_source/test_bench/$1.vhdl
	else
		echo "Synthesis is currently unsupported"

		#This is supposed to work but doesn't. The idea is to process the
	#VHDL code and create a netlist, a representation of all lowest-level
	#components and the connections between them, kind of like a circuit
	#diagram. The netlist can probably be used to generate a reversible
	#quantum circuit
	
	#ghdl-0.37/bin/ghdl --synth --ieee=standard --workdir=$work $1
	fi

	#This uses a makefile approach to update the analysis of modified files
	ghdl-0.37/bin/ghdl -m --std=08 --ieee=standard --workdir=$work $1 `echo $size` `echo $index`

	#Running the simulation doesn't do much of anything without test inputs
	#and outputs- this section is largely for testing, not synthesis
	ghdl-0.37/bin/ghdl -r --std=08 --ieee=standard --workdir=$work $1 `echo $size` `echo $index`
else
	#Specify top-level module as a command line argument by entity name
	echo "ERROR: Need to provide a top-level module entity name"
fi