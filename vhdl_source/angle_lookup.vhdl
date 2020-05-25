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
	component cnot
		port (
			I : in std_logic_vector (1 downto 0);
			O : out std_logic_vector (1 downto 0)
		);
	end component;

	--Array for storing vectors to look up. The size of the vectors
	--correspond to the largest currently supported angle vector size,
	--currently 16-bits. Support can be added for larger sizes by
	--calculating these fractions with higher precision.
	--Each string is arctan(2^(-index)) / 2pi.
	--Higher-indexed values are all zero!!!
	type angle_array is array (natural range <>) of std_logic_vector (15 downto 0);
	constant lut : angle_array := (
		"00100000000000000", "00010010111001000", "00001001111110110",
		"00000101000100010", "00000010100010110", "00000001010001011",
		"00000000101000101", "00000000010100010", "00000000001010001",
		"00000000000101000", "00000000000010100", "00000000000001010",
		"00000000000000101", "00000000000000010", "00000000000000001"
	);
	signal angle : std_logic_vector (n-1 downto 0);

begin
	--Copy the n highest bits from the lut
	--angle <= lut(index)(15 downto 16-n);
	--gen1 : for j in n-1 downto 0 generate
	--	gen2 : if angle(j) = 1 generate

	--		--TODO: make a not gate and use it here!
	--		cnotx : cnot port map (I => );
	--	else generate

	--	end generate gen2;
	--end generate gen1;
end rtl;