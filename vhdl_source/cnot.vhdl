library ieee;
use ieee.std_logic_1164.all;

--The entity section of the CNOT gate. This has an input and an output.
--Since it's supposed to be "reversible," the inputs and outputs are
--the same size
entity cnot is
	port (
		--Each port is a 2-bit vector of std_logic. The size is
		--specified with the "downto" keyword, making the most
		--significant bit (MSB )indexed at 1 and the LSB indexed at 0
		I : in std_logic_vector (1 downto 0);
		O : out std_logic_vector (1 downto 0)
	);
end cnot;

--The architecture section. One input bit (the control bit)
--should be copied to the output and the other outputs the controlled
--flip, computed with a non-reversible XOR gate for simulation purposes
architecture rtl of cnot is
	--There are no intermediate signals or components in this design
begin
	--The VHDL assignment operator with the destination on the left
	O(1) <= I(1);
	O(0) <= I(0) xor I(1);
end rtl;