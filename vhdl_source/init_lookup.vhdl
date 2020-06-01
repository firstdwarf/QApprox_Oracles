library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity init_lookup is
	generic (
		n : integer;
		stages : integer
	);
	port (
		I : in std_logic_vector (n-1 downto 0);
		O : out std_logic_vector (n-1 downto 0)
	);
end init_lookup;

architecture rtl of init_lookup is

	--Array for storing vectors to look up. The size of the vectors
	--correspond to the largest currently supported input size,
	--currently 16-bits. Support can be added for larger sizes by
	--calculating these fractions with higher precision.
	--Each string is the running product of cos(arctan(2^(-index)))
	--for all lower indices. Higher-index strings are equal to
	--the last string listed here

	--Right now, all of these are initialized to roughly 0.6072
	type angle_array is array (natural range <>) of std_logic_vector (15 downto 0);
	constant lut : angle_array := (
		"1011010100000100", "1010000111101000", "1001110100010011",
		"1001101111011100", "1001101110001110", "1001101101111011",
		"1001101101110110", "1001101101110101", "1001101101110101",
		"1001101101110100"
	);

begin

	--Cap the index at 9 if necessary
	gen0 : if stages > 9 generate
		gen1 : for j in 0 to n-1 generate
			gen2 : if lut(9)(15-j) generate
				--Maybe make a not gate here, but I don't know if it's necessary
				O(n-j-1) <= not I(n-j-1);
			else generate
				O(n-j-1) <= I(n-j-1);
			end generate gen2;
		end generate gen1;
	else generate
		gen3 : for j in 0 to n-1 generate
			gen4 : if lut(stages)(15-j) generate
				--Maybe make a not gate here, but I don't know if it's necessary
				O(n-j-1) <= not I(n-j-1);
			else generate
				O(n-j-1) <= I(n-j-1);
			end generate gen4;
		end generate gen3;
	end generate gen0;

end rtl;