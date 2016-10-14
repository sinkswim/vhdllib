library ieee;
use ieee.std_logic_1164.all;

entity xnor2 is
  port(
    x0, x1 : in std_logic;
    y : out std_logic
  );
end xnor2;

architecture beh of xnor2 is
  begin
    y <= x0 xnor x1;
end beh;
