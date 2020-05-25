library ieee;
use ieee.std_logic_1164.all;

entity peres is
	port (
		I : in std_logic_vector (2 downto 0);
		O : out std_logic_vector (2 downto 0)
	);
end peres;

architecture rtl of peres is
begin
	O(2) <= I(2);
	O(1) <= I(2) xor I(1);
	O(0) <= I(0) xor (I(2) and I(1));
end rtl;