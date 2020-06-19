library ieee;
use ieee.std_logic_1164.all;

entity cordich_stage is
	generic (
		n : integer;
		index : integer
	);
	port (
		W : in std_logic_vector (n+2 + index downto 0);
		A, C : in std_logic_vector (n downto 0);
		X, Y : in std_logic_vector (n+1 downto 0);
		G : out std_logic_vector (n+2 + index downto 0);
		A_OUT, C_OUT : out std_logic_vector (n downto 0);
		X_OUT, Y_OUT : out std_logic_vector (n+1 downto 0)
	);
end cordich_stage;

architecture rtl of cordich_stage is
	component cnot_reg is
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

	component add_in_place is
		generic (
			n : integer
		);
		port (
			A, B : in std_logic_vector (n-1 downto 0);
			A_OUT, S : out std_logic_vector (n-1 downto 0)
		);
	end component;

	component add_scratch is
		generic (
			n : integer
		);
		port (
			A, B, W : in std_logic_vector (n-1 downto 0);
			A_OUT, B_OUT, S : out std_logic_vector (n-1 downto 0)
		);
	end component;

	component angleh_lookup is
		generic (
			n : integer;
			index : integer
		);
		port (
			I : in std_logic_vector (n-1 downto 0);
			O : out std_logic_vector (n-1 downto 0)
		);
	end component;

	component add_sub_in_place is
		generic (
			n : integer
		);
		port (
			CTRL : in std_logic;
			A, B : in std_logic_vector (n-1 downto 0);
			CTRL_OUT : out std_logic;
			A_OUT, S : out std_logic_vector (n-1 downto 0)
		);
	end component;

	--Cos line intermediate values
	signal x_1, x_2, x_3 : std_logic_vector (n+1 downto 0);
	--Sin line intermediate values
	signal y_1, y_2, y_3, y_4, y_5 : std_logic_vector (n+1 downto 0);
	--Angle sign bit intermediate values
	signal as : std_logic_vector (5 downto 0);
	--Constant rotation intermediate values
	signal c_1, c_2, c_3, c_4 : std_logic_vector (n downto 0);
	--Re-use workspace bits for appending to shifted sin/cos
	signal w_mid : std_logic_vector (index-1 downto 0);

	--Signal to collect angle again components and avoid bugs
	signal a_cmb : std_logic_vector (n downto 0);
begin

	--Adder to calculate cos value
	add1 : add_scratch generic map (n+2) port map (
								A => X, B => y_2, W => W (n+2 downto 1),
								A_OUT => x_1, B_OUT => y_3, S => X_OUT);

	--Adder/subtractor to calculate sin value
	addSub : add_sub_in_place generic map (n+2) port map (
								CTRL => as(3), A => y_5, B => x_2,
								CTRL_OUT => as(4),
								A_OUT => G (n+2 downto 1), S => Y_OUT);

	--Register CNOTs for adding shifted sin value to cos
	cnotr1 : cnot_reg generic map (n+2) port map (
								CTRL => as(0), I => y_1,
								CTRL_OUT => as(1), O => y_2);
	cnotr2 : cnot_reg generic map (n+2) port map (
								CTRL => as(1), I => y_3,
								CTRL_OUT => as(2), O => y_4);

	--Generate shifters for addition/subtraction
	--Right now these are inverting twice if sin or cos comes in negative
	gen0 : if index = 0 generate
		--Bypass shifters if the index is zero
		--This shouldn't happen in the cordich algorithm
		y_1 <= Y;
		y_5 <= y_4;
		x_2 <= x_1;
	else generate
		--CNOTs used for shifting and appending a leading 0 or 1
		--Shifting sin to add to cos
		cnotr3 : cnot_reg generic map (index) port map (
								CTRL => Y(n+1),
								I => W (index + n+2 downto n+3),
								CTRL_OUT => y_1(n+1 - index),
								O => y_1 (n+1 downto n+2 - index));
		y_1 (n - index downto 0) <= Y (n downto index);

		--Undoing previous shift
		cnotr4 : cnot_reg generic map (index) port map (
								CTRL => y_4(n+1 - index),
								I => y_4 (n+1 downto n+2 - index),
								CTRL_OUT => y_5(n+1), O => w_mid);
		y_5 (n downto 0) <= y_4 (n - index downto 0)
								& Y (index-1 downto 0);

		--Shifting cos to add to sin
		cnotr5 : cnot_reg generic map (index) port map (
								CTRL => x_1(n+1), I => w_mid,
								CTRL_OUT => x_2(n+1 - index),
								O => x_2 (n+1 downto n+2 - index));
		x_2 (n - index downto 0) <= x_1 (n downto index);
		G (n+2 + index downto n+3) <= x_1 (index-1 downto 0);
	end generate;

	--y_1 (n+1 downto n+2 - index) <= W (index + n+2 downto n+3);
	--y_1 (n+1 - index downto 0) <= Y (n+1 downto index);

	--y_5 <= y_4 (n+1 - index downto 0) & Y (index-1 downto 0);
	--w_mid <= y_4 (n+1 downto n+2 - index);

	--x_2 (n+1 - index downto 0) <= x_1 (n+1 downto index);

	--x_2 (n+1 downto n+2 - index) <= w_mid;

	--Adder to accumulate angle
	a_cmb <= as(5) & A (n-1 downto 0);
	add2 : add_in_place generic map (n+1) port map (
								A => c_2, B => a_cmb,
								A_OUT => c_3, S => A_OUT);

	--Inverters for angle sign bit
	as(0) <= not A(n);
	as(5) <= not as(4);

	--Register CNOT for subtracting constant
	cnotr6 : cnot_reg generic map (n+1) port map (
								CTRL => as(2), I => c_1,
								CTRL_OUT => as(3), O => c_2);
	--Register CNOT for resetting constant space
	cnotr7 : cnot_reg generic map (n) port map (
								CTRL => c_4(n), I => c_4 (n-1 downto 0),
								CTRL_OUT => G(0), O => C_OUT (n downto 1));
	C_OUT(0) <= W(0);

	--Angle lookup cnots for setting and resetting constant
	alut1 : angleh_lookup generic map (n+1, index) port map (
								I => C, O => c_1);
	alut2 : angleh_lookup generic map (n+1, index) port map (
								I => c_3, O => c_4);
end rtl;