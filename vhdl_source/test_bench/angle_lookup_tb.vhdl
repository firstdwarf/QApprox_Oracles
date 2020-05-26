library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all; -- Imports the standard textio package.
use ieee.numeric_std.all;               -- for type conversions

--Empty entity without inputs or outputs
entity angle_lookup_tb is
	generic (
		size : integer;
		index : integer
	);
end angle_lookup_tb;


architecture rtl of angle_lookup_tb is
	--Declaring the component to test
	component angle_lookup
		generic (
			n : integer;
			index : integer
		);
		port (
			I : in std_logic_vector (n-1 downto 0);
			O : out std_logic_vector (n-1 downto 0)
		);
	end component;

	--This is an unnecessary configuration statement; this might be
	--useful later though
	--for cnot0 : cnot use entity work.cnot;

	--Signals to write to the component to test
	signal I, O : std_logic_vector (size-1 downto 0);

	--Files to read from. While this test bench uses constant test
	--patterns, both methods are included here
	--file fin : text;
	--file fout : text;

	type angle_array is array (natural range <>) of std_logic_vector (15 downto 0);
		constant lut : angle_array := (
			"0010000000000000", "0001001011100100", "0000100111111011",
			"0000010100010001", "0000001010001011", "0000000101000101",
			"0000000010100010", "0000000001010001", "0000000000101000",
			"0000000000010100", "0000000000001010", "0000000000000101",
			"0000000000000010", "0000000000000001"
		);
	signal angle : std_logic_vector (size-1 downto 0);

begin
	angle_lut : angle_lookup generic map (n => size, index => index)
		port map (I => I, O => O);

	I <= (others => '0');
	angle <= lut(index)(15 downto 16-size);

	--Sequential process statement
	process

		--This section is for testing via local patterns
		--Variables are like signals but only for processes
		variable l : line;
	begin

		----This is for lookup table testing
		wait for 1 ns;
		--Test circuit output
		if (O /= angle) then
			write (l, string'("Unexpected value for case I=")
				& to_string(I)
				& string'(": got O=")
				& to_string(O)
				& string'(", expected O=")
				& to_string(angle));
    		writeline (output, l);
		end if;
		write (l, string'("End of test!"));
		writeline (output, l);
		wait;
	end process;
end rtl;