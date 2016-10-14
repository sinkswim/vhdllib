-- MUX 21 generic, lab 1
library IEEE;
use IEEE.std_logic_1164.all; 	
use WORK.constants.all; 	
use ieee.numeric_std.all;

entity MUX21 is
	generic (NBIT : integer := 8;
                 DLY  : time    := 1 ns);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0)
		);
end MUX21;




architecture BEHAVIORAL_1 of MUX21 is

begin
	Y <= A after DLY when S='1' else B after DLY;

end BEHAVIORAL_1;





architecture STRUCTURAL of MUX21 is

	signal Y1: std_logic_vector (NBIT-1 downto 0);
	signal Y2: std_logic_vector (NBIT-1 downto 0);
	signal SB: std_logic;

	component ND2
	
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		Y:	Out	std_logic);
	end component;
	
	component IV
	
	Port (	A:	In	std_logic;
		Y:	Out	std_logic);
	end component;

begin

	UIV : IV
	Port Map ( S, SB);
	
	gen_mux21: for i in 0 to NBIT-1 generate
		UND1 : ND2
		Port Map ( A(i), S, Y1(i));

		UND2 : ND2
		Port Map ( B(i), SB, Y2(i));

		UND3 : ND2
		Port Map ( Y1(i), Y2(i), Y(i));
	end generate gen_mux21;
	
	


end STRUCTURAL;


configuration CFG_MUX21_BEHAVIORAL_1_GEN of MUX21 is
	for BEHAVIORAL_1
	end for;
end CFG_MUX21_BEHAVIORAL_1_GEN;


configuration CFG_MUX21_STRUCTURAL_GEN of MUX21 is
	for STRUCTURAL
          for gen_mux21
           
		for all : ND2
			use configuration WORK.CFG_ND2_ARCH2;
		end for;
          end for;
          for all : IV
		use configuration WORK.CFG_IV_BEHAVIORAL;
	  end for;
	end for;
end CFG_MUX21_STRUCTURAL_GEN;
