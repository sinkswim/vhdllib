library ieee;
use ieee.std_logic_1164.all;

entity n2to1mux is
  port(
    sw : in std_logic;
    x : in std_logic_vector(1 downto 0);
    y : out std_logic
  );
end n2to1mux;

architecture beh of n2to1mux is
  begin
    process(sw, x)
    begin
        if(sw = '0') then
          y <= x(0);
        elsif(sw = '1') then
          y <= x(1);
        else
          y <= 'Z';
        end if;
    end process;
end beh;
