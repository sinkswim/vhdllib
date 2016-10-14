----------------------------------------------------------------------------------
-- RF Contro Unit
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.all;

-------------------------------------------------------------------------------------------
-- Assumptions:
-- 1) Signals Fill/Spill control also sort of MUX/DEMUX such that data to/from memory are
-- sent directly to the reg file (no wait states!)
-- 2) All Read/Write operations occur within the same block (GLOBALS/IN/LOCAL/OUT).
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

entity RF_CU is
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
end RF_CU;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

architecture Behavioral of RF_CU is

-- Signals Declarations

type state_type is (RESET, WSUB, CHECK_SPILL, SPILL_STATE1, SPILL_STATE2, INC_SWP, INC_CWP, CHECK_FILL, FILL_STATE1, FILL_STATE2, DEC_SWP, DEC_CWP);
-- STATE REG
signal current_state : state_type;
signal next_state    : state_type;
-- CWP REG
signal current_CWP : std_logic_vector(ADDRSIZE-1 downto 0);
signal next_CWP    : std_logic_vector(ADDRSIZE-1 downto 0);
-- SWP REG
signal current_SWP : std_logic_vector(ADDRSIZE-1 downto 0);
signal next_SWP    : std_logic_vector(ADDRSIZE-1 downto 0);
-- ADDR_CU REG
signal current_ADDR_CU : std_logic_vector(ADDRSIZE-1 downto 0);
signal next_ADDR_CU    : std_logic_vector(ADDRSIZE-1 downto 0);

