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
