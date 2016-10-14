------------------------------------------------------------------------------------------------------
-- Register File
-- NOTE: Forwarding whenever a read and a write occur on the same register
------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.all;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------


entity register_file is
 generic (
				REGNUM   : natural := 32;
				WIDTH    : natural := 64;
				ADDRSIZE : natural := 5
	);
 port (
			 -- INPUTS
			 CLK: 		IN std_logic;
			 RESET: 		IN std_logic;
			 ENABLE: 	IN std_logic;
			 RD1: 		IN std_logic;
			 RD2: 		IN std_logic;
			 WR: 			IN std_logic;
			 ADD_WR: 	IN std_logic_vector(ADDRSIZE-1 downto 0);
			 ADD_RD1: 	IN std_logic_vector(ADDRSIZE-1 downto 0);
			 ADD_RD2: 	IN std_logic_vector(ADDRSIZE-1 downto 0);
			 DATAIN: 	IN std_logic_vector(WIDTH-1 downto 0);
			 -- OUTPUTS
			 OUT1: 		OUT std_logic_vector(WIDTH-1 downto 0);
			 OUT2: 		OUT std_logic_vector(WIDTH-1 downto 0));
end register_file;


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------


architecture A of register_file is

-- Signals Declarations
subtype REG_ADDR is natural range 0 to REGNUM-1; -- using natural type
type REG_ARRAY is array(REG_ADDR) of std_logic_vector(WIDTH-1 downto 0); 
signal REGISTERS : REG_ARRAY; 

	
begin

	-----------------------------------------
	-- Name: Read proc
	-- Purpose: It describes the read operation
	-- Type: Sequential
	-----------------------------------------
	read_proc: process(CLK)
	begin
		if (CLK'EVENT and CLK = '1') then
			if(ENABLE = '1') then
				if(RD1 = '1') then
					-- forwarding
					if (ADD_RD1 = ADD_WR) then
						OUT1 <= DATAIN;
					else
						OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
					end if;
				else
					OUT1 <= (others=>'Z');
				end if;
				if(RD2 = '1') then
					-- forwarding
					if (ADD_RD2 = ADD_WR) then
						OUT2 <= DATAIN;
					else
						OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
					end if;
				else
					OUT2 <= (others=>'Z');
				end if;
			else
				OUT1 <= (others => 'Z');
				OUT2 <= (others => 'Z');
			end if;
		end if;
	end process read_proc;
	
	-----------------------------------------
	-- Name: Write Proc
	-- Purpose: It describes the write operation
	-- Type: Sequential
	-----------------------------------------
	write_proc: process(CLK)
	begin
		if(CLK'EVENT and CLK = '1') then
			if(RESET = '1') then
				REGISTERS <= (others=>(others=>'0'));
			elsif(ENABLE = '1') then
					if(WR = '1') then
						REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
					end if;
				
			end if;
		end if;
	end process write_proc;


end A;

----


configuration CFG_RF_BEH of register_file is
  for A
  end for;
end configuration;
