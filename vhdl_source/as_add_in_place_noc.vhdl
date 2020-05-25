library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--This is a hybrid adder/subtractor that computes an approximate
--subtraction by taking 1s complement instead of 2s complement.
--The a-input is inverted based on the control signal.
--The adder in this design has no carry-in and computes on

entity as_add_in_place_noc is
	generic (
		n : integer
	);
	port (
		CTRL : in std_logic;
		A, B, W : in std_logic_vector (n-1 downto 0);
		CTRL_OUT : out std_logic;
		A_OUT, B_OUT, S : out std_logic_vector (n-1 downto 0)
	);
end as_add_in_place_noc;

architecture rtl of as_add_in_place_noc is
	component add_in_place
		generic (
			n : integer
		);
		port (
			A, B, W : in std_logic_vector (n-1 downto 0);
			A_OUT, B_OUT, S : out std_logic_vector (n-1 downto 0)
		);
	end component;

	component cnot
		port (
			I : in std_logic_vector (1 downto 0);
			O : out std_logic_vector (1 downto 0)
		);
	end component;

	--Signal to store the complement of the a-input
	signal a_cnot : std_logic_vector (n-1 downto 0);
	--Signal to store the ctrl signal before and after all uses
	signal ctrl_prop : std_logic_vector (n downto 0);

begin
	ctrl_prop(0) <= CTRL;
	gen1 : for j in 0 to n-1 generate
		cnot0 : cnot port map (I => ctrl_prop(j) & A(j),
							O(1) => ctrl_prop(j+1),
							O(0) => a_cnot(j));
	end generate gen1;
	CTRL_OUT <= ctrl_prop(n);

	add : add_in_place generic map (n) port map (
								A => a_cnot, B => B, W => W,
								A_OUT => A_OUT, B_OUT => B_OUT, S => S);

end rtl;