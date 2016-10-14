library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity RAM is
  generic(
    nadd : natural := 10;
    n : natural := 32         -- 32-bit words
    size : natural := 1024    -- 1kByte RAM
  );
  port(
    addr : in std_logic_vector(nadd-1 downto 0);
    dout : out std_logic_vector(n-1 downto 0);
    din : in std_logic_vector(n-1 downto 0);
    en : in std_logic;
    clk, rst : in std_logic;
    rw : in std_logic  -- 0 read / 1 write
  );
end RAM;

architecture beh of RAM is
  type mem is array (0 to size-1) of std_logic_vector(n-1 downto 0);
  signal content : mem;
  begin

    writep : process(clk)
    if(clk = '1' and clk'event) then
        if(rst = '1') then          -- erase all contents
          content <= (others => (others => '0'));
        elsif(en = '1' and rw = '1') then
          content(conv_integer(addr)) <= din;
        end if;
    end if;
  end process;

    readp : process(rw, addr, en)
    begin
      if(en = '1' and rw = '0') then
        dout <= content(conv_integer(addr));
      else
        dout <= (others => 'Z');
      end if;
    end process;
end beh;
