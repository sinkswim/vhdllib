library IEEE;
use IEEE.std_logic_1164.all; 

entity pgcell is
	port(
		a, b : in std_logic;
		p, g : out std_logic
	);
end entity;

architecture beh of pgcell is
begin
	p <= a xor b;
	g <= a and b;
end beh;


