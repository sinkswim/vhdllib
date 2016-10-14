library ieee;
use ieee.std_logic_1164.all;

entity and2 is
  port(
    x : in std_logic_vector(1 downto 0);
    y : out std_logic
  );
end and2;

architecture beh of and2 is
  begin
    y <= x(1) and x(0);
end beh;
