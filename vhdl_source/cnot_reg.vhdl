library ieee;
use ieee.std_logic_1164.all;

--The entity section of the CNOT gate. This has an input and an output.
--Since it's supposed to be "reversible," the inputs and outputs are
--the same size
entity cnot_reg is
	generic (
		n : integer
	);
	port (
		CTRL : in std_logic;
		I : in std_logic_vector (n-1 downto 0);
		CTRL_OUT : out std_logic;
		O : out std_logic_vector (n-1 downto 0)
	);
end cnot_reg;

architecture rtl of cnot_reg is
	component cnot
		port (
			I : in std_logic_vector (1 downto 0);
			O : out std_logic_vector (1 downto 0)
		);
	end component;

	signal ctrl_prop : std_logic_vector (n downto 0);

begin
	
	ctrl_prop(0) <= CTRL;
	gen1 : for j in 0 to n-1 generate
		cnot0 : cnot port map (I => ctrl_prop(j) & I(j),
							O(1) => ctrl_prop(j+1),
							O(0) => O(j));
	end generate gen1;
	CTRL_OUT <= ctrl_prop(n);

end rtl;