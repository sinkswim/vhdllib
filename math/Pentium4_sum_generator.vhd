library IEEE;
use IEEE.std_logic_1164.all; 

entity sum_generator is
	generic(
		OPSIZE : integer := 32;
		numblocks : integer := 8
	);
	port(
		a, b : in std_logic_vector(OPSIZE-1 downto 0);
		carries : in std_logic_vector(numblocks-1 downto 0);
		sum : out std_logic_vector(OPSIZE-1 downto 0)
	);
end sum_generator;

architecture struct of sum_generator is
	component carry_sel is
		generic(
			SIZE : integer := 4		-- operand bit size
		);
		port(
			cin : in std_logic;
			a, b : in std_logic_vector(SIZE-1 downto 0);
			sums : out std_logic_vector(SIZE-1 downto 0)
		);
	end component;
	
	constant par : integer := OPSIZE/numblocks;

begin
	blocks: for i in 1 to numblocks generate
		ucarrysel : carry_sel generic map (par) port map (carries(i-1), a(par*i-1 downto par*i-par), b(par*i-1 downto par*i-par), sum(par*i-1 downto par*i-par));
	end generate blocks;
end struct;


configuration cfg_sumgen_struct of sum_generator is
	for struct
		for blocks 
			for all : carry_sel
				use configuration WORK.cfg_carrysel_struct;
			end for;
		end for;
	end for;
end configuration cfg_sumgen_struct;