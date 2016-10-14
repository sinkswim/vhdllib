library ieee;
use ieee.std_logic_1164.all;

entity shlreg is
  generic(n : natural := 8);
  port(
    sh_en : in std_logic;
    clk, rst : in std_logic;
    Q : out std_logic_vector(n-1 downto 0)
  );
end shlreg;

architecture beh of shlreg is
  signal R : std_logic_vector(n-1 downto 0);
begin
  process(clk)
  begin
    if(clk ='1' and clk'event)
      if(rst = '1')
        R <= (others => '0');
      elsif(sh_en = '1')
        R(0) <= R(n-1);
        for i in 0 to n-2 loop
          R(i+1) <= R(i);
        end loop;
      end if;
    end if;
  end process;
  Q <= R;
end beh;
