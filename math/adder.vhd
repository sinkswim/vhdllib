library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  generic(
    n : natural := 8
  );
  port(
    a : in unsigned(n-1 downto 0);
    b : in unsigned(n-1 downto 0);
    res : out unsigned(n-1 downto 0);
    cin, cout : out std_logic
  );
end adder;

architecture beh of adder is
  signal tmp : unsigned(n downto 0);
begin
  process(a, b, cin)
  begin
    tmp <= ("0"&a) + ("0"&b) + ("0"&cin);
    res <= tmp(n-1 downto 0);
    cout <= tmp(n);
  end process;
end beh;
