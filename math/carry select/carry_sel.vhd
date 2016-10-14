library IEEE;
use IEEE.std_logic_1164.all;

entity carry_sel is
	generic(
		SIZE : integer := 4		-- operand bit size
	);
	port(
		cin : in std_logic;
		a, b : in std_logic_vector(SIZE-1 downto 0);
		sums : out std_logic_vector(SIZE-1 downto 0)
	);
end carry_sel;

architecture struct of carry_sel is
	component rca is
		generic (NBIT  :	integer := 8;
				DRCAS : 	Time := 0 ns;  -- sum delay
				DRCAC : 	Time := 0 ns); -- carry out delay
		Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
			B:	In	std_logic_vector(NBIT-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(NBIT-1 downto 0);
			Co:	Out	std_logic);
	end component;

	component MUX21 is
	generic (NBIT : integer := 8;
                 DLY  : time    := 1 ns);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0)
		);
	end component;

	constant one : std_logic := '1';
	constant zero : std_logic := '0';
	signal out0 : std_logic_vector(SIZE-1 downto 0);
	signal out1 : std_logic_vector(SIZE-1 downto 0);
begin

	umux : MUX21 generic map (SIZE) port map (out1, out0, cin, sums);	-- output equal to out1 when select == 1
	urca0 : rca generic map (SIZE) port map (a, b, zero, out0);
	urca1 : rca generic map (SIZE) port map (a, b, one, out1);

end struct;

configuration cfg_carrysel_struct of carry_sel is
	for struct
		for all: rca
			use configuration WORK.CFG_RCA_STRUCTURAL_GEN;
		end for;
		for umux : MUX21
			use configuration WORK.CFG_MUX21_STRUCTURAL_GEN;
		end for;
	end for;
end configuration cfg_carrysel_struct;


