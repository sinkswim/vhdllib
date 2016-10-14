----------------------------------------------------------------------------
-- Generic MUX 5 to 1
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux51 is
  generic(
    N : integer := 8
    );
  port(
     in1, in2, in3, in4, in5 : in std_logic_vector(N-1 downto 0);
     sel : in std_logic_vector(2 downto 0);
     mux_out : out std_logic_vector(N-1 downto 0)
    );
end mux51;


architecture beh of mux51 is

begin  -- beh
  
  MUX51Comb_logic: process (in1,in2,in3,in4,in5,sel)
  begin
	case sel is
	when "000"  => mux_out <= in1;      -- 0
	when "001"  => mux_out <= in2;      -- +A
	when "010"  => mux_out <= in3;      -- -A
	when "011"  => mux_out <= in4;      -- +2A
	when "100"  => mux_out <= in5;      -- -2A
	when others => mux_out <= (others => 'Z');
	end case;
  end process;
  

end beh;
