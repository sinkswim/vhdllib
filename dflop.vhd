library ieee;
use ieee.std_logic_1164.all;

entity dflop is
port(
  D : in std_logic;
  clk, rst : in std_logic;
  Q : out std_logic
);
end dflop;

architecture beh of dflop is
begin
  process(clk)
  begin
    if(clk = '1' and clk'event) then
      if(rst = '1') then
        Q <= '0';
      else
        Q <= D;
      end if;
    end if;
  end process;
end beh;
