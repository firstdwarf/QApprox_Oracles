library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--This adder computes onto a scratch space. It's basically a
--ripple-carry adder that makes repeated use of full-adders as below:
--(the * are controls and the N are NOT operations)
--a_n---------------*---*-----a_n
--			  	    |	|
--b_n-------*---*---|---|-----b_n
--		    |	|	|	|
--c_n-1-----*---N---*---N-----s_n
--		    |		|
--W_n-------N-------N---------c_n

entity add_scratch is
	generic (
		n : integer
	);
	port (
		A, B, W : in std_logic_vector (n-1 downto 0);
		A_OUT, B_OUT, S : out std_logic_vector (n-1 downto 0)
	);
end add_scratch;

architecture rtl of add_scratch is

	--Used to grab the inputs/outputs of a cell
	--The a-, b-, and s-slices collect stage outputs over the circuit
	--They aren't strictly necessary and can be cleaned up later
	--The c-slices are used as inputs to the next stage
	signal a_s, b_s, s_s, c_s : std_logic_vector (n-2 downto 0);

	--Temporary signals for slices within the first stage
	signal pre_a, pre_b, pre_s : std_logic;

	--Temp signal for between the final cnot gates
	signal post_s : std_logic;

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
begin

	--Compute the first stage without a carry in
	cnota : cnot port map (I => A(0) & W(0), O(1) => pre_a, O(0) => pre_s);
	cnotb : cnot port map (I => B(0) & pre_s, O(1) => pre_b, O(0) => s_s(0));
	ccnotc : ccnot port map (I => pre_a & pre_b & W(1),
							O(2) => a_s(0),
							O(1) => b_s(0),
							O(0) => c_s(0));

	--Create n-2 stages in a row: these circuit blocks are full-adders
	gen1 : for j in 1 to n-2 generate
		signal mid1, mid2, mid3 : std_logic_vector (3 downto 0);
	begin
		--Compute on the carry out from the last stage using workspace
		--ccnot(b, sum, carry)
		ccnot1 : ccnot port map (I => B(j) & c_s(j-1) & W(j+1),
								O(2) => mid1(1),
								O(1) => mid1(2),
								O(0) => mid1(3));
		mid1(0) <= A(j);

		--cnot(b, sum)
		cnot1 : cnot port map (I => mid1(1) & mid1(2),
							O(1) => mid2(1),
							O(0) => mid2(2));
		mid2(0) <= mid1(0);
		mid2(3) <= mid1(3);

		--ccnot(a, sum, carry)
		ccnot2 : ccnot port map (I => mid2(0) & mid2(2) & mid2(3),
								O(2) => mid3(0),
								O(1) => mid3(2),
								O(0) => mid3(3));

		mid3(1) <= mid2(1);

		--cnot(a, sum)
		cnot2 : cnot port map (I => mid3(0) & mid3(2),
							O(1) => a_s(j),
							O(0) => s_s(j));

		b_s(j) <= mid3(1);
		c_s(j) <= mid3(3);
	end generate gen1;

	--These compute the final sum without an output carry
	--cnot(b, sum)
	cnoteb : cnot port map (I => B(n-1) & c_s(n-2),
							O(1) => B_OUT(n-1),
							O(0) => post_s);
	--cnot(a, sum)
	cnotea : cnot port map (I => A(n-1) & post_s,
							O(1) => A_OUT(n-1),
							O(0) => S(n-1));

	A_OUT(n-2 downto 0) <= a_s;
	B_OUT(n-2 downto 0) <= b_s;
	S(n-2 downto 0) <= s_s;

end rtl;