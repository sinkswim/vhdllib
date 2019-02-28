library ieee;
use ieee.std_logic_1164.all;

entity and4 is
	port(
		a, b, c, d: in std_logic;
		z: out std_logic
	);
end and4;

architecture beh of and4 is
begin
	z <= a and b and c and d;
end beh;