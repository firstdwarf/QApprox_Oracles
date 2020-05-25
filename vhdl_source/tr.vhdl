library ieee;
use ieee.std_logic_1164.all;

--This one hasn't been tested or used yet

entity tr is
	port (
		I : in std_logic_vector (2 downto 0);
		O : out std_logic_vector (2 downto 0)
	);
end tr;

architecture rtl of tr is
begin
	O(2) <= I(2);
	O(1) <= I(2) xor I(1);
	O(0) <= I(0) xor (I(2) and (not I(1)));
end rtl;