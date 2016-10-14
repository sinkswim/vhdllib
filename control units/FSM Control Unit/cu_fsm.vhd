-------------------------------------------------------------------------------------------------
-- FSM Control Unit
-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.myTypesFSM.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------------------------
-- Important Note: Some states are shared among different instructions. States shared are those 
-- with the same control signals. Instruction are grouped in 3 groups(see myTypesFSM.vhd).
-- To complete each instruction every 3 clock cycles, one unique DECODE state has been introduced
-- since all instructions belonging to the ISA access the register file for at least one read, so
-- all read ports are activated. It will be up to the MUXs in the EX stage that will select the 
-- right inputs for ALU. 
-- ALUOPCODE is computed at the beginning of the DECODE stage (as soon as the OPCODE and FUNC are
-- available). It will be used only during the EX stage, when the control signals are activated.
-- Disadvantages: probably more power consumption due to:
-- 	- 2 reads will be always performed, even if only one is actually needed.
--     	- ALUOPCODE produced during DECODE can cause the ALU (which is combinational) to switch and
--      produce an output. The output will be taken into account only during the EX stage, and 
--      the ALU will switch the output twice (once during the DECODE and once during the EX)
-- Advantages: 1 clock cycle less for instruction (only 3), and saving area.
-- Possible Improvments: substitue the process ALU_OPCODE with a LUT to reduce the area, latency
-- and probably power. 
-------------------------------------------------------------------------------------------------


entity cu_fsm is
port (
              -- FIRST PIPE STAGE OUTPUTS
              EN1    : out std_logic;               -- enables the register file and the pipeline registers
              RF1    : out std_logic;               -- enables the read port 1 of the register file
              RF2    : out std_logic;               -- enables the read port 2 of the register file
              WF1    : out std_logic;               -- enables the write port of the register file
              -- SECOND PIPE STAGE OUTPUTS
              EN2    : out std_logic;               -- enables the pipe registers
              S1     : out std_logic;               -- input selection of the first multiplexer
              S2     : out std_logic;               -- input selection of the second multiplexer
              ALU1   : out std_logic;               -- alu control bit
              ALU2   : out std_logic;               -- alu control bit
              -- THIRD PIPE STAGE OUTPUTS
              EN3    : out std_logic;               -- enables the memory and the pipeline registers
              RM     : out std_logic;               -- enables the read-out of the memory
              WM     : out std_logic;               -- enables the write-in of the memory
              S3     : out std_logic;               -- input selection of the multiplexer
              -- INPUTS
              OPCODE    : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
              FUNC      : in  std_logic_vector(FUNC_SIZE - 1 downto 0);              
              Clk 	: in std_logic;
              Rst 	: in std_logic);                  -- Active Low
end cu_fsm;


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------



architecture Behavioral of cu_fsm is

-- Signals Declarations
-- States Description:
-- RESET : reset the control unit (status register)
-- DECODE : decode the current instruction
-- R_TYPE_EX : execution stage for RTYPE instructions
-- I_1_TYPE_EX: execution stage for I_1_TYPE instructions (see myTypesFSM.vhd)
-- I_2_TYPE_EX: execution stage for I_2_TYPE instructions (see myTypesFSM.vhd)
-- NO_MEM: state for those instruction that do not access the memory
-- L_MEM: state for those instructions that load data from memory
-- S_MEM: state for those instructions that save data into memory and doesn't require any write access to the register file
type state_type is (RESET, DECODE, R_TYPE_EX, I_1_TYPE_EX, I_2_TYPE_EX, NO_MEM, L_MEM, S_MEM);
signal current_state, next_state : state_type;

-- CW_size = 11, since we have 11 output control signals (ALU1 and ALU2 are generated with another process)
-- Thus the our control word is the following (leftmost is the MSB):
-- |EN1 RF1 RF2 WF1| |EN2 S1 S2| |EN3 RM WM S3|
signal cw   : std_logic_vector(CW_SIZE - 1 downto 0);


