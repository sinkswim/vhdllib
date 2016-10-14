library ieee;
use ieee.std_logic_1164.all;

entity fulladd is
  port(
    a, b, cin : in std_logic;
    s, cout : out std_logic
  );
end fulladd;

architecture beh of fulladd is
begin
  s <= (a xor b) xor cin;
  cout <= (b and cin) or (a and cin) or (a and b);
end beh;
