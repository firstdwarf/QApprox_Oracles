library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inith_lookup is
	generic (
		n : integer;
		stages : integer
	);
	port (
		I : in std_logic_vector (n-1 downto 0);
		O : out std_logic_vector (n-1 downto 0)
	);
end inith_lookup;

architecture rtl of inith_lookup is

	--Array for storing vectors to look up. The size of the vectors
	--correspond to the largest currently supported input size,
	--currently 16-bits. Support can be added for larger sizes by
	--calculating these fractions with higher precision.
	--Each string is the running product of cosh(arctanh(2^(-index)))
	--for all lower indices. Higher-index strings are equal to
	--the last string listed here.
	--These are all fixed-point with a leading 1, ie 1XXX = 1.XXX

	--Right 
	type angle_array is array (natural range <>) of std_logic_vector (16 downto 0);
	constant lut : angle_array := (
		"UUUUUUUUUUUUUUUUU", "10010011110011010", "10011000101001100",
		"10011001110110110", "10011010001010000", "10011010001110110",
		"10011010010000000", "10011010010000011"
	);
begin

	--Cap the index at 7 if necessary
	gen0 : if stages > 7 generate
		gen1 : for j in 0 to n-1 generate
			gen2 : if lut(7)(16-j) generate
				--Maybe make a not gate here, but I don't know if it's necessary
				O(n-j-1) <= not I(n-j-1);
			else generate
				O(n-j-1) <= I(n-j-1);
			end generate gen2;
		end generate gen1;
	else generate
		gen3 : for j in 0 to n-1 generate
			gen4 : if lut(stages)(16-j) generate
				--Maybe make a not gate here, but I don't know if it's necessary
				O(n-j-1) <= not I(n-j-1);
			else generate
				O(n-j-1) <= I(n-j-1);
			end generate gen4;
		end generate gen3;
	end generate gen0;

end rtl;