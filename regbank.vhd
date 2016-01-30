library ieee;
use ieee.std_logic_1164.all;

entity regbank is
  generic(
    nregs : natural := 16;
    bits : natural := 8
    );
  port(
    I : in std_logic_vector(nregs*bits downto 0);
    clk, rst : in std_logic;
    Q : in std_logic_vector(nregs*bits downto 0)
  );
end regbank;

architecture gen of regbank is
  component register is
    generic(n : natural := 8);
    port(
      I : in std_logic_vector(n-1 downto 0);
      clk, rst : in std_logic;
      Q : out std_logic_vector(n-1 downto 0)
    );
  end component;
begin
  for i in 0 to nregs-1 generate
    reg: register generic map (bits) port map (I(((i*2*bits)-1) downto i*bits), clk, rst, Q(((i*2*bits)-1)downto i*bits);
  end generate;
end gen;
