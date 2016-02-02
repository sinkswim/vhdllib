library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity downcounter is
  generic(n : natural := 16);
  port(
    clk, rst : in std_logic;
    cnt : in std_logic;
    val : out std_logic_vector(n-1 downto 0);
    tc : out std_logic
  );
end downcounter;

architecture beh of downcounter is
  signal internal : unsigned(n-1 downto 0);
  begin
    process(clk)
    begin
      if(clk ='1' and clk'event) then
        if(rst = '1') then
          internal <= (others => '1');
        elsif(cnt = '1') then
          internal <= internal - 1;
        end if;
      end if;
    end process;

    val <= std_logic_vector(internal);
    tc <= '1' when internal = X"0000" else '0';
end beh;

architecture struct of downcounter is

  component register is
    generic(n : natural := 8);
    port(
      I : in std_logic_vector(n-1 downto 0);
      ld : in std_logic;
      clk, rst : in std_logic;
      Q : out std_logic_vector(n-1 downto 0)
    );
  end component;

  component and_gen is
    generic(n : natural := 8);
    port(
      x : in std_logic_vector(n-1 downto 0);
      y : out std_logic
    );
  end component;

  component incrementer is
    generic(n : natural := 8);
    port(
      x : std_logic_vector(n-1 downto 0);
      y : std_logic_vector(n-1 downto 0)
    );
  end component;

  signal temp, internal : std_logic_vector(n-1 downto 0);
  begin
    reg : register generic map (n) port map (internal, cnt, clk, rst, temp);
    andgate : and_gen generic map (n) port map (temp, tc);
    inc : incrementer generic map (n) port map(temp, internal);
    val <= temp;
end struct;
