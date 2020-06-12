library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all; -- Imports the standard textio package.
use ieee.numeric_std.all;               -- for type conversions

entity cordich_tb is
	generic (
		size : integer;
		stages : integer
	);
end cordich_tb;

architecture rtl of cordich_tb is
	component cordich is
		generic (
			n : integer;
			stages : integer
		);
		port (
			--Total amount of garbage ancillae, with an extra bit for the angle
			W : in std_logic_vector ((stages+1)*(n+3) + ((stages+1)*stages)/2 downto 0);
			--The angle you want to run CORDIC on, with a leading zero
			A : in std_logic_vector (n downto 0);
			--Zero-initialized scratch space for loading constants
			C : in std_logic_vector (n downto 0);
			--Zero-initialized space to calculate cos and sin on
			X, Y : in std_logic_vector (n+1 downto 0);
			G : out std_logic_vector ((stages+1)*(n+3) + ((stages+1)*stages)/2 downto 0);
			--Garbage but partially indicative of accuracy
			A_OUT : out std_logic_vector (n downto 0);
			--Returned un-computed back ot zero
			C_OUT : out std_logic_vector (n downto 0);
			X_OUT, Y_OUT : out std_logic_vector (n+1 downto 0)
		);
	end component;


	--for cnot0 : cnot use entity work.cnot;
	signal I : std_logic_vector (size-1 downto 0);
	signal O : std_logic_vector (2*size + 3 downto 0);

	--Temporary signals to make assignment easy and prevent them
	--from being optimized away
	signal g : std_logic_vector ((stages+1)*(size+3) + ((stages+1)*stages)/2 downto 0);
	signal a_out : std_logic_vector (size downto 0);
	signal c_out : std_logic_vector (size downto 0);

	--More temp signals
	signal w : std_logic_vector ((stages+1)*(size+3) + ((stages+1)*stages)/2 downto 0);
	signal a : std_logic_vector (size downto 0);
	signal c : std_logic_vector (size downto 0);
	signal x, y : std_logic_vector (size+1 downto 0);

	file fin : text;
	file fout : text;

begin
	a <= '0' & I;
	w <= (others => '0');
	c <= (others => '0');
	x <= (others => '0');
	y <= (others => '0');
	cordich0 : cordich generic map (size, stages) port map (
								W => w, A => a, C => c,
								X => x, Y => y,
								G => g, A_OUT => a_out, C_OUT => c_out,
								X_OUT => O (2*size + 3 downto size+2),
								Y_OUT => O (size+1 downto 0));
	process
		variable l : line;
		--Count the number of test cases run
		variable num : integer := 0;

		--This section is for testing via input files
		variable iline : line;
		variable oline : line;
		variable ivar : std_logic_vector (size-1 downto 0);

	begin

		--This is for input files
		file_open(fin, "input.txt", read_mode);
		file_open(fout, "output.txt", write_mode);
		while not endfile(fin) loop
			--Report progress for long tests
			num := num + 1;
			assert false
				report "Running test " & to_string(num) severity note;

			readline(fin, iline);
			read(iline, ivar);
			I <= ivar;
			wait for 1 ns;
			write (oline, to_string(I) & string'(",")
				& to_string(O (2*size + 3 downto size+2))
				& string'(",") & to_string(O (size+1 downto 0)));
			writeline (fout, oline);
		end loop;
		file_close(fin);
		file_close(fout);

		wait;
	end process;
end rtl;