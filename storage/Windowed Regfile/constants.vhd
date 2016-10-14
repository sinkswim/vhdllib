----------------------------------------------------------------------------------
-- Useful Constants
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.functions.all;

package constants is

---------------------------------------------------------------------
---------------------------------------------------------------------

---------------------------------------------------------------------
--------------------- CONSTANTS -------------------------------------
---------------------------------------------------------------------
constant M          : integer := 4;				     -- number of globals regs
constant N          : integer := 4;					  -- number of register within each block
constant F 			  : integer := 4;    			  -- number of widonws
constant REGWIDTH   : integer := 32;				  -- bitwidth of a single register in the RF


constant SIZE_RF 	  : integer := (2*N*F) + M; 	  -- total number of registers within the register files
constant ADDR_SIZE  : integer := log2of(SIZE_RF);

constant CWP_LAST   : integer := M + 2*N*(F-1);	  -- address of last windows
constant ADDR_RANGE : integer := M + 2*N;		     -- address that should be mapped at the beginning(used to implement circular buffer)

constant SPILL_SUM  : integer := 4*N;				  -- used to check whether i have to spill or not in RF CU

---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

end constants;

