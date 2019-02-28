library ieee;
use ieee.std_logic_1164.all;

entity rtl_ex3 is
	generic(N: positive := 8);
	port(
		lda, ldb: in std_logic;
		s0, s1: in std_logic;
		x, y: in std_logic_vector(N-1 downto 0);
		clk: in std_logic;
		rb: buffer std_logic_vector(N-1 downto 0)
	);
end rtl_ex3;

architecture struct of rtl_ex3 is
	-- declare signals
	signal muxa_out, muxb_out, ra, rb_tmp: std_logic_vector(N-1 downto 0);
	
	-- declare components
	component mux21 is
		generic(N: positive := 8);
		port(
			x, y: in std_logic_vector(N-1 downto 0);
			sel: in std_logic;
			z: out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	component reg is
		generic(N: positive := 8);
		port(
			d: in std_logic_vector(N-1 downto 0);
			ld: in std_logic;
			clk: in std_logic;
			q: out std_logic_vector(N-1 downto 0)
		);
	end component;

begin
	muxa: mux21 port map (x, rb_tmp, s1, muxa_out);
	muxb: mux21 port map (ra, y, s0, muxb_out);
	rega: reg port map (muxa_out, lda, clk, ra);
	regb: reg port map (muxb_out, ldb, clk, rb_tmp);
	
	rb <= rb_tmp;
	
end struct;