---------------------------------------------------------------------------------------------
-- Constants declaration for FSM CU
---------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package myTypesFSM is

-- Number of instruction implemented by the CU
   constant N_INSTR : integer := 15;
   constant CW_SIZE : integer := 11;

-- Control unit input sizes
   constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
   constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size

-- R-Type instruction -> FUNC field
   constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    -- ADD RS1,RS2,RD
   constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";    -- SUB RS1,RS2,RD
   constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";	 -- AND RS1,RS2,RD 
   constant RTYPE_OR  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";	 -- OR  RS1,RS2,RD 
   constant NOP       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    -- NOP OPERATION

-- R-Type instruction -> OPCODE field
   constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field (comment it..)
    -- I_1-Type
    constant ITYPE_ADDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";    
    constant ITYPE_SUBI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";    
    constant ITYPE_ANDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";    
    constant ITYPE_ORI1   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";      
    constant ITYPE_S_REG1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";
    constant ITYPE_L_MEM1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110"; 
    -- I_2-Type
    constant ITYPE_ADDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";    
    constant ITYPE_SUBI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";    
    constant ITYPE_ANDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";    
    constant ITYPE_ORI2   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";  
    constant ITYPE_MOV    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";
    constant ITYPE_S_REG2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";  
    constant ITYPE_S_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";  
    constant ITYPE_L_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";  
	 
-- CW for each state
-- CW_size = 11, since we have 11 output control signals (ALU1 and ALU2 are generated with another process)
-- Thus the our control word is the following (leftmost is the MSB):
-- |EN1 RF1 RF2 WF1| |EN2 S1 S2| |EN3 RM WM S3|

   constant CW_RESET 		 : std_logic_vector(CW_SIZE - 1 downto 0) := "00000000000";
   constant CW_DECODE            : std_logic_vector(CW_SIZE - 1 downto 0) := "11100000000";
   constant CW_R_TYPE_EX         : std_logic_vector(CW_SIZE - 1 downto 0) := "00001010000";
   constant CW_I_1_TYPE_EX       : std_logic_vector(CW_SIZE - 1 downto 0) := "00001110000";
   constant CW_I_2_TYPE_EX       : std_logic_vector(CW_SIZE - 1 downto 0) := "00001000000";
   constant CW_NO_MEM 		 : std_logic_vector(CW_SIZE - 1 downto 0) := "00010001000";
   constant CW_L_MEM 		 : std_logic_vector(CW_SIZE - 1 downto 0) := "00010001101";
   constant CW_S_MEM 		 : std_logic_vector(CW_SIZE - 1 downto 0) := "00000001010";
  	
	



end myTypesFSM;

