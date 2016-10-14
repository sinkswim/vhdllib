-- accumulator, structural/behavioral implementation, lab1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ACC is
	generic (numBit : integer := 64);
    port (
      A          : in  std_logic_vector(numBit - 1 downto 0);
      B          : in  std_logic_vector(numBit - 1 downto 0);
      CLK        : in  std_logic;
      RST_n      : in  std_logic;
      ACCUMULATE : in  std_logic;
      Y          : out std_logic_vector(numBit - 1 downto 0));
 end ACC;


architecture beh of ACC is

	signal regTomux : std_logic_vector(numBit-1 downto 0);
	signal muxToadder : std_logic_vector(numBit-1 downto 0);
	signal adderToreg : std_logic_vector(numBit-1 downto 0);

begin

	REG: process (CLK, RST_n)
	begin
		if (RST_n = '1') then
			regTomux <= (others => '0');
		elsif (CLK = '1' and CLK'event) then
			regTomux <= adderToreg;
		end if;
	end process REG;

	RCA: process (A, muxToadder)
	begin
		adderToreg <= std_logic_vector(unsigned(A) + unsigned(muxToadder));
	end process;
	
	MUX: process(regTomux, B, ACCUMULATE)
	begin
		if (ACCUMULATE = '1') then
			muxToadder <= regToMux;
		elsif (ACCUMULATE = '0') then
			muxToadder <= B;
		else 
			muxToadder <= (others => 'Z');
		end if;
	end process;

	Y <= regTomux;
end beh;


architecture struct of ACC is

component RCA  
	generic (NBIT  :	integer := 8;
		 DRCAS : 	Time := 0 ns;  -- sum delay
	         DRCAC : 	Time := 0 ns); -- carry out delay
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(NBIT-1 downto 0);
		Co:	Out	std_logic);
end component;

component MUX21 
	generic (NBIT : integer := 8;
                 DLY  : time    := 1 ns);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0)
		);
end component;

component reg_gen 
  
  generic (
    NBIT : integer := 8);               -- size of the register

  port (
    A     : in  std_logic_vector (NBIT-1 downto 0);  -- primary input
    B     : out std_logic_vector (NBIT-1 downto 0);  -- primary output
    clock : in  std_logic;                           -- clock source
    reset : in  std_logic);                          -- reset signal

end component;

signal regTomux : std_logic_vector(numBit-1 downto 0);
signal muxToadder : std_logic_vector(numBit-1 downto 0);
signal adderToreg : std_logic_vector(numBit-1 downto 0);

begin

	MUX: MUX21 generic map (numBit) port map (regTomux, B, ACCUMULATE, muxToadder);
	REG: reg_gen generic map(numBit) port map (adderToreg, regTomux, CLK, RST_n);
	RCA0: RCA generic map(numBit) port map (A, muxToadder, '0', adderToreg); 	
	Y <= regTomux;

end struct;



configuration CFG_ACC_BEH of ACC is
	   for BEH
	   end for; 
end CFG_ACC_BEH;



configuration CFG_ACC_STRUCT of ACC is
	   for STRUCT
		for MUX: MUX21 use configuration work.CFG_MUX21_STRUCTURAL_GEN;
		end for;
		for REG: reg_gen use configuration work.cfg_reg_async;
		end for;
		for RCA0: RCA use configuration work.CFG_RCA_STRUCTURAL_GEN;
		end for;
	   end for; 
end CFG_ACC_STRUCT;
