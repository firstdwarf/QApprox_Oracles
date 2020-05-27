library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--This is a hybrid adder/subtractor that computes an approximate
--subtraction by taking 1s complement instead of 2s complement.
--The a-input is inverted based on the control signal.
--The adder in this design has no carry-in and computes on

entity add_sub_in_place is
	generic (
		n : integer
	);
	port (
		CTRL : in std_logic;
		A, B : in std_logic_vector (n-1 downto 0);
		CTRL_OUT : out std_logic;
		A_OUT, S : out std_logic_vector (n-1 downto 0)
	);
end add_sub_in_place;

architecture rtl of add_sub_in_place is
	component add_in_place
		generic (
			n : integer
		);
		port (
			A, B : in std_logic_vector (n-1 downto 0);
			A_OUT, S : out std_logic_vector (n-1 downto 0)
		);
	end component;

	component cnot_reg
		generic (
			n : integer
		);
		port (
			CTRL : in std_logic;
			I : in std_logic_vector (n-1 downto 0);
			CTRL_OUT : out std_logic;
			O : out std_logic_vector (n-1 downto 0)
		);
	end component;

	--Signal to store the complement of the b-input
	signal b_cnot : std_logic_vector (n-1 downto 0);

begin
	cnotr : cnot_reg generic map (n) port map (
								CTRL => CTRL, I => B,
								CTRL_OUT => CTRL_OUT, O => b_cnot);

	add : add_in_place generic map (n) port map (
								A => A, B => b_cnot,
								A_OUT => A_OUT, S => S);

end rtl;