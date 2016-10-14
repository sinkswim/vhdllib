library ieee;
use ieee.std_logic_1164.all;

entity Pentium4_adder_gen is
  generic(
    SIZE: integer := 4;	-- bits of a single carry select
    NBIT: integer := 32		-- bits of operands
  );
	port(
		a, b : in std_logic_vector(NBIT-1 downto 0);
		cin : in std_logic;
		sum : out std_logic_vector(NBIT-1 downto 0);
		cout : out std_logic
	);
end Pentium4_adder_gen;

architecture struct of Pentium4_adder_gen is

	component carrygen_generic is
    generic (
  		SIZE: integer := 4;	-- bits of a single carry select
  		NBIT: integer := 32		-- bits of operands
  	);
  	port (
  		A,B: in std_logic_vector (NBIT-1 downto 0);
  		cin: in std_logic;		-- propagates directly to sum generator
  		c0_out: out std_logic;	-- gets cin
  		carries: out std_logic_vector (NBIT/SIZE-1 downto 0)	-- NBIT/SIZE: number of carry outs generated
  	);
	end component;

	component sum_generator is
		generic(
			OPSIZE : integer := 32;
			numblocks : integer := 8
		);
		port(
			a, b : in std_logic_vector(OPSIZE-1 downto 0);
			carries : in std_logic_vector(numblocks-1 downto 0);
			sum : out std_logic_vector(OPSIZE-1 downto 0)
		);
	end component;

	signal int_carries : std_logic_vector(NBIT/SIZE downto 0);

begin
	cout <= int_carries(NBIT/SIZE);
	unit_carrygen: carrygen_generic port map (a, b, cin, int_carries(0), int_carries(NBIT/SIZE downto 1));
	unit_sumgen: sum_generator port map (a, b, int_carries(NBIT/SIZE-1 downto 0), sum);

end struct;
