library IEEE;
use IEEE.std_logic_1164.all;

entity grey_box is	-- grey_box is G block (see diagram)
	port(
    Gik, Pik, Glow : in std_logic;
    Gij : out std_logic
	);
end grey_box;

architecture beh of grey_box is
begin
	Gij <= Gik or (Pik and Glow);
end beh;

