## What are HDLs?

Hardware description languages, or HDLs, are used to describe hardware designs and connections for prototyping and implementing integrated circuits. Both VHDL and Verilog are HDLs originially developed in the 1980s that work at the register transfer level, allowing specification of circuits at a higher level than the gate level. Sythesis and simulation tools can parse simple programming constructs into hardware level descriptions, dramatically simplifying the implementation of memory, timers, sequential logic, basic ALU operations, and more. Fundamentally, the toolchain allows designers to specify their behavior in many different ways, allowing a more natural construction of ideas. For example, a multiplexer may be described by a case statement, or strings of bits may be interpreted and referred to as signed or unsigned integers, allowing for simple control-flow-based descriptions of complex timing or counting circuitry.

## Why use HDLs?

HDL toolchains are an invaluable component of hardware design or implementation for several reasons. First, synthesis and simulation allows for generating low-level implementation details of a high-level hierarchical design. For example, a gate-level description of a complex ALU may be obtained from a few dozen statements in an HDL.

Second, HDLs inherently support complex timing and sequential logic. By using special processes activated by changes in some signal, HDLs can synthesize statements to execute concurrently exactly when some condition is met, such as a rising edge of a clock signal.

Third, the resulting description may be verified and simulated classically using traditional software toolchains or executed on specialized Field Programmable Gate Arrays (FPGAs). FPGAs "execute" compiled HDL designs to reconfigure themselves to implement the intended design. This turns an FPGA into a reusable and easily configurable prototype of an integrated circuit.

For this reason, FPGAs and HDLs also see extensive use in research environments. Dedicated hardware descriptions run on an FPGA are an extremely cost-effective, simple, and fast way to incorporate hardware in an experiment. For example, modern quantum platform or architecture researchers commonly use FPGAs to implement and verify classical control hardware for quantum systems.

## Working with HDLs

Fundamentally, HDLs describe physical hardware connections instead of software execution steps. One major consequence of this is that HDL statements are generally executed concurrently. This inherent support for parallelism can make it much easier to define a schematic.

Next, while HDLs allow high-level behavioral descriptions of hardware implementations, more abstract descriptions may lead to more unpredictable or non-optimal low-level implementations. Put simply, bad HDL code may lead to bad hardware implementations without much indication that the design is suboptimal. The more intent and understanding a designer has, the better an implementation may end up.

## VHDL vs Verilog

VHDL features a strong type system and verbose implementations, making it much easier to debug and more self-documenting than Verilog. In contrast, Verilog features a more C-like syntax that can be more comfortable for beginners. Several toolchains exist that allow conversion between descriptions to some degree and both languages are IEEE standard, so much of the choice of language comes down to personal preference.

A third language called SystemVerilog deserves a mention- it's an even-higher level extension to verilog that bridges the gap between description and verification languages. I haven't used Verilog or SystemVerilog and know very little about the latter.

## Why use HDLs for quantum?

For my purposes, I needed an easily classically-simulable open-source toolchain that allowed me to process data at the bit and register transfer level. Traditional HDL synthesis also allows me to expand hierarchical designs to get resource estimates and implementation details for more complex designs. Quantum circuits are currently described at the gate level and feature both concurrent and sequential elements with precise timing constraints.

One of the main advantages of HDLs is allowing designers to use more complex ideas that can then be translated and synthesized down to the gate level, an ability that is sorely lacking in many quantum circuit design flows. Expanding simple binary operations between qubits or registers into complex multi-gate functional blocks would dramatically simplify workflow. I believe that both understanding and controlling how a language synthesizes to real hardware are crucial, especially since there are many different ways to implement traditional combinational circuits reversibly.

Perhaps the biggest challenge to HDL development for quantum computation lies in the nature of computation-in-memory. Describing sequential processing of a qubit concurrently or combinationally requires distinguishing each stage of the qubit's processing separately. Describing parallel statements with purely sequential logic is similarly difficult.

## Resources
Introduction to HDLs: https://www.sciencedirect.com/science/article/pii/B9780128000564000042

Example VHDL code: https://en.wikipedia.org/wiki/VHDL
https://vhdlguide.readthedocs.io/en/latest/vhdl/dex.html#

Verilog examples: http://www.asic-world.com/examples/verilog/index.html

Reference manual for VHDL: https://ieeexplore.ieee.org/document/4772740