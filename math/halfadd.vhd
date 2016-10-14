library ieee;
use ieee.std_logic_1164.all;

entity halfadd is
  port(
    a, b : in std_logic;
    s, cout : out std_logic
  );
end halfadd;

architecture beh of halfadd is
begin
    s <=  a xor b;
    cout <= a and b;
end beh;
