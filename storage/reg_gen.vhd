-- register (asynchronous, synchronous) with generic, lab 1
library ieee;
use ieee.std_logic_1164.all;

entity reg_gen is
  
  generic (
    NBIT : integer := 8);               -- size of the register

  port (
    A     : in  std_logic_vector (NBIT-1 downto 0);  -- primary input
    B     : out std_logic_vector (NBIT-1 downto 0);  -- primary output
    clock : in  std_logic;                           -- clock source
    reset : in  std_logic);                          -- reset signal

end reg_gen;

architecture reg_syn of reg_gen is

  component FD is
	Port (	D:	In	std_logic;
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic);
  end component;
  
begin  -- reg_sync

   gen_dfp: for i in 0 to NBIT-1 generate
     DFP: FD port map (A(i), clock, reset,B(i));
   end generate gen_dfp; 

end reg_syn;

architecture reg_asyn of reg_gen is

  component FD is
	Port (	D:	In	std_logic;
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic);
  end component;
  
begin  -- reg_async

   gen_dfp: for i in 0 to NBIT-1 generate
     DFP: FD port map (A(i), clock, reset,B(i));
   end generate gen_dfp; 

end reg_asyn;

configuration cfg_reg_sync of reg_gen is
  for reg_syn
    for gen_dfp
      for all: FD
        use configuration  work.CFG_FD_PIPPO;
      end for;
    end for;
  end for;
end cfg_reg_sync;


configuration cfg_reg_async of reg_gen is
  for reg_asyn
    for gen_dfp
      for all: FD
        use configuration  work.CFG_FD_PLUTO;
      end for;
    end for;
  end for;
end cfg_reg_async;


