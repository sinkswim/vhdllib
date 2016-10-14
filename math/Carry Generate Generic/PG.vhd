library IEEE;
use IEEE.std_logic_1164.all;

entity white_box is		-- white_box is PG block (see diagram)
	port(
		Pik, Plow, Gik, Glow : in std_logic;
		Pij, Gij : out std_logic
	);
end white_box;

architecture beh of white_box is
begin
	Gij <=	Gik or (Pik and Glow);
	Pij <=	Pik and Plow;
end beh;





