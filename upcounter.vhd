library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity upcounter is
  generic(n : natural := 16);
  port(
    clk, rst : in std_logic;
    cnt : in std_logic;
    val : out std_logic_vector(n-1 downto 0);
    tc : out std_logic
  );
end upcounter;

architecture beh of upcounter is
  signal internal : unsigned(n-1 downto 0);
  begin
    process(clk)
    begin
      if(clk ='1' and clk'event) then
        if(rst = '1') then
          internal <= (others => '0');
        elsif(cnt = '1') then
          internal <= internal + 1;
        end if;
      end if;
    end process;

    val <= std_logic_vector(internal);
    tc <= '1' when internal = X"FFFF" else '0';
end beh;
