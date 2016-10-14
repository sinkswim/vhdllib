----------------------------------------------
-- Microprogrammed Control Unit
----------------------------------------------
-------------------------------------------------------------------------------------------------
-- The microcode memory size is 46 since we have reset_code + 15 istr. * 3 CCPI
--------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.CU_UP_Types.all;

entity myCU_UP is
  port (
                -- FIRST SET OF OUTPUTS
                EN1    : out std_logic;               -- enables the register file and the pipeline registers
                RF1    : out std_logic;               -- enables the read port 1 of the register file
                RF2    : out std_logic;               -- enables the read port 2 of the register file
                WF1    : out std_logic;               -- enables the write port of the register file
                -- SECOND SET OF OUTPUTS
                EN2    : out std_logic;               -- enables the pipe registers
                S1     : out std_logic;               -- input selection of the first multiplexer
                S2     : out std_logic;               -- input selection of the second multiplexer
                ALU1   : out std_logic;               -- alu control bit
                ALU2   : out std_logic;               -- alu control bit
                -- THIRD SET OF OUTPUTS
                EN3    : out std_logic;               -- enables the memory and the pipeline registers
                RM     : out std_logic;               -- enables the read-out of the memory
                WM     : out std_logic;               -- enables the write-in of the memory
                S3     : out std_logic;               -- input selection of the multiplexer
                -- INPUTS
                OPCODE    : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
                FUNC      : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
                Clk 	: in std_logic;
                Rst 	: in std_logic);                  -- Active Low

end myCU_UP;

architecture myCU_UP_rtl of myCU_UP is

  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  type reloc_mem_array is array (0 to RELMEM_SIZE - 1) of unsigned(RELOPC_SIZE-1 downto 0);

  signal microcode_mem : mem_array := ( "00000000000",  -- RESET
                                        "11100000000", -- R Type
                                        "00001010000",
                                        "00010001000",
                                        "10100000000", -- ADDI1
                                        "00001110000",
                                        "00010001000",
                                        "10100000000", -- SUBI1
                                        "00001110000",
                                        "00010001000",
                                        "10100000000",  -- ANDI1
                                        "00001110000",
                                        "00010001000",
                                        "10100000000",  -- ORI1
                                        "00001110000",
                                        "00010001000",
                                        "11000000000",  -- ADDI2
                                        "00001000000",
                                        "00010001000",
                                        "11000000000",  -- SUBI2
                                        "00001000000",
                                        "00010001000",
                                        "11000000000",  -- ANDI2
                                        "00001000000",
                                        "00010001000",
                                        "11000000000",  -- ORI2
                                        "00001000000",
                                        "00010001000",
                                        "11000000000",  -- MOV
                                        "00001000000",
                                        "00010001000",
                                        "10100000000",  -- S_REG1
                                        "00001110000",
                                        "00010001000",
                                        "11000000000",  -- S_REG2
                                        "00001000000",
                                        "00010001000",
                                        "11100000000",  -- S_MEM2
                                        "00001000000",
                                        "00000001010",
                                        "10100000000",  -- L_MEM1
                                        "00001110000",
                                        "00010001101",
                                        "11000000000",  -- L_MEM2
                                        "00001000000",
                                        "00010001101");

  signal reloc_mem : reloc_mem_array := ("000001", -- R-type instructions
                                         "000100",  -- ADDI1
                                         "000111",  -- SUBI1
                                         "001010",  -- ANDI1
                                         "001101",  -- ORI1
                                         "010000",  -- ADDI2
                                         "010011",  -- SUBI2
                                         "010110",  -- ANDI2
                                         "011001",  -- ORI2
                                         "011100",  -- MOV
                                         "011111",  -- S_REG1
                                         "100010",  -- S_REG2
                                         "100101",  -- S_MEM2
                                         "101000",  -- L_MEM1
                                         "101011"  -- L_MEM2
                                         );

  signal cw : std_logic_vector(CW_SIZE - 1 downto 0);

  signal uPC : integer range 0 to MICROCODE_MEM_SIZE-1;     -- pointer to microcode memory
  signal ICount : integer range 0 to INSTRUCTIONS_EXECUTION_CYCLES; -- used to update the uPC while working on an instr.

	signal relocated_OPCODE : unsigned(RELOPC_SIZE-1 downto 0);


  -- constant R_OPCODE : unsigned(OP_CODE_SIZE -1 downto 0) := "000000";

begin  -- myCU_UP_rtl
-- relocate OPCODE for correct update of uPC, see uPC_PROC process
	relocated_OPCODE <= reloc_mem(conv_integer(OPCODE));
-- get CW from the microcode memory
  cw <= microcode_mem(uPC);
-- assign CW wires to output signals
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

  -- purpose: Update the uPC value depending on the instruction Op Code
  -- type   : sequential
  -- inputs : Clk, Rst
  -- outputs: CW Control Signals
  uPC_Proc: process (Clk, Rst)
  begin  -- process uPC_Proc
    if Rst = '0' then                   -- asynchronous reset (active low)
      uPC <= 0;
      ICount <= 0;
    elsif (Clk'event and Clk = '1') then  -- rising clock edge
      if (ICount = 0) then
        uPC <= conv_integer(relocated_OPCODE);
        ICount <= ICount + 1;
      elsif (ICount < INSTRUCTIONS_EXECUTION_CYCLES) then
        uPC <= uPC + 1;
		  if(ICount = 1) then
			ICount <= ICount + 1;
		  elsif (ICount = 2) then
			ICount <= 0;
		  end if;
      end if;
    end if;
  end process uPC_Proc;


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
		if (OPCODE = RTYPE ) then
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

end myCU_UP_rtl;
