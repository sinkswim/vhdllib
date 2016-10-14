library ieee;
use ieee.std_logic_1164.all;

entity nor2 is
  port(
    x : in std_logic_vector(1 downto 0);
    y : out std_logic
  );
end nor2;

architecture beh of nor2 is
  begin
    y <= x(1) nor x(0);
end beh;
