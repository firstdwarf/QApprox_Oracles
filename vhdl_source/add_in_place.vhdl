library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--This is the first complex reversible component I built and it
--may be rewritten later. It's possible that a process statement
--could be used for these heavily sequential sections, but I won't
--know for sure without access to a synthesis tool so I can
--verify the design maintains reversibility

--This adder is described in section 4 of the following paper:
	
	--Thapliyal, H., & Ranganathan, N. (2017).
	--Design of Efficient Reversible Logic Based Binary
	--and BCD Adder Circuits.

--If you're trying to figure out how this works, I'd highly recommend
--looking off the diagrams in the paper

entity add_in_place is
	--This is what having a generic input looks like
	generic (
		n : integer
	);
	--Multiple inputs or outputs of the same type can be declared
	--simultaneously. Note the variable size depending on the generic
	port (
		A, B : in std_logic_vector (n-1 downto 0);
		A_out, S : out std_logic_vector (n-1 downto 0)
	);
end add_in_place;

architecture rtl of add_in_place is
	--There are intermediate signals declared below for after
	--each of the six distinctive stages of the computaton

	--Vertical signal slice for concurrent gates
	signal s1_a, s1_b : std_logic_vector (n-1 downto 0);

	--Staggered vertical signal slice for sequential gates. The
	--mid signal is used for intermediate results within the stage
	signal s2_mid : std_logic_vector (n-1 downto 0);
	signal s2_a, s2_b : std_logic_vector (n-1 downto 0);

	signal s3_mid : std_logic_vector (n-1 downto 0);
	signal s3_a, s3_b : std_logic_vector (n-1 downto 0);

	signal s4_mid : std_logic_vector (n-1 downto 0);
	signal s4_a, s4_b : std_logic_vector (n-1 downto 0);

	signal s5_mid : std_logic_vector (n-1 downto 0);
	signal s5_a, s5_b : std_logic_vector (n-1 downto 0);

	signal s6_a, s6_b : std_logic_vector (n-1 downto 0);

	--Component descriptions. These are nearly identical to their
	--entity descriptions within their respective files
	component cnot
		port (
			I : in std_logic_vector (1 downto 0);
			O : out std_logic_vector (1 downto 0)
		);
	end component;

	component ccnot
		port (
			I : in std_logic_vector (2 downto 0);
			O : out std_logic_vector (2 downto 0)
		);
	end component;

	component peres
		port (
			I : in std_logic_vector (2 downto 0);
			O : out std_logic_vector (2 downto 0)
		);
	end component;
begin

	--Step one
	--This is a generate statement that creates n-1 concurrent
	--cnot gates
	gen1 : for j in 1 to n-1 generate
		--Port maps connect the inputs and outputs of a component
		--instance to signals within the current architecture.
		--The assignment operators are a little different here.
		--Also, the concatenation operator & is used to assign
		--the 2-bit cnot input I to the vector formed by putting
		--a(j) in the MSB and b(j) in the LSB.
		cnot1_j : cnot port map (I => a(j) & b(j),
			O(1) => s1_a(j), O(0) => s1_b(j));
	end generate gen1;
	s1_a(0) <= a(0);
	s1_b(0) <= b(0);

	--Step two
	s2_mid(0) <= s1_a(0);
	s2_mid(n-1) <= s1_a(n-1);
	gen2 : for j in n-1 downto 2 generate
		--Description of sequential cnot gates
		cnot2_j : cnot port map (I => a(j-1) & s2_mid(j),
			O(1) => s2_mid(j-1), O(0) => s2_a(j));
	end generate gen2;
	s2_a(1 downto 0) <= s2_mid(1 downto 0);
	s2_b <= s1_b;

	--Step three
	s3_mid(0) <= s2_a(0);
	gen3 : for j in 1 to n-1 generate
		ccnot3_j : ccnot port map (I => s2_b(j-1) & s3_mid(j-1) & s2_a(j),
								O(2) => s3_b(j-1),
								O(1) => s3_a(j-1),
								O(0) => s3_mid(j));
	end generate gen3;
	s3_a(n-1) <= s3_mid(n-1);
	s3_b(n-1) <= s2_b(n-1);

	--Step four
	cnot_4 : cnot port map (I => s3_a(n-1) & s3_b(n-1),
						O(1) => s4_mid(n-1), O(0) => s4_b(n-1));

	gen4 : for j in n-2 downto 0 generate
		peres4_j : peres port map (I => s3_a(j) & s3_b(j) & s4_mid(j + 1),
								O(2) => s4_mid(j),
								O(1) => s4_b(j),
								O(0) => s4_a(j + 1));
	end generate gen4;
	s4_a(0) <= s4_mid(0);

	--Step five
	s5_mid(1 downto 0) <= s4_a(1 downto 0);
	gen5 : for j in 1 to n-2 generate
		cnot5_j : cnot port map (I => s5_mid(j) & s4_a(j+1),
								O(1) => s5_a(j),
								O(0) => s5_mid(j+1));
	end generate gen5;
	s5_a(0) <= s5_mid(0);
	s5_a(n-1) <= s5_mid(n-1);
	s5_b <= s4_b;

	--Step six
	s6_a(0) <= s5_a(0);
	s6_b(0) <= s5_b(0);
	gen6 : for j in 1 to n-1 generate
		--Description of concurrent cnot gates
		cnot1_j : cnot port map (I => s5_a(j) & s5_b(j),
								O(1) => s6_a(j),
								O(0) => s6_b(j));
	end generate gen6;

	A_OUT <= s6_a;
	S <= s6_b;

end rtl;