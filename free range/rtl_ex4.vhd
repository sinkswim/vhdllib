library ieee;
use ieee.std_logic_1164.all;

entity rtl_ex4 is
	generic(N: positive := 6);
	port(
		lda, ldb: in std_logic;
		x, y: in std_logic_vector(N-1 downto 0);
		s0, s1: in std_logic;
		rd: in std_logic;
		clk: in std_logic;
		ra: out std_logic_vector(N-1 downto 0);
		rb: buffer std_logic_vector(N-1 downto 0)
	);
end rtl_ex4;

architecture beh of rtl_ex4 is
	signal muxa_out, muxb_out: std_logic_vector(N-1 downto 0);
begin
	-- mux a
	with s0 select
	muxa_out <= y when '0',
				rb when '1',
				(others => '0') when others;
	
	-- mux b
	with s1 select
	muxb_out <= y when '0',
				x when '1',
				(others => '0') when others;

	-- register a
	rega: process(clk)
	begin
		if(rising_edge(clk)) then
			if(lda = '1' and rd = '1') then
				ra <= muxa_out;
			end if;
		end if;
	end process rega;
	
	-- register b
	regb: process(clk)
	begin
		if(rising_edge(clk)) then
			if(ldb = '1' and rd = '0') then
				rb <= muxb_out;
			end if;
		end if;
	end process regb;
	
end beh;