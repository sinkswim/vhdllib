library ieee;
use ieee.std_logic_1164.all;

entity or2 is
  port(
    x : in std_logic_vector(1 downto 0);
    y : out std_logic
  );
end or2;

architecture beh of or2 is
  begin
    y <= x(1) or x(0);
end beh;
