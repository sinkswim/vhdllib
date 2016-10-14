----------------------------------------------------------------------------------
-- N2N: extend from N to 2N the input signal.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity N2N is
	generic (Nbit_in: integer := 8;
				Nbit_out : integer := 16);
	port (A_in: in std_logic_vector(Nbit_in-1 downto 0);
		   A_out: out std_logic_vector(Nbit_out-1 downto 0));
end N2N;

architecture Behavioral of N2N is

begin
	
	A_out(Nbit_out-1 downto Nbit_in) <= (others => '1') when (A_in(Nbit_in-1) = '1')  else (others => '0');	-- consider sign of operand
	A_out(Nbit_in-1 downto 0) <= A_in;

end Behavioral;

