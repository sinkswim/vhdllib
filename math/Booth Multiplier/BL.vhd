----------------------------------------------------------------------------
-- BL. this block contains MUX 5 to 1, 2 shifter, 1 RCA and
-- one Booth's Encoder.
----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity BL is 
	generic (
			shf0: integer := 0;
			shf1: integer := 1;
			Nbit: integer := 8
		);
	port (
	     A, mA,operand_b : in std_logic_vector(Nbit-1 downto 0);
	     B2l1, B2l, B2l_1 : in std_logic;
	     s_out : out std_logic_vector(Nbit-1 downto 0));
end BL;


architecture struct of BL is

component encoder_booth is
  
  port (
    B       : in  std_logic_vector(2 downto 0);
    enc_out : out std_logic_vector(2 downto 0)
    );
end component;


component shf is
	generic (
				shf_amt: integer := 1;		-- shift amount
				Nbit: integer := 8);
	port (
			A, m_A: in std_logic_vector(Nbit-1 downto 0);
			outA, outm_A: out std_logic_vector(Nbit-1 downto 0)
			);
end component;

component mux51 is
  generic(
    N : integer := 8
    );
  port(
     in1, in2, in3, in4, in5 : in std_logic_vector(N-1 downto 0);
     sel : in std_logic_vector(2 downto 0);
     mux_out : out std_logic_vector(N-1 downto 0)
    );
end component;

component RCA is 
	generic (NBIT  :	integer := 8);
		 --DRCAS : 	Time := 0 ns;  -- sum delay
	         --DRCAC : 	Time := 0 ns); -- carry out delay
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(NBIT-1 downto 0);
		Co:	Out	std_logic);
end component; 

constant zero : std_logic_vector(Nbit-1 downto 0) := (others => '0');
signal shfToMuxO, shfToMux_mO, shfToMuxI, shfToMux_mI, MuxToAdder : std_logic_vector(Nbit-1 downto 0);
signal encToMux : std_logic_vector(2 downto 0);

begin

	u_shf0: shf   generic map(shf0, Nbit) port map(A, mA, shfToMuxO, shfToMux_mO);
	u_shf1: shf   generic map (shf1, Nbit) port map(A, mA, shfToMuxI, shfToMux_mI);
	u_mux:  mux51 generic map(Nbit) port map(zero, shfToMuxO, shfToMux_mO, shfToMuxI, shfToMux_mI, encToMux, MuxToAdder);
	u_rca:  rca   generic map(Nbit) port map(MuxToAdder, operand_b, '0', s_out);
	u_enc:  encoder_booth   port map(B(2) => B2l1, B(1) => B2l, B(0) => B2l_1, enc_out => encToMux);
	
end struct;