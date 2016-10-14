----------------------------------------------------------------------------------
-- SHF: Generic left shifter, 2 input 2 output.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shf is
	generic (
				shf_amt: integer := 1;		-- shift amount
				Nbit: integer := 8);
	port (
			A, m_A: in std_logic_vector(Nbit-1 downto 0);
			outA, outm_A: out std_logic_vector(Nbit-1 downto 0)
			);
end shf;

architecture Behavioral of shf is

begin

	outA  <= std_logic_vector(SHIFT_LEFT(unsigned(A), shf_amt));
	outm_A <= std_logic_vector(SHIFT_LEFT(unsigned(m_A), shf_amt));	-- not a problem because we have extended the last bit already with N2N block


end Behavioral;