begin

	-----------------------------------------
	-- Name: Regs
	-- Purpose: It represents the bank of 
	-- registers
	-- Type: Sequential
	-----------------------------------------
	Regs: process(CLK, RST)
	begin
		if (CLK = '1' and CLK'event) then

			if (RST = '1') then

				current_state   <= RESET;
				current_CWP     <= std_logic_vector(to_unsigned(M, ADDRSIZE));
				current_SWP     <= std_logic_vector(to_unsigned(M, ADDRSIZE));
				current_ADDR_CU <= std_logic_vector(to_unsigned(M, ADDRSIZE));

			else

				current_state   <= next_state;
				current_CWP     <= next_CWP;
				current_SWP     <= next_SWP;
				current_ADDR_CU <= next_ADDR_CU;

			end if;

		end if;

	end process;


	-----------------------------------------
	-- Name: Comb Logic
	-- Purpose: It describes the comb
   --	logic of RF CU
	-- Type: Combinational
	-----------------------------------------
	Comb_logic: process (ENABLE, RD1, RD2, WR, CALL, RET, current_state, current_CWP, current_SWP, current_ADDR_CU)
	-- variable declarations
	variable can_save    : integer range 0 to F-1 := F-2;
	variable can_restore : integer range 0 to F-1 := 1;
	begin

		-- default signal assignments
		next_CWP     <= current_CWP;
		next_SWP     <= current_SWP;
		next_ADDR_CU <= current_ADDR_CU;
		
		case current_state is

					when RESET =>

						FILL    <= '0';
						SPILL   <= '0';
						INT_RD1 <= '0';
						INT_RD2 <= '0';
						INT_WR  <= '0';

						if (ENABLE = '1') then
							next_state <= WSUB;
						else
							next_state <= RESET;
						end if;

					-- WSUB: within a subroutine simply check if a call/return signals are received
					when WSUB =>

						FILL    <= '0';
						SPILL   <= '0';
						INT_RD1 <= RD1;
						INT_RD2 <= RD2;
						INT_WR  <= WR;

						if (CALL = '1') then
							next_state <= CHECK_SPILL;
						elsif (RET = '1') then
							next_state <= CHECK_FILL;
						else
							next_state <= WSUB;
						end if;

					-- CHECK_SPILL: perform a spill to memory if CWP+4*N == SWP
					when CHECK_SPILL =>
						
						can_save := can_save - 1;
						can_restore := can_restore + 1;

						FILL    <= '0';
						SPILL   <= '0';
						INT_RD1 <= RD1;
						INT_RD2 <= RD2;
						INT_WR  <= WR;


						if (can_save = 0) then
							next_state <= SPILL_STATE1;
						else
							next_state <= INC_CWP;
						end if;

					-- SPILL_STATE: raise SPILL signal to 1, raise INT_RD1 to 1 (design decision to perform spills reading from read port 1): check the address value
					when SPILL_STATE1 =>

						FILL    <= '0';
						SPILL   <= '1';
						INT_RD1 <= '1';
						INT_RD2 <= '0';
						INT_WR  <= '0';

						
						if (current_ADDR_CU = std_logic_vector(to_unsigned(M + 2*N - 1,ADDR_SIZE))) then
							next_state <= INC_SWP;
						else
							next_state <= SPILL_STATE2;
						end if;
					
					-- SPILL_STATE2: increment the address
					when SPILL_STATE2 =>

						FILL    <= '0';
						SPILL   <= '1';
						INT_RD1 <= '1';
						INT_RD2 <= '0';
						INT_WR  <= '0';

						next_ADDR_CU <= std_logic_vector(unsigned(current_ADDR_CU) + 1);

						next_state <= SPILL_STATE1;
						

					-- INC_SWP: the spill is done so increment the SWP so it points to the next window block
					when INC_SWP =>
						
						can_save := can_save + 1;
						can_restore := can_restore - 1;
						
						FILL    <= '0';
						SPILL   <= '1';				
						INT_RD1 <= '1';
						INT_RD2 <= '0';
						INT_WR  <= '0';

						next_ADDR_CU <= std_logic_vector(to_unsigned(M, ADDRSIZE)); -- bring back the address to M
						next_SWP <= std_logic_vector(unsigned(current_SWP) + to_unsigned(2*N, ADDR_SIZE));

						next_state <= INC_CWP;

					-- INC_CWP: before going to WSUB adjust CWP to the new correct value
					when INC_CWP =>

						FILL    <= '0';
						SPILL   <= '0';
						INT_RD1 <= '0';
						INT_RD2 <= '0';
						INT_WR  <= '0';

						-- check if the value of CWP is the last window, if so add 2N and M as well (to do a correct roll-back)
						if ( current_CWP = std_logic_vector(to_unsigned(CWP_last, ADDR_SIZE)) ) then
							next_CWP <= std_logic_vector(unsigned(current_CWP) + to_unsigned(2*N, ADDR_SIZE) + to_unsigned(M, ADDR_SIZE));
						else
							next_CWP <= std_logic_vector(unsigned(current_CWP) + to_unsigned(2*N, ADDR_SIZE));
						end if;

						next_state <= WSUB;

					-- CHECK_FILL: perform a FILL from memory if can_restore = 0
					when CHECK_FILL =>

						can_restore := can_restore - 1;
						can_save := can_save + 1;

						FILL    <= '0';
						SPILL   <= '0';
						INT_RD1 <= RD1;
						INT_RD2 <= RD2;
						INT_WR  <= WR;

						if (can_restore = 0) then
						  next_state <= FILL_STATE1;
						else
						  next_state <= DEC_CWP;
						end if;

					-- FILL_STATE1: raise FILL signal to 1, raise INT_WR to 1; check address value
					when FILL_STATE1 =>

						FILL    <= '1';
						SPILL   <= '0';
						INT_RD1 <= '0';
						INT_RD2 <= '0';
						INT_WR  <= '1';

						
						 if (current_ADDR_CU = std_logic_vector(to_unsigned(M + 2*N - 1,ADDR_SIZE))) then
							next_state <= DEC_SWP;
						 else
							next_state <= FILL_STATE2;
						 end if;
					
					-- FILL_STATE2: increment the address
					when FILL_STATE2 =>

						FILL    <= '1';
						SPILL   <= '0';
						INT_RD1 <= '0';
						INT_RD2 <= '0';
						INT_WR  <= '1';

						
						next_ADDR_CU <= std_logic_vector(unsigned(current_ADDR_CU) + 1);

						next_state <= FILL_STATE1;


					-- DEC_SWP: the fill is done so decrement the SWP so it points to the previous window block
					when DEC_SWP =>
						
						can_restore := can_restore + 1;
						can_save := can_save - 1;
						
						FILL    <= '1';				
						SPILL   <= '0';
						INT_RD1 <= '0';
						INT_RD2 <= '0';
						INT_WR  <= '1';

						next_ADDR_CU <= std_logic_vector(to_unsigned(M, ADDRSIZE)); -- bring back the address to M
						next_SWP <= std_logic_vector(unsigned(current_SWP) - to_unsigned(2*N, ADDR_SIZE));

						next_state <= DEC_CWP;

					-- DEC_CWP: before going to WSUB adjust CWP to the new correct value
					when DEC_CWP =>
				
			
						FILL    <= '0';
						SPILL   <= '0';
						INT_RD1 <= '0';
						INT_RD2 <= '0';
						INT_WR  <= '0';

						next_CWP <= std_logic_vector(unsigned(current_CWP) - to_unsigned(2*N, ADDR_SIZE));

						next_state <= WSUB;

						-- in all other cases go to the RESET state (safe FSM)
						when others =>

							 next_state <= RESET;

		end case;

	end process;

	-- cuncurrent signal assignment
	CWP_OUT <= current_CWP;
	SWP_OUT <= current_SWP;
	ADDRESS_CU <= current_ADDR_CU;

end Behavioral;
