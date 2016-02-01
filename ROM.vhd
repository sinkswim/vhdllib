library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ROM is
  generic(
    nadd : natural := 10;
    n : natural := 32         -- 32-bit words
    size : natural := 1024    -- 1kByte ROM
  );
  port(
    addr : in std_logic_vector(nadd-1 downto 0);
    dout : out std_logic_vector(n-1 downto 0);
    en : in std_logic;
    r : in std_logic  -- 0 nop / 1 read
  );
end ROM;

architecture beh of ROM is
  type mem is array (0 to size-1) of std_logic_vector(n-1 downto 0);
  signal content : mem;
  begin

    readp : process(addr, r, en)
    if(en = '1' and r = '1') then
      dout <= content(conv_integer(addr));
    else
      dout <= (others => 'Z');
    end if;
  end process;

end beh;
