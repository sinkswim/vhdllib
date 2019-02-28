library ieee;
use ieee.std_logic_1164.all;

entity reg is
	generic(N: positive := 8);
	port(
		d: in std_logic_vector(N-1 downto 0);
		ld: in std_logic;
		clk: in std_logic;
		q: out std_logic_vector(N-1 downto 0)
	);
end reg;

architecture beh of reg is
begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(ld = '1') then
				q <= d;
			end if;
		end if;
	end process;
end beh;