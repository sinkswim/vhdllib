library ieee;
use ieee.std_logic_1164.all;

entity nand2 is
  port(
    x : in std_logic_vector(1 downto 0);
    y : out std_logic
  );
end nand2;

architecture beh of nand2 is
  begin
    y <= x(1) nand x(0);
end beh;
