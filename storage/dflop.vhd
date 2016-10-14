library ieee;
use ieee.std_logic_1164.all;

entity dflop is
port(
  D : in std_logic;
  clk, rst : in std_logic;
  Q : out std_logic
);
end dflop;

-- asynchronous reset
architecture beh1 of dflop is
begin
  process(clk, rst)
  begin
    if(rst = '1') then
      Q <= '0';
    elsif(clk = '1' and clk'event) then
        Q <= D;
    end if;
  end process;
end beh1;

-- synchronous reset
architecture beh2 of dflop is
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
end beh2;
