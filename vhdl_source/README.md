This directory contains VHDL source files, and if you're not familiar with VHDL, it's not going to make much sense- I'll include a brief overview here before discussing how I've made things "reversible" below.

------------------------------------------------------------------------
## Basic VHDL: Entity and Architecture

Most files here have two sections- entity and architecture. The entity represents a hierarchical circuit module and describes its inputs and outputs. Most inputs and outputs in these files are fundamentally of type standard_logic, which may be logic 0, logic 1, or several other less common cases, like uninitialized (U), high impedance (Z), etc. Usually, several standard_logic inputs may be combined into a bundle of type standard_logic_vector, an array of standard_logic variables. One especially important input is a generic, a more traditional programming variable. Details about this last type are found later in this document.

The architecture section describes the actual connections and logic that links inputs to outputs within an entity. First, you declare any temporary signals (types that are generally used to label intermediate inputs and outputs within a circuit) and define any components you'd like to use within your design- these are black box entities you or someone else has already created.

Within the architecture section, the keyword "begin" indicates the end of the preliminary declarations and the beginning of the architecture description. One important thing to be aware of is that in VHDL, assignment statements within the architecture are CONCURRENT, not sequential! That means that making an assignment to some signal, input, or output describes a permanent wired connection between those components. To see basic examples of VHDL syntax, I'd look at .vhdl files in this repository that simulate basic quantum gates, like cnot, ccnot, and peres. The cnot gate has been commented very explicitly for this purpose. For more complex examples, check the add_in_place and add_scratch .vhdl files, although I'd finish reading this document before looking at the last two.

One of the advantages of using VHDL is that it can automatically synthesize and simulate more complex circuit components based on a designer's intent using varied logic operators. You can use basic logic operations like AND, OR, NOT, and more, but you can also add, subtract, multiply, divide, take modulo, interpret std_logic_vectors as bits or numbers when convenient, switch only on certain parts of clock cycles, and way more. You can also include "process" statements within an architecture that contain SEQUENTIAL statements instead of concurrent. This allows the use of more complex programming constructs, including control flow, but it is much more unpredictable and prone to inserting memory elements like latches or flip flops to implement a particular design.

------------------------------------------------------------------------
## Classical Simulation via Test Benches

A test bench file can wrap a component entity for simulation. The test bench has no entity inputs and outputs since it's not a component (although it may have generics). The bench programmatically evaluates the design for specific cases and compares it to expected design. The tools used in test benches are generally not synthesizeable and they are absolutely not reversible. This is only done for classical simulation of components. Test benches may use hard-coded input and output patterns (see the cnot and ccnot test benches) or read in from files (see basically any other bench). For now, all input and output filenames are the same but may be changed without consequence. There's most likely a way to make a function that does this instead of just a simple file, so I might update this system eventually.

------------------------------------------------------------------------
## Tool Constraints for Reversibility

To maintain reversibility, I don't use any complex vhdl features. Instead, I just describe combinations of fundamental reversible gates or other components I've created. By doing so, I maintain more direct control of the actual hardware and prevent the inclusion of non-reversible elements. That means you won't find process statements or complex VHDL operators here. Instead, I rely on instantiating my reversible components and assigning component and entity inputs and outputs to temporary signals that are only read to and read from once.

You may notice that the "reversible" fundamental gates are described irreversibly within their VHDL files- the descriptions of these gates are only used for classical simulation and cannot be used for execution on real quantum simulators. Rather, their reversible equivalents should replace them.

------------------------------------------------------------------------
## Generate Statements and Generics

I also have access to "for... generate" blocks, or generate statements. These statements describe patterns of circuit components that generate based on some control flow. This is extremely powerful because it allows a simple blueprint to be reused to define and construct different components based on some variable input. Here, the generic input finds its use- by specifying some integer generic at sythesis/compile time, a component may be created with some desired quality like input size or level of approximation. This adds tremendous modularity to VHDL code.

------------------------------------------------------------------------
## Future Directions: Synthesis

One step in the standard VHDL toolchain is design synthesis- converting a design specified in VHDL code to an actual hardware implementation described by a netlist (connections between various fundamental gates). Netlists produced by synthesizing these designs without replacing fundamental reversible gates with equivalent classical logic should be lowest-level descriptions of the quantum circuits elaborated here. Reversibility should be maintained by preventing many different optimizations- in other words, a light front-end synthesizer should be used to merely replace black-box components with their architecture and nothing more. GHDL has just such a synthesizer, in theory. This could be an important part of the toolchain.