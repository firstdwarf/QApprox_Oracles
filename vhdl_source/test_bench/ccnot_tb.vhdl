library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all; -- Imports the standard textio package.
use ieee.numeric_std.all;               -- for type conversions

entity ccnot_tb is
end ccnot_tb;

architecture rtl of ccnot_tb is
	component ccnot
		port (
			I : in std_logic_vector (2 downto 0);
			O : out std_logic_vector (2 downto 0)
		);
	end component;

	--for cnot0 : cnot use entity work.cnot;
	signal I, O : std_logic_vector (2 downto 0);

	file fin : text;
	file fout : text;

begin
	ccnot0 : ccnot port map (I => I, O => O);
	process

		--This section is for testing via local patterns
		variable l : line;

		type pattern_type is record
			I : std_logic_vector (2 downto 0);
			O : std_logic_vector (2 downto 0);
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array := (
			("000", "000"),
			("001", "001"),
			("010", "010"),
			("011", "011"),
			("100", "100"),
			("101", "101"),
			("110", "111"),
			("111", "110")
		);

		--This section is for testing via input files
		--variable iline : line;
		--variable oline : line;
		--variable ivar : std_logic_vector (1 downto 0);
		--variable evar : std_logic_vector (1 downto 0);
		--variable comma : character;

	begin

		--This is for pattern testing
		for j in patterns'range loop
			I <= patterns(j).I;
			wait for 1 ns;
			if (O /= patterns(j).O) then
				write (l, string'("Unexpected value for case I=")
					& to_string(I)
					& string'(": got O=")
					& to_string(O)
					& string'(", expected O=")
					& to_string(patterns(j).O));
    			writeline (output, l);
			end if;
		end loop;
		write (l, string'("End of test!"));
		writeline (output, l);


		--This is for input files
		--file_open(fin, "input.txt", read_mode);
		--file_open(fout, "output.txt", write_mode);
		--while not endfile(fin) loop
		--	readline(fin, iline);
		--	read(iline, ivar);
		--	read(iline, comma);
		--	read(iline, evar);
		--	I <= ivar;
		--	wait for 1 ns;
		--	if (O /= evar) then
		--		write (oline, string'("Unexpected value for case I=")
		--			& to_string(I)
		--			& string'(": got O=")
		--			& to_string(O)
		--			& string'(", expected O=")
		--			& to_string(evar));
  --  			writeline (fout, oline);
		--	end if;
		--end loop;
		--write (l, string'("End of test!"));
		--writeline (fout, l);
		--file_close(fin);
		--file_close(fout);

		wait;
	end process;
end rtl;