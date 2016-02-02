library ieee;
use ieee.std_logic_1164.all;

entity n16to1mux is
  port(
    sw : in std_logic_vector(3 downto 0);
    x : in std_logic_vector(15 downto 0);
    y : out std_logic
  );
end n16to1mux;

architecture struct of n16to1mux is
  component n4to1mux is
    port(
      sw : in std_logic_vector(1 downto 0);
      x : in std_logic_vector(3 downto 0);
      y : out std_logic
    );
  end component;

  signal internals : std_logic_vector(3 downto 0);
begin
  mux1 : n4to1mux port map (sw(1 downto 0), x(3 downto 0), internals(0));
  mux2 : n4to1mux port map (sw(1 downto 0), x(7 downto 4), internals(1));
  mux3 : n4to1mux port map (sw(1 downto 0), x(11 downto 8), internals(2));
  mux4 : n4to1mux port map (sw(1 downto 0), x(15 downto 12), internals(3));
  mux5 : n4to1mux port map (sw(3 downto 2), internals(3 downto 0), y);
end struct;
