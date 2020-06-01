library ieee;
use ieee.std_logic_1164.all;

entity cordic is
	generic (
		n : integer;
		stages : integer
	);
	port (
		--Total amount of garbage ancillae, with an extra bit for the angle
		W : in std_logic_vector (stages*(n+2) + (stages*(stages-1))/2 downto 0);
		--The angle you want to run CORDIC on, with a leading zero
		A : in std_logic_vector (n downto 0);
		--Zero-initialized scratch space for loading constants
		C : in std_logic_vector (n-2 downto 0);
		--Zero-initialized space to calculate cos and sin on
		X, Y : in std_logic_vector (n downto 0);
		G : out std_logic_vector (stages*(n+2) + (stages*(stages-1))/2 downto 0);
		--Garbage but partially indicative of accuracy
		A_OUT : out std_logic_vector (n downto 0);
		--Returned un-computed back ot zero
		C_OUT : out std_logic_vector (n-2 downto 0);
		X_OUT, Y_OUT : out std_logic_vector (n downto 0)
	);
end cordic;

architecture rtl of cordic is
	component cordic_stage is
		generic (
			n : integer;
			index : integer
		);
		port (
			W : in std_logic_vector (n+1 + index downto 0);
			A, C : in std_logic_vector (n-2 downto 0);
			X, Y : in std_logic_vector (n downto 0);
			G : out std_logic_vector (n+1 + index downto 0);
			A_OUT, C_OUT : out std_logic_vector (n-2 downto 0);
			X_OUT, Y_OUT : out std_logic_vector (n downto 0)
		);
	end component;

	component init_lookup is
		generic (
			n : integer;
			stages : integer
		);
		port (
			I : in std_logic_vector (n-1 downto 0);
			O : out std_logic_vector (n-1 downto 0)
		);
	end component;

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

	component cnot is
		port (
			I : in std_logic_vector (1 downto 0);
			O : out std_logic_vector (1 downto 0)
		);
	end component;

	--Used to store temp values during angle and x/y shifting
	signal a_ctrl : std_logic_vector (3 downto 0);

	type angle_sigs is array (stages downto 0) of std_logic_vector (n-2 downto 0);
	signal cs, as : angle_sigs;

	type v_sigs is array (stages downto 0) of std_logic_vector (n downto 0);
	signal xs, ys : v_sigs;
begin
	init : init_lookup generic map (n, stages) port map (
									I => X (n-1 downto 0),
									O => xs(0) (n-1 downto 0));
	xs(0)(n) <= X(n);

	ys(0) <= Y;
	cs(0) <= C;

	--Register cnot to subtract all but the top bit of A from pi
	cnotr1 : cnot_reg generic map (n-2) port map (
									CTRL => A(n-2), I => A (n-3 downto 0),
									CTRL_OUT => a_ctrl(1),
									O => as(0) (n-3 downto 0));

	--This uses the leading zero ancilla in A (for now)
	as(0)(n-2) <= A(n);

	--Use the first two angle bits (A(n-1) and a_ctrl) to fix X and Y
	cnotry : cnot_reg generic map (n+1) port map (
									CTRL => A(n-1), I => ys(stages),
									CTRL_OUT => a_ctrl(2), O => Y_OUT);
	--Flip the second bit off the first one to use it for cos
	cnot1 : cnot port map (I => a_ctrl (2 downto 1),
									O(1) => A_OUT(n), O(0) => a_ctrl(0));
	--Flip cos
	cnotrx : cnot_reg generic map (n+1) port map (
									CTRL => a_ctrl(0), I => xs(stages),
									CTRL_OUT => A_OUT(n-1), O => X_OUT);

	gen1 : for j in 0 to stages-1 generate
		--Put the cordic stages here
		stagex : cordic_stage generic map (n, j) port map (
									W => W ((j+1)*(n+2) + (j*(j+1))/2
										downto j*(n+2) + (j*(j-1))/2 + 1),
									A => as(j), C => cs(j),
									X => xs(j), Y => ys(j),
									G => G ((j+1)*(n+2) + (j*(j+1))/2
										downto j*(n+2) + (j*(j-1))/2 + 1),
									A_OUT => as(j+1), C_OUT => cs(j+1),
									X_OUT => xs(j+1), Y_OUT => ys(j+1));
	end generate gen1;
end rtl;