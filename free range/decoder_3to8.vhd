library ieee;
use ieee.std_logic_1164.all;

entity decoder_3to8 is
	port(
		x: in std_logic_vector(2 downto 0);
		z: out std_logic_vector(7 downto 0)
	);
end decoder_3to8;

architecture beh of decoder_3to8 is
begin
	with x select
		z <= x"00" when "000",
			 x"01" when "001",
			 x"02" when "010",
			 x"03" when "011",
			 x"04" when "100",
			 x"05" when "101",
			 x"06" when "110",
			 x"07" when "111",
			 (others => '0') when others;
end beh;