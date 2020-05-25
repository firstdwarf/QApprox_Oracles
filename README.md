This repository contains VHDL implementations of some heavily classical quantum oracles and some utilities designed to sythesize and simulate reversible designs using GHDL, an open-source VHDL simulation and synthesis.

------------------------------------------------------------------------
##VHDL

If you're new to VHDL, it's an industry-standard hardware description language (HDL) that allows programmatic description of real hardware behavior and attachments. Using hierarchical design, complex logic behavior may be constructed from simple low-level designs and user-created building blocks. See the README in the vhdl_source directory for more information. In particular, the unique demands of reversibility and quantum computation require careful adherance to several principles, and my ititial attempts may be found there.

------------------------------------------------------------------------
##GHDL

Testing and synthesizing vhdl designs requires some sort of tool, and I've used GHDL for this project. Prebuilt GHDL binaries and instructions for building your own can be found here:

https://ghdl.readthedocs.io/en/latest/getting/Releases.html

I've been using the mcode OSX version. Instructions for running GHDL commands may be found on the same website.

------------------------------------------------------------------------
##Basic GHDL Use

Analyzing and simulating with GHDL requires specifying a top-level module, the design at the head of the hierarchical food chain. Most designs in this repository have associated test bench files located in the test_bench directory. Since these files don't just describe simple hardware, they are not synthesizeable (capable of being converted to actual circuit descriptions), but they are convenient wrappers to allow simple testing features, like reading/writing to/from files during simulation to check and record test cases. Invoking GHDL with these test benches as the top-level module allows for fast and efficient testing.

------------------------------------------------------------------------
##Convenient Automation

I've included a shell script written for OSX that automates the execution of several GHDL commands. Invoking it to test the construction of a sixteen-bit reversible adder with no input carry that computes its value onto ancillae (a design in this repository) may be done as follows: ./test.sh add_scratch_tb 16

You can check my shell script for examples of command sequences.

------------------------------------------------------------------------
##Testing

Finally, the automatic tests require an input and output file to read/write from. The input file is used to specify test inputs and their corresponding expected output. The output file reports test results and lists any errors that occurred- a file that doesn't mention errors means there were none. While these files are unimaginatively named input.txt and output.txt, respectively, the desired file names may be set on a case-by-case basis in test bench files. I've also included a c++ program that can generate test vectors for simple binary operations and write them to an input.txt file. Compiling this program and running it with the -h option will provide more information, as will reading through the source code.