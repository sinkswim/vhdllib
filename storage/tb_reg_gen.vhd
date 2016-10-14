library IEEE;
use IEEE.std_logic_1164.all;


entity TBFD is
end TBFD;

architecture TEST of TBFD is
        constant NBIT : integer := 8;   -- register size
	signal	CK:		std_logic :='0';
	signal	RESET:		std_logic :='0';
	signal	D:		std_logic_vector(NBIT-1 downto 0) :=(others => '0');
	signal	QSYNCH:		std_logic_vector(NBIT-1 downto 0);
	signal	QASYNCH:	std_logic_vector(NBIT-1 downto 0);
	
	component reg_gen is
        	generic (NBIT : integer := 8);               -- size of the register
        	port (
       			 A     : in  std_logic_vector (NBIT-1 downto 0);  -- primary input
        		 B     : out std_logic_vector (NBIT-1 downto 0);  -- primary output
        		 clock : in  std_logic;                           -- clock source
        		 reset : in  std_logic);                           -- reset signal
        end component;              

begin 
		
	reg_syn: reg_gen
	Port Map (D, QSYNCH, CK, RESET); -- sync

	reg_asyn: reg_gen
	Port Map (D, QASYNCH, CK, RESET); -- async
	

	RESET <= '0', '1' after 0.6 ns, '0' after 1.1 ns, '1' after 2.2 ns, '0' after 3.2 ns;	
	
	
	D <= "00000000", "00000001" after 0.4 ns,"00000000"  after 1.1 ns,"00000001" after 1.4 ns, "00000000" after 1.7 ns, "00000001" after 1.9 ns;

	
	PCLOCK : process(CK)
	begin
		CK <= not(CK) after 0.5 ns;	
	end process;

end TEST;

configuration REGTEST of TBFD is
   for TEST
      for reg_syn : reg_gen
         use configuration WORK.cfg_reg_sync; -- sincrono
      end for;
      for reg_asyn : reg_gen
         use configuration WORK.cfg_reg_async; -- asincrono
      end for;


   end for;
end REGTEST;

