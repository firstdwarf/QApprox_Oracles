library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity angle_lookup is
	generic (
		n : integer;
		index : integer
	);
	port (
		I : in std_logic_vector (n-1 downto 0);
		O : out std_logic_vector (n-1 downto 0)
	);
end angle_lookup;

architecture rtl of angle_lookup is

	--Array for storing vectors to look up. The size of the vectors
	--correspond to the largest currently supported angle vector size,
	--currently 16-bits. Support can be added for larger sizes by
	--calculating these fractions with higher precision.
	--Each string is arctan(2^(-index)) / 2pi.
	--Higher-indexed values are all zero!!!
	type angle_array is array (natural range <>) of std_logic_vector (15 downto 0);
	constant lut : angle_array := (
		"0010000000000000", "0001001011100100", "0000100111111011",
		"0000010100010001", "0000001010001011", "0000000101000101",
		"0000000010100010", "0000000001010001", "0000000000101000",
		"0000000000010100", "0000000000001010", "0000000000000101",
		"0000000000000010", "0000000000000001"
	);

begin

	--The evaluation of this block is known at synthesis/compile time
	gen1 : for j in 0 to n-1 generate
		--This extra -1 here is because I don't think the angle needs
		--its first bit and the second bit gets used for sign anyway.
		--This is an experimental change that could be reversed later
		gen2 : if lut(index)(15-j-1) generate
			--Maybe make a not gate here, but I don't know if it's necessary
			O(n-j-1) <= not I(n-j-1);
		else generate
			O(n-j-1) <= I(n-j-1);
		end generate gen2;
	end generate gen1;

end rtl;