----------------------------------------------------------------------------------
-- Window Register File: This unit contains 3 sub-units
-- 1) RF_CU : Register File control unit
-- 2) RFMU  : Register File managment unit
-- 3) register_file : Physical register file (bank of registers)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constants.all;


-------------------------------------------------------------------------------------------
-- Assumptions:
-- 1) Signals Fill/Spill control also sort of MUX/DEMUX such that data to/from memory are
-- sent directly to the reg file (no wait states!)
-- 2) All Read/Write operations occur within the same block (GLOBALS/IN/LOCAL/OUT).
-------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


entity WRF is
		generic (
						REGNUM   : natural := SIZE_RF;
						WIDTH    : natural := REGWIDTH;
						ADDRSIZE : natural := ADDR_SIZE
		);
		
		port (
				 -- INPUTS
				 CLK: 			IN std_logic;
				 RST: 			IN std_logic;
				 ENABLE: 		IN std_logic;
				 RD1: 			IN std_logic;										-- Read enable on read port 1 from main cu
				 RD2: 			IN std_logic;										-- Read enable on read port 2 from main cu
				 WR: 				IN std_logic;										-- Write enable on write port from main cu
				 CALL, RET:		IN std_logic;										-- Call/Return signals from main cu
				 ADD_WR: 	   IN std_logic_vector(ADDRSIZE-1 downto 0); -- Address generted from the main cu
				 ADD_RD1: 	   IN std_logic_vector(ADDRSIZE-1 downto 0); -- Address generted from the main cu
				 ADD_RD2: 	   IN std_logic_vector(ADDRSIZE-1 downto 0); -- Address generted from the main cu
				 DATAIN: 	   IN std_logic_vector(WIDTH-1 downto 0);    -- Data coming from memory/main cu
				 -- OUTPUTS
				 FILL, SPILL:  OUT std_logic;										-- control signals to MMU, RFMU and MUX/DEMUX
				 OUT1: 		   OUT std_logic_vector(WIDTH-1 downto 0);   -- output of read port 1
				 OUT2: 		   OUT std_logic_vector(WIDTH-1 downto 0)  	-- output of read port 2			 
		);

end WRF;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


architecture Behavioral of WRF is

-----------------------------
-- Components declarations
-----------------------------

-- Register File Control Unit
component RF_CU is
generic (ADDRSIZE : natural := ADDR_SIZE);
port (
          -- INPUTS
			 CLK: 			IN std_logic;
			 RST: 			IN std_logic;
			 ENABLE: 		IN std_logic;
			 RD1: 			IN std_logic;										-- Read enable on read port 1 from main cu
			 RD2: 			IN std_logic;										-- Read enable on read port 2 from main cu
			 WR: 				IN std_logic;										-- Write enable on write port from main cu
		    CALL, RET:		IN std_logic;										-- Call/Return signals from main cu
			 -- OUTPUTS
			 FILL, SPILL:  OUT std_logic;										-- control signals to MMU, RFMU and MUX/DEMUX
			 INT_RD1: 		OUT std_logic;										-- Read enable signal controlled by the RF CU (to perfomr operations such as SPILL)
			 INT_RD2: 		OUT std_logic;									
			 INT_WR: 		OUT std_logic;										-- Write enable signal controller by the RF CU (to perform operations such as FILL)	
			 CWP_OUT:		OUT std_logic_vector(ADDRSIZE-1 downto 0);
			 SWP_OUT:		OUT std_logic_vector(ADDRSIZE-1 downto 0);
			 ADDRESS_CU:   OUT std_logic_vector(ADDRSIZE-1 downto 0) -- Address generated to spill/fill to/from memory
	);
end component;


-- Register File Managment Unit
component RFMU is
	generic (
				ADDRSIZE : natural := ADDR_SIZE
				);
	port(
			-- INPUT PORTS
			ADDR_R1 : in std_logic_vector(ADDRSIZE-1 downto 0);	-- address of read port 1
			ADDR_R2 : in std_logic_vector(ADDRSIZE-1 downto 0);   -- addr of read port 2
			ADDR_W1 : in std_logic_vector(ADDRSIZE-1 downto 0);   -- addr of write port 1
			ADDR_CU : in std_logic_vector(ADDRSIZE-1 downto 0);   -- addr coming from the RF CU
			CWP_in  : in std_logic_vector(ADDRSIZE-1 downto 0);   -- current value of CWP regs
			SWP_in  : in std_logic_vector(ADDRSIZE-1 downto 0);   -- current value of SWP regs
			SPILL   : in std_logic;
			FILL    : in std_logic;
			-- OUTPUT PORTS
			INT_ADDR_R1 : out std_logic_vector(ADDRSIZE-1 downto 0);	-- address of read port 1
			INT_ADDR_R2 : out std_logic_vector(ADDRSIZE-1 downto 0);   -- addr of read port 2
			INT_ADDR_W1 : out std_logic_vector(ADDRSIZE-1 downto 0)    -- addr of write port 1
		  );
end component;

-- Register File
component register_file is
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
end component;

-- Interconnection Signals

signal INT_FILL, INT_SPILL, INT_RD1, INT_RD2, INT_WR : std_logic;
signal CWP_OUT, SWP_OUT                      : std_logic_vector(ADDR_SIZE-1 downto 0); 
signal ADDRESS_CU                            : std_logic_vector(ADDR_SIZE-1 downto 0); 
signal OUT_ADDR_R1, OUT_ADDR_R2, OUT_ADDR_W1 : std_logic_vector(ADDR_SIZE-1 downto 0);
	


begin

	-- Components Instatiations
	uut_CU: RF_CU generic map (ADDR_SIZE) PORT MAP (
			-- INPUTS
			CLK => CLK,
			RST => RST,
			ENABLE => ENABLE,
			RD1 => RD1,
			RD2 => RD2,
			WR => WR,
			CALL => CALL,
			RET => RET,
			-- OUTPUTS
			FILL => INT_FILL,
			SPILL => INT_SPILL,
			INT_RD1 => INT_RD1,
			INT_RD2 => INT_RD2,
			INT_WR => INT_WR,
			CWP_OUT => CWP_OUT,
			SWP_OUT => SWP_OUT,
			ADDRESS_CU => ADDRESS_CU
			);

	uut_MU: RFMU generic map (ADDR_SIZE) PORT MAP (
			-- INPUT PORTS from CPU
			ADDR_R1 => ADD_RD1,			
			ADDR_R2 => ADD_RD2,			
			ADDR_W1 => ADD_WR,	
			-- INPUT PORTS from CONTROL UNIT	
			ADDR_CU => ADDRESS_CU,		
			CWP_in  => CWP_OUT,
			SWP_in  =>SWP_OUT ,
			SPILL  => INT_SPILL,
			FILL   => INT_FILL,
			-- OUTPUT PORTS
			INT_ADDR_R1 => OUT_ADDR_R1,
			INT_ADDR_R2 => OUT_ADDR_R2,
			INT_ADDR_W1 => OUT_ADDR_W1
		  );

	uut_RF: register_file generic map (SIZE_RF, REGWIDTH, ADDR_SIZE) port map (
		-- INPUTS
		CLK => CLK,
		RESET => RST,
		ENABLE => ENABLE,		-- enable signal shared with the rf control unit
		RD1 => INT_RD1,		-- from cu
		RD2 => INT_RD2,		-- from cu
		WR => INT_WR,			-- from cu
		ADD_WR =>	OUT_ADDR_W1,		-- from RFMU
		ADD_RD1 => OUT_ADDR_R1,			-- from RFMU
		ADD_RD2 => OUT_ADDR_R2,			-- from RFMU
		DATAIN => DATAIN,
		-- OUTPUTS
		OUT1 => OUT1,
		OUT2 => OUT2
	);
	
	
	FILL  <= INT_FILL;
	SPILL <= INT_SPILL;


end Behavioral;

