library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity incrementer is
  generic(n : natural := 8);
  port(
    x : std_logic_vector(n-1 downto 0);
    y : std_logic_vector(n-1 downto 0)
  );
end incrementer;

architecture beh of incrementer is
begin
  y <= x + 1;
end beh;
