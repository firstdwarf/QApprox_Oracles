library ieee;
use ieee.std_logic_1164.all;

entity ccnot is
	port (
		I : in std_logic_vector (2 downto 0);
		O : out std_logic_vector (2 downto 0)
	);
end ccnot;

architecture rtl of ccnot is
begin
	--Subvectors within a std_logic_vector can be accessed like this
	O (2 downto 1) <= I (2 downto 1);
	--Simple double-controlled NOT gate
	O(0) <= I(0) xor (I(2) and I(1));
end rtl;