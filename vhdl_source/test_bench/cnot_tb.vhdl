library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all; -- Imports the standard textio package.
use ieee.numeric_std.all;               -- for type conversions

--Empty entity without inputs or outputs
entity cnot_tb is
end cnot_tb;


architecture cnot_tb_arc of cnot_tb is
	--Declaring the component to test
	component cnot
		port (
			I : in std_logic_vector (1 downto 0);
			O : out std_logic_vector (1 downto 0)
		);
	end component;

	--This is an unnecessary configuration statement; this might be
	--useful later though
	--for cnot0 : cnot use entity work.cnot;

	--Signals to write to the component to test
	signal I, O : std_logic_vector (1 downto 0);

	--Files to read from. While this test bench uses constant test
	--patterns, both methods are included here
	--file fin : text;
	--file fout : text;

begin
	cnot0 : cnot port map (I => I, O => O);
	--Sequential process statement
	process

		--This section is for testing via local patterns
		--Variables are like signals but only for processes
		variable l : line;

		--Custom type for an expected input and output
		type pattern_type is record
			I : std_logic_vector (1 downto 0);
			O : std_logic_vector (1 downto 0);
		end record;

		--Constant array of input and output cases
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array := (
			("00", "00"),
			("01", "01"),
			("10", "11"),
			("11", "10")
		);

		--This section is for testing via input files
		--variable iline : line;
		--variable oline : line;
		--variable ivar : std_logic_vector (1 downto 0);
		--variable evar : std_logic_vector (1 downto 0);
		--variable comma : character;

	begin

		--This is for pattern testing
		--Loop through constant pattern array
		for j in patterns'range loop
			I <= patterns(j).I;
			wait for 1 ns;
			--Test circuit output
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
end cnot_tb_arc;