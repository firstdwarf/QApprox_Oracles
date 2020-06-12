library ieee;
use ieee.std_logic_1164.all;

entity cordich is
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
end cordich;

architecture rtl of cordich is
	component cordich_stage is
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
	end component;

	component inith_lookup is
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

	type angle_sigs is array (stages downto 0) of std_logic_vector (n downto 0);
	signal cs, as : angle_sigs;

	type v_sigs is array (stages downto 0) of std_logic_vector (n+1 downto 0);
	signal xs, ys : v_sigs;

	--Lookup tables where the array index is the iteration number
	type index_lookup is array (natural range <>) of integer;
	--Stage numbers for a given iteration
	constant sl : index_lookup := (
							1, 2, 3, 4, 4, 5, 6, 7, 8,
							9, 10, 11, 12, 13, 13, 14
						);
	--Workspace bounds for a given iteration
	constant bl : index_lookup := (
							-1, n+3, 2*n+8, 3*n+14, 4*n+21, 5*n+28,
							6*n+36, 7*n+45, 8*n+55, 9*n+66, 10*n+78,
							11*n+91, 12*n+105, 13*n+120, 14*n+136,
							15*n+152, 16*n+169
						);
begin
	initx : inith_lookup generic map (n+1, stages) port map (
									I => X (n downto 0),
									O => xs(0) (n downto 0));
	xs(0)(n+1) <= X(n+1);

	--inity : inith_lookup generic map (n+1, stages) port map (
	--								I => Y (n downto 0),
	--								O => ys(0) (n downto 0));

	--ys(0)(n+1) <= Y(n+1);
	ys(0) <= Y;
	cs(0) <= C;

	--Invert angle to represent current distance from target angle
	as(0) <= not A;
	A_OUT <= as(stages);
	C_OUT <= cs(stages);
	X_OUT <= xs(stages);
	Y_OUT <= ys(stages);

	gen1 : for j in 0 to stages-1 generate
		--Put the cordich stages here
		stagex : cordich_stage generic map (n, sl(j)) port map (
								W => W (bl(j+1) downto bl(j)+1),
								A => as(j), C => cs(j),
								X => xs(j), Y => ys(j),
								G => G (bl(j+1) downto bl(j)+1),
								A_OUT => as(j+1), C_OUT => cs(j+1),
								X_OUT => xs(j+1), Y_OUT => ys(j+1));
	end generate gen1;
end rtl;