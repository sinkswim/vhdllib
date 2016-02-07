library ieee;
use ieee.std_logic_1164.all;

entity register is
  generic(n : natural := 8);
  port(
    I : in std_logic_vector(n-1 downto 0);
    ld : in std_logic;
    clk, rst : in std_logic;
    Q : out std_logic_vector(n-1 downto 0)
  );
end register;

-- synchronous reset
architecture beh of register is
  signal R : std_logic_vector(n-1 downto 0);
begin
  process(clk)
  begin
    if(clk = '1' and clk'event)
      if(rst = '1')
        R <= (others => '0');
      elsif(ld = '1')
        R <= I;
      end if;
    end if;
  end process;
  Q <= R;
end beh;

architecture gen of register is
  component dflop is
    port(
      D : in std_logic;
      clk, rst : in std_logic;
      Q : out std_logic
    );
  end component;
begin
  for i in 0 to n-1 generate
    dff : dflop port map (I(i) , clk, rst, Q(i));   -- choose beh1 or beh2 
  end generate;
end gen;
