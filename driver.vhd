library ieee;
use ieee.std_logic_1164.all;

entity driver is
  port(
    x : in std_logic;
    y : out std_logic
  );
end driver;

architecture beh of driver is
begin
  y <= x;
end beh;
