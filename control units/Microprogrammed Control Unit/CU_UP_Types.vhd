-----------------------------------------------------------------------------
-- Constants declarations for Microprogrammed version of the control unit
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package CU_UP_Types is

  constant MICROCODE_MEM_SIZE : integer := 46;  -- Microcode Memory Size -- reset + 15 instr * 3 cc = 46 ucodes
  constant INSTRUCTIONS_EXECUTION_CYCLES : integer := 3;  -- Instructions Execution
  constant RELMEM_SIZE : integer := 15;


-- Number of instruction implemented by the CU
   constant N_INSTR : integer := 15;
   constant CW_SIZE : integer := 11;

-- Control unit input sizes
   constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
   constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size
   constant RELOPC_SIZE : integer := 6;

-- R-Type instruction -> FUNC field
   constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    -- ADD RS1,RS2,RD
   constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";    -- SUB RS1,RS2,RD
   constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";    -- AND RS1,RS2,RD
   constant RTYPE_OR  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";    -- OR  RS1,RS2,RD
   constant NOP       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    -- NOP OPERATION

-- R-Type instruction -> OPCODE field
   constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field (comment it..)
   constant ITYPE_ADDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";
   constant ITYPE_SUBI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";
   constant ITYPE_ANDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";
   constant ITYPE_ORI1   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";
   constant ITYPE_ADDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";
   constant ITYPE_SUBI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";
   constant ITYPE_ANDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";
   constant ITYPE_ORI2   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";
   constant ITYPE_MOV    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";
   constant ITYPE_S_REG1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";
   constant ITYPE_S_REG2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";
   constant ITYPE_S_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";
   constant ITYPE_L_MEM1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";
   constant ITYPE_L_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";


end CU_UP_Types;
