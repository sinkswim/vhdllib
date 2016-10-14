------------------------------------------------------------------------------
-- Hardwired CU
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

-------------------------------------------------------------------------------
-- Important note: ALU1,ALU2 represent ALU_opcode(i.e. function to be executed)
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

entity cu_hw is
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
end cu_hw;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



architecture beh of cu_hw is 
-- CW_size = 11, since we have 11 output control signals (ALU1 and ALU2 are generated with another process)
-- Thus the our control word is the following (leftmost is the MSB):
-- |EN1 RF1 RF2 WF1| |EN2 S1 S2| |EN3 RM WM S3|

-- Signals Declarations
type mem_array is array (integer range 0 to N_INSTR - 1) of std_logic_vector(CW_SIZE - 1 downto 0);

-- LUT
constant cw_mem : mem_array := ( "11111011000",  -- RTYPE
				 "10111111000",  -- ITYPE_ADDI1
				 "10111111000",  -- ITYPE_SUBI1
				 "10111111000",  -- ITYPE_ANDI1
				 "10111111000",  -- ITYPE_ORI1 
				 "11011001000",  -- ITYPE_ADDI2
				 "11011001000",  -- ITYPE_SUBI2
				 "11011001000",  -- ITYPE_ANDI2
				 "11011001000",  -- ITYPE_ORI2 
				 "11011001000",  -- ITYPE_MOV  
				 "10111111000",  -- ITYPE_S_REG1
				 "11011001000",  -- ITYPE_S_REG2
				 "11101001010",  -- ITYPE_S_MEM2
				 "10111111101",  -- ITYPE_L_MEM1
				 "11011001101"); -- ITYPE_L_MEM2 
										
signal cw   : std_logic_vector(CW_SIZE - 1 downto 0);

begin

	-- Use the OPCODE to address the LUT and assign the CW
	cw <= cw_mem (to_integer(unsigned(OPCODE)));
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




end beh;
