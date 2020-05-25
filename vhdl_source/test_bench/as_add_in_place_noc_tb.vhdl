library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all; -- Imports the standard textio package.
use ieee.numeric_std.all; -- for type conversions

--A generic is included here because it can be set when invoking
--GHDL, allowing the test bench to test component sizes set at
--synthesis/compile time
entity as_add_in_place_noc_tb is
	generic (
		size : integer
	);
end as_add_in_place_noc_tb;

architecture rtl of as_add_in_place_noc_tb is
	component as_add_in_place_noc
		generic (
			n : integer
		);
		port (
			CTRL : in std_logic;
			A, B : in std_logic_vector (size-1 downto 0);
			CTRL_OUT : out std_logic;
			A_OUT, S : out std_logic_vector (size-1 downto 0)
		);
	end component;

	--for cnot0 : cnot use entity work.cnot;
	signal I, O : std_logic_vector (2*size downto 0);

	file fin : text;
	file fout : text;

begin
	--The size generic is passed from the test bench to the adder
	add : as_add_in_place_noc generic map (size) port map (
			CTRL => I(2*size),
			A => I (2*size-1 downto size),
			B => I (size-1 downto 0),
			CTRL_OUT => O(2*size),
			A_OUT =>O (2*size-1 downto size),
			S => O (size-1 downto 0)
			);
	process
		variable l : line;
		--Count the number of test cases run
		variable num : integer := 0;

		--This section is for testing via local patterns
		--type pattern_type is record
		--	I : std_logic_vector (2 downto 0);
		--	O : std_logic_vector (2 downto 0);
		--end record;
		--type pattern_array is array (natural range <>) of pattern_type;
		--constant patterns : pattern_array := (
		--	("000", "000"),
		--	("001", "001"),
		--	("010", "010"),
		--	("011", "011"),
		--	("100", "100"),
		--	("101", "101"),
		--	("110", "111"),
		--	("111", "110")
		--);

		--This section is for testing via input files
		--Lots of variables to read in a CSV
		variable iline : line;
		variable oline : line;
		--Input test vector
		variable ivar : std_logic_vector (2*size downto 0);
		--Expected test vector (also from input file)
		variable evar : std_logic_vector (2*size downto 0);
		variable comma : character;

	begin

		--This is for pattern testing
		--for j in patterns'range loop
		--	I <= patterns(j).I;
		--	wait for 1 ns;
		--	if (O /= patterns(j).O) then
		--		write (l, string'("Unexpected value for case I=")
		--			& to_string(I)
		--			& string'(": got O=")
		--			& to_string(O)
		--			& string'(", expected O=")
		--			& to_string(patterns(j).O));
  --  			writeline (output, l);
		--	end if;
		--end loop;
		--write (l, string'("End of test!"));
		--writeline (output, l);


		--This is for input files
		--Change the names here if you'd like. Input is for
		--reading in specified input and output patterns and
		--output is for reporting test results
		file_open(fin, "input.txt", read_mode);
		file_open(fout, "output.txt", write_mode);

		--Loop through input file
		while not endfile(fin) loop
			--Report progress for long tests
			num := num + 1;
			assert (num rem 10000 /= 0)
				report "Running test " & to_string(num) severity note;

			readline(fin, iline);
			read(iline, ivar);
			read(iline, comma);
			read(iline, evar);
			I <= ivar;
			wait for 1 ns;
			if (O /= evar) then
				write (oline, string'("Unexpected value for case I=")
					& to_string(I)
					& string'(": got O=")
					& to_string(O)
					& string'(", expected O=")
					& to_string(evar));
    			writeline (fout, oline);
			end if;
		end loop;
		--The file is practically empty if there are no errors
		write (l, string'("End of test with SIZE=") & to_string(size));
		writeline (fout, l);
		file_close(fin);
		file_close(fout);

		wait;
	end process;
end rtl;