library ieee;
use ieee.std_logic_1164.all;

entity mux21 is
	generic(N: positive := 8);
	port(
		x, y: in std_logic_vector(N-1 downto 0);
		sel: in std_logic;
		z: out std_logic_vector(N-1 downto 0)
	);
end mux21;

architecture beh of mux21 is
begin
	with sel select 
	z <= x when '0',
		 y when '1',
		 (others => '0') when others;
end beh;
