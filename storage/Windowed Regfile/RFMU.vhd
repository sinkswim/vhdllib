-----------------------------------------------------------------------------------------------
-- Register File Managment Unit
-- Combinational unit which performs address translation
-----------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constants.all;
use IEEE.NUMERIC_STD.ALL;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

entity RFMU is
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
end RFMU;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

architecture Behavioral of RFMU is
	
begin

	-----------------------------------------
	-- Name: Comb Logic
	-- Purpose: It describes the comb
   --	logic which perfomrs the translation.
	-- Type: Combinational
	-----------------------------------------
	Comb_logic: process (ADDR_R1, ADDR_R2, ADDR_W1, ADDR_CU,SPILL, FILL, CWP_in, SWP_in)
	begin
		
		if ( (SPILL = '0') and (FILL = '0')) then
			
			-- translate address coming from main CU
			if ( (to_integer(unsigned(ADDR_R1)) < M) or (to_integer(unsigned(ADDR_R2)) < M) or (to_integer(unsigned(ADDR_W1)) < M)  ) then
				
				INT_ADDR_R1 <= ADDR_R1;
				INT_ADDR_R2 <= ADDR_R2;
				INT_ADDR_W1 <= ADDR_W1;	
					
			else 
					
					if ( ((to_integer(unsigned(ADDR_R1)) >= ADDR_RANGE) or (to_integer(unsigned(ADDR_R2)) >= ADDR_RANGE) or (to_integer(unsigned(ADDR_W1)) >= ADDR_RANGE))
							and ( (to_integer(unsigned(CWP_in))) = CWP_LAST)) then
						
						-- address greater or equal to ADDR_RANGE should be mapped in at the beginning of win 1
						INT_ADDR_R1 <= std_logic_vector(unsigned(ADDR_R1) - to_unsigned(2*N, ADDR_SIZE));
						INT_ADDR_R2 <= std_logic_vector(unsigned(ADDR_R2) - to_unsigned(2*N, ADDR_SIZE));
						INT_ADDR_W1 <= std_logic_vector(unsigned(ADDR_W1) - to_unsigned(2*N, ADDR_SIZE));								
							
					else
						
						-- equation is: int_addr = addr + CWP - M
						INT_ADDR_R1 <= std_logic_vector(unsigned(ADDR_R1) + unsigned(CWP_in) - to_unsigned(M, ADDR_SIZE));
						INT_ADDR_R2 <= std_logic_vector(unsigned(ADDR_R2) + unsigned(CWP_in) - to_unsigned(M, ADDR_SIZE));
						INT_ADDR_W1 <= std_logic_vector(unsigned(ADDR_W1) + unsigned(CWP_in) - to_unsigned(M, ADDR_SIZE));							
						
					end if;
					
			end if;
			
		elsif ( SPILL = '1') then
			
			-- translate address coming from the RF CU.
			-- DUE TO FORWARDING OF REG FILE
			-- DURING SPILL: CORRECT ADDRESS IS ON ADDR_RD1, OTHERS IN HIGH Z
			-- DURIGN FILL : CORRECT ADDRESS IS ON ADDR_WR1, OTHERS IN HIGH Z

			-- equation is: int_addr = addr + SWP - M					
			INT_ADDR_R1 <= std_logic_vector(unsigned(ADDR_CU) + unsigned(SWP_in) - to_unsigned(M, ADDR_SIZE));
			INT_ADDR_R2 <= (others => 'Z');
			INT_ADDR_W1 <= (others => 'Z');
			
		elsif ( FILL = '1' ) then
				
			-- equation is: int_addr = addr + SWP - 2*N - M					
			INT_ADDR_R1 <= (others => 'Z');
			INT_ADDR_R2 <= (others => 'Z');
			INT_ADDR_W1 <= std_logic_vector(unsigned(ADDR_CU) + unsigned(SWP_in) - to_unsigned(2*N, ADDR_SIZE) - to_unsigned(M, ADDR_SIZE));
				
				
		else
		
			INT_ADDR_R1 <= (others => 'Z');
			INT_ADDR_R2 <= (others => 'Z');
			INT_ADDR_W1 <= (others => 'Z');
			
		end if;
	
	end process;

end Behavioral;

