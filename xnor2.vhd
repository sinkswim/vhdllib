library ieee;
use ieee.std_logic_1164.all;

entity xnor2 is
  port(
    x : in std_logic_vector(1 downto 0);
    y : out std_logic
  );
end xnor2;

architecture beh of xnor2 is
  begin
    y <= x(1) xnor x(0);
end beh;
