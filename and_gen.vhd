library ieee;
use ieee.std_logic_1164.all;

entity and_gen is
  generic(n : natural := 8);
  port(
    x : in std_logic_vector(n-1 downto 0);
    y : out std_logic
  );
end and_gen;

architecture beh of and_gen is
  begin
    process(x)
    variable res : std_logic;
    begin
      res := '1';
      for i in 0 to n-1 loop
        res := res and x(i);
      end loop;
      y <= res;
  end process;
end beh;
