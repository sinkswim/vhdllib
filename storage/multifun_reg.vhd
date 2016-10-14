library ieee;
use ieee.std_logic_1164.all;

entity multifun_reg is
  generic(
    n : natural := 8
  );
  port(
    clk, rst : in std_logic;
    I : in std_logic_vector(n-1 downto 0);
    O : out std_logic_vector(n-1 downto 0);
    ld, shl, shr: in std_logic;
    shin : in std_logic
  );
end multifun_reg;

-- multifun_reg with implicitly decoded commands
-- in a structural approach a comb circ is in charge of
-- decoding the ld, shl, shr commands into S(x downto 0)
-- lines that drive a mux for each internal flip flop
architecture beh of multifun_reg is
  signal R : std_logic_vector(n-1 downto 0);
  begin
    process(clk)
    begin
      if(clk ='1' and clk'event) then
        if(rst = '1') then
          R <= (others => '0');
        elsif (ld = '1') then
          R <= I;
        elsif (shl = '1') then
          R(0) <= shin;
          for i in 0 to n-2 loop
            R(i + 1) <= R(i);
          end loop;
        elsif (shr = '1') then
          R(n-1) <= shin;
          for i in 0 to n-2 loop
            R(i) <= R(i + 1);
          end loop;
        -- in other case internal value is kept
        end if;
      end if;
    end process;
    O <= R;
end beh;
