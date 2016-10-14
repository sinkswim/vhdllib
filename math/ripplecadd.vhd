-- classic ripple carry adder (first stage is a half adder)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned;
use ieee.numeric_std.all;

entity ripplecadd is
  generic(n : natural := 8);
  port(
    A : in std_logic_vector(n-1 downto 0);
    B : in std_logic_vector(n-1 downto 0);
    S : out std_logic_vector(n-1 downto 0);
    cout : out std_logic
  );
end ripplecadd;

architecture struct of ripplecadd is

  component halfadd is
    port(
      a, b : in std_logic;
      s, cout : out std_logic
    );
  end component;

  component fulladd is
    port(
      a, b, cin : in std_logic;
      s, cout : out std_logic
    );
  end component;

  signal carries : std_logic_vector(n-2 downto 0);
  begin
    ha : halfadd port map (A(0), B(0), S(0), carries(0));
    for i in 1 to n-2 generate
      fa: fulladd port map (A(i), B(i), carries(i-1), S(i), carries(i));
    end generate;
    last : fulladd port map (A(n-1), B(n-1), carries(n-2), S(n-1), cout;
end struct;

architecture beh of ripplecadd is
begin
    process(A, B)
      variable vA : std_logic_vector(n downto 0);
      variable vB : std_logic_vector(n downto 0);
      variable vS : std_logic_vector(n downto 0);
    begin
      vA := '0'&A;
      vB := '0'&B;
      vS := vA + vB;
      cout <= vS(n);
      R <= vS(n-1 downto 0);
    end process;

end beh;
