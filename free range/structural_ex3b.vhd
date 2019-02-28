library ieee;
use ieee.std_logic_1164.all;

entity structural_ex3b is
	port(
		a, b, c: in std_logic;
		f: out std_logic
	);
end structural_ex3b;

architecture struct of structural_ex3b is
	-- declare signals
	signal dec_out: std_logic_vector(7 downto 0);
	
	-- declare components
	component decoder_3to8 is
	port(
		x: in std_logic_vector(2 downto 0);
		z: out std_logic_vector(7 downto 0)
	);
	end component;
	
	component and4 is
	port(
		a, b, c, d: in std_logic;
		z: out std_logic
	);
	end component;

begin
	-- instantiate components
	dec_3to8: decoder_3to8 port map (
		x(0) => a,
		x(1) => b,
		x(2) => c,
		z => dec_out
		);
		
	and_4: and4 port map (
		a => dec_out(0),
		b => dec_out(1),
		c => dec_out(3),
		d => dec_out(4),
		z => f
	);
end struct;