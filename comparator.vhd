library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity comparator is
  generic(
    n : natural := 8
  );
  port(
    a, b : in std_logic_vector(n-1 downto 0);
    res : out std_logic
  );
end comparator;

architecture beh of comparator is
  begin
    process(a, b)
    begin
      if(a = b) then
        res <= '1';
      else
        res <= '0';
      end if;
    end process;
end beh;


-- xnor each bit pair and and all xnor results (signal internals)
architecture struct of comparator is

  component xnor2 is
    port(
      x0, x1 : in std_logic;
      y : out std_logic
    );
  end component;

  component and_gen is
    generic(n : natural := 8);
    port(
      x : in std_logic_vector(n-1 downto 0);
      y : out std_logic
    );
  end component;

  signal internals : std_logic_vector(n-1 downto 0);
  
  begin
    for i in 0 to n-1 generate
      xnori : xnor2(a(i), b(i), internals(i));
    end generate;
    andN : and_gen generic map (n) port map (internals, res);
end struct;
