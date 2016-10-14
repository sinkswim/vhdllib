library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity magn_comp is
  generic(
    n : natural := 8
  );
  port(
    a, b : in std_logic_vector(n-1 downto 0);
    eq, lt, gt : out std_logic    -- lt = '1' means a < b
  );
end magn_comp;

architecture beh of magn_comp is
  begin
    process(a, b)
    begin
      if(a = b) then
        eq <= '1';
        lt <= '0';
        gt <= '0';
      elsif (a > b) then
        eq <= '0';
        lt <= '0';
        gt <= '1';
      elsif (a < b) then
        eq <= '0';
        lt <= '1';
        gt <= '0';
      else
        eq <= '0';
        lt <= '0';
        gt <= '0';
      end if;
    end process;
end beh;


architecture struct of magn_comp is

  component magn_comp_stage is
    port(
      a, b : in std_logic;
      in_eq, in_lt, in_gt : in std_logic;
      out_eq, out_lt, out_gt : out std_logic
    );
  end component;

  signal first_eq : std_logic := '1';
  signal first_lt : std_logic := '0';
  signal first_gt : std_logic := '0';
  signal int_eq : std_logic_vector(n-2 downto 0);
  signal int_lt : std_logic_vector(n-2 downto 0);
  signal int_gt : std_logic_vector(n-2 downto 0);

  begin

    first_stage : magn_comp_stage port map(a(0), b(0), first_eq, first_lt, first_gt, int_eq(0), int_lt(0), int_gt(0));
    for i in 1 to n-2 generate
      stagei : magn_comp_stage port map(a(i), b(i), int_eq(i-1), int_lt(i-1), int_gt(i-1), int_eq(i), int_lt(i), int_gt(i));
    end generate;
    last_stage : magn_comp_stage port map(a(n-1), b(n-1), int_eq(n-2), int_lt(n-2), int_gt(n-2), gt, lt, gt);

end struct;
