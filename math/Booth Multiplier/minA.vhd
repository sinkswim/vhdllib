----------------------------------------------------------------------------------
-- minA: it transforms from A to -A the input signal A.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity minA is
	generic (Nbit : integer := 8);
	port (
			A : in std_logic_vector(Nbit-1 downto 0);
			m_A : out std_logic_vector(Nbit-1 downto 0)
			);
end minA;

architecture Behavioral of minA is

begin

	m_A <= std_logic_vector(unsigned(not(A)) + 1);

end Behavioral;

