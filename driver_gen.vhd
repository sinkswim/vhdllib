library ieee;
use ieee.std_logic_1164.all;

entity driver is
  generic(
    n : natural := 1
  );
  port(
    x : in std_logic_vector(n-1 downto 0);
    y : out std_logic_vector(n-1 downto 0)
  );
end driver;

architecture beh of driver is
begin
  y <= x;
end beh;
