library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity angleh_lookup is
	generic (
		n : integer;
		index : integer
	);
	port (
		I : in std_logic_vector (n-1 downto 0);
		O : out std_logic_vector (n-1 downto 0)
	);
end angleh_lookup;

architecture rtl of angleh_lookup is

	--Array for storing vectors to look up. The size of the vectors
	--correspond to the largest currently supported angle vector size,
	--currently 16-bits. Support can be added for larger sizes by
	--calculating these fractions with higher precision.
	--Each string is arctanh(2^(-index)) with a leading 0
	--in the ones place
	--Higher-order terms are probably 0
	type angleh_array is array (natural range <>) of std_logic_vector (16 downto 0);
	constant lut : angleh_array := (
		"0UUUUUUUUUUUUUUUU", "01000110010011111", "00100000101100010",
		"00010000000101011", "00001000000000101", "00000100000000000",
		"00000010000000000", "00000001000000000", "00000000100000000",
		"00000000010000000", "00000000001000000", "00000000000100000",
		"00000000000010000", "00000000000001000", "00000000000000100",
		"00000000000000010", "00000000000000001"
	);

begin

	--The evaluation of this block is known at synthesis/compile time
	gen1 : for j in 0 to n-1 generate
		gen2 : if lut(index)(16-j) generate
			O(n-j-1) <= not I(n-j-1);
		else generate
			O(n-j-1) <= I(n-j-1);
		end generate gen2;
	end generate gen1;

end rtl;