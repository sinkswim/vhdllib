library ieee;
use ieee.std_logic_1164.all;

entity inv is
  port(
    x : in std_logic;
    y : out std_logic
  );
end inv;

architecture beh of inv is
  begin
    y <= not(x);
end beh;
