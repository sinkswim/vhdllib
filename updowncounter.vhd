library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity updowncounter is
  generic(n : natural := 16);
  port(
    clk, rst : in std_logic;
    dir : in std_logic;     -- 1 up / 0 down
    cnt : in std_logic;
    val : out std_logic_vector(n-1 downto 0);
    tc : out std_logic
  );
end updowncounter;

architecture beh of updowncounter is
  signal internal : unsigned(n-1 downto 0);
  begin
    process(clk)
    begin
      if(clk ='1' and clk'event) then
        if(rst = '1' and dir = '0') then
          internal <= (others => '1');
        elsif(rst = '1' and dir = '1') then
            internal <= (others => '0');
        end if;
        if(cnt = '1' and dir ='0') then
          internal <= internal - 1;
        elsif(cnt = '1' and dir ='1') then
          internal <= internal + 1;
        end if;
      end if;
    end process;

    val <= std_logic_vector(internal);
    tc <= '1' when ((internal = X"0000" and dir = '0') or (internal = X"FFFF" and dir = '1')) else '0';
end beh;
