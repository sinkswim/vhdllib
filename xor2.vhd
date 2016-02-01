library ieee;
use ieee.std_logic_1164.all;

entity xor2 is
  port(
    x : in std_logic_vector(1 downto 0);
    y : out std_logic
  );
end xor2;

architecture beh of xor2 is
  begin
    y <= x(1) xor (0);
end beh;