begin

	
	-- Assign to each output the CW for the current state
	EN1 <= cw (10);
	RF1 <= cw (9); 
	RF2 <= cw (8);
	WF1 <= cw (7);
	EN2 <= cw (6);
	S1  <= cw (5);
	S2  <= cw (4); 
	EN3 <= cw (3);
	RM  <= cw (2);
	WM  <= cw (1); 
	S3  <= cw (0);
	
	
	-----------------------------------
	-- Name: STATE_REG
	-- Type: Sequential
	-- Purpose: It describes the state
	-- register. Asynchronuos Reset
	-- signal(ACTIVE LOW).
	----------------------------------
	STATE_REG: process (Clk, Rst)
	begin
		
		if (Rst = '0') then
			current_state <= RESET;
		elsif (Clk = '1' and Clk'event) then
			current_state <= next_state;
		end if;
		
	end process;
	
	
	-----------------------------------
	-- Name: COMB LOGIC
	-- Type: Combinational
	-- Purpose: It describes the comb.
	-- logic necessary to produce
	-- the output for each state and
	-- the next_state.
	----------------------------------
	COMB_LOGIC: process (current_state, OPCODE)
	begin
		
		case current_state is
			
			when RESET =>
			
				cw <= CW_RESET;
				next_state <= DECODE;
				
			when DECODE =>
				
				cw <= CW_DECODE;
				
				if (OPCODE = RTYPE) then
					next_state <= R_TYPE_EX;
				elsif ( OPCODE > ITYPE_L_MEM1 ) then
				 next_state <= I_2_TYPE_EX;
				else
					next_state <= I_1_TYPE_EX;
				end if;
			
			when R_TYPE_EX =>
			
				cw <= CW_R_TYPE_EX;
				next_state <= NO_MEM;
			
			when I_1_TYPE_EX =>
			
				cw <= CW_I_1_TYPE_EX;
				
				if (OPCODE = ITYPE_L_MEM1) then
					next_state <= L_MEM;
				else 
					next_state <= NO_MEM;
				end if;
			
			when I_2_TYPE_EX =>
			
				cw <= CW_I_2_TYPE_EX;
				
				if (OPCODE = ITYPE_S_MEM2) then
					next_state <= S_MEM;
				elsif (OPCODE = ITYPE_L_MEM2) then
					next_state <= L_MEM;
				else
					next_state <= NO_MEM;
				end if;
			
			-- NO_MEM is the state associated to WB stage, without memory access
			when NO_MEM =>
			
				cw <= CW_NO_MEM;
				next_state <= DECODE;
			
			when L_MEM =>
			
				cw <= CW_L_MEM;
				next_state <= DECODE;
			
			when S_MEM =>
				
				cw <= CW_S_MEM;
				next_state <= DECODE;
				
			when others =>
			
				cw <= CW_RESET;
				next_state <= RESET;
			
		end case;
		
	end process;
	
	
	-----------------------------------
	-- Name: ALU OPCODE P
	-- Type: Combinational
	-- Purpose: It describes the comb.
	-- logic necessary to produce the
	-- right ALU_OPCODE(ALU1, ALU2)
	----------------------------------
	ALU_OPCODE_P: process (OPCODE,FUNC)
	begin
		-- if I-type ALU_OPCODE depens only on the input OPCODE
		-- if R-type func should be analyzed
		if (OPCODE = std_logic_vector(to_unsigned(0, OP_CODE_SIZE)) ) then
			-- R-TYPE
			case FUNC is
				
				-- ADD, NOP
				when RTYPE_ADD =>
				
					ALU1 <= '0';
					ALU2 <= '0';
				
				-- SUB
				when RTYPE_SUB =>
				
					ALU1 <= '0';
					ALU2 <= '1';

				
				-- AND
				when RTYPE_AND =>
					
					ALU1 <= '1';
					ALU2 <= '0';

				
				-- OR
				when RTYPE_OR =>
				
					ALU1 <= '1';
					ALU2 <= '1';

				
				when others =>
					
					ALU1 <= '0';
					ALU2 <= '0';
					
			end case;
			
		else
		
		-- I-TYPE
			case OPCODE is

				 when ITYPE_ADDI1  => 
					
					ALU1 <= '0';
					ALU2 <= '0';
					
				 when ITYPE_SUBI1  =>
					
					ALU1 <= '0';
					ALU2 <= '1';
					
				 when ITYPE_ANDI1  =>
					
					ALU1 <= '1';
					ALU2 <= '0';
				 
				 when ITYPE_ORI1   =>
				 
					ALU1 <= '1';
					ALU2 <= '1';
				 
				 when ITYPE_ADDI2  => 
					
					ALU1 <= '0';
					ALU2 <= '0';
					
				 when ITYPE_SUBI2  =>  

					ALU1 <= '0';
					ALU2 <= '1';
					
				 when ITYPE_ANDI2  =>  
					
					ALU1 <= '1';
					ALU2 <= '0';
					
				 when ITYPE_ORI2   =>  
				 
					ALU1 <= '1';
					ALU2 <= '1';
				 
				 when ITYPE_MOV    => 
					
					ALU1 <= '0';
					ALU2 <= '0';
					
				 when ITYPE_S_REG1 =>  
				 
					ALU1 <= '0';
					ALU2 <= '0';
					
				 when ITYPE_S_REG2 => 

					ALU1 <= '0';
					ALU2 <= '0';
					
				 when ITYPE_S_MEM2 =>  
					
					ALU1 <= '0';
					ALU2 <= '0';
					
				 when ITYPE_L_MEM1 =>
					
					ALU1 <= '0';
					ALU2 <= '0';
					
				 when ITYPE_L_MEM2 =>
					
					ALU1 <= '0';
					ALU2 <= '0';
					
				 when others       =>
					
					ALU1 <= '0';
					ALU2 <= '0';

			end case;
				
		end if;
		
	end process;


end Behavioral;

