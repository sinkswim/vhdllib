library ieee;
use ieee.std_logic_1164.all;

entity n2to1mux is
  port(
    sw : in std_logic_vector(1 downto 0);
    x : in std_logic_vector(3 downto 0);
    y : out std_logic
  );
end n2to1mux;

architecture beh of n2to1mux is
  begin
    
    process(sw, x)
    begin
        case sw is
          when "00" =>
            y <= x(0);
          when "01" =>
            y <= x(1);
          when "10" =>
            y <= x(2);
          when "11" =>
            y <= x(3);
          when others =>
            y <= 'Z';
        end case;
    end process;

end beh;
