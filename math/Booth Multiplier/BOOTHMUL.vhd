----------------------------------------------------------------------------
-- Booth's multiplier.T his implementation is made of
-- following sub-blocks:
-- - shf: this block is in charge for shifting two input of
--   a certain amount specified in the generic list.
-- - N2N: this block is in charge for extending the input signal
--   from N bits to 2N bits. The sign is not preserved.
-- - minA: it computes the value -A of the input signal A.
-- - BL: this block includes MUX 5 to , 2 shifter, adder and the encoder.
--   Shifter are needed to compute at each stage 2*A, -2*A, 4*A, and so on.
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity BOOTHMUL is
	generic (N: integer := 8);	-- try 32
	port(
	A, B : in std_logic_vector(N-1 downto 0);
	P : out std_logic_vector(2*N-1 downto 0));
end BOOTHMUL;

architecture arch of BOOTHMUL is
-- signal declarations

  signal int_A : std_logic_vector(2*N-1 downto 0);
  signal int_minA : std_logic_vector(2*N-1 downto 0);
  signal int_2A : std_logic_vector(2*N-1 downto 0);
  signal int_min2A : std_logic_vector(2*N-1 downto 0);
  signal int_muxout : std_logic_vector(2*N-1 downto 0);
  signal out_encoder : std_logic_vector(2 downto 0);
  type sig_group is array (1 to ((N/2)-2)) of std_logic_vector(2*N-1 downto 0);
  signal arr: sig_group;

-- component declarations
component N2N is
	generic (Nbit_in: integer := 8;
		 Nbit_out : integer := 16);
	port (A_in: in std_logic_vector(Nbit_in-1 downto 0);
	      A_out: out std_logic_vector(Nbit_out-1 downto 0));
end component;

component minA is
	generic (Nbit : integer := 8);
	port (
		A : in std_logic_vector(Nbit-1 downto 0);
		m_A : out std_logic_vector(Nbit-1 downto 0)
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

component encoder_booth is

  port (
    B       : in  std_logic_vector(2 downto 0);
    enc_out : out std_logic_vector(2 downto 0)
    );
end component;

component BL is
	generic (
			shf0: integer := 0;		-- shift amount first shifter
			shf1: integer := 1;		-- shift amount second shifter
			Nbit: integer := 8
		);
	port (
	     A, mA,operand_b : in std_logic_vector(Nbit-1 downto 0);
	     B2l1, B2l, B2l_1 : in std_logic;
	     s_out : out std_logic_vector(Nbit-1 downto 0));
end component;


 -- go here
begin


  u_N2N : N2N generic map (N, 2*N) port map (A, int_A);
  u_minA : minA generic map (2*N) port map (int_A, int_minA);

  BM : for l in 0 to (N/2-1) generate

    lev0 : if (l = 0) generate
        enc0 : encoder_booth port map (B(2) => B(1),B(1) => B(0), B(0) => '0', enc_out => out_encoder);
        shf0 : shf generic map (1, 2*N) port map (int_A, int_minA, int_2A, int_min2A);
        mux0 : mux51 generic map (2*N) port map ((others => '0'), int_A, int_minA, int_2A, int_min2A, out_encoder, int_muxout);
    end generate lev0;

    lev1 : if (l = 1) generate
      BL1 : BL generic map (l+l, l+l+1, 2*N) port map (int_A, int_minA, int_muxout, B(2*l+1), B(2*l), B(2*l-1), arr(l)(2*N-1 downto 0));
    end generate lev1;

    levmid : if ((l > 1) and (l < (N/2-1))) generate
      uBL : BL generic map (l+l, l+l+1, 2*N) port map (int_A, int_minA, arr(l-1)(2*N-1 downto 0), B(2*l+1), B(2*l), B(2*l-1), arr(l)(2*N-1 downto 0));
    end generate levmid;

    levlast : if (l = N/2-1) generate
      BLlast : BL generic map (l+l, l+l+1, 2*N) port map (int_A, int_minA, arr(l-1)(2*N-1 downto 0), B(2*l+1), B(2*l), B(2*l-1), P);
    end generate levlast;

  end generate BM;
end arch;
