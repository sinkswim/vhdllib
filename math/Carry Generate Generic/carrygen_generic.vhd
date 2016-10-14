library ieee;
use ieee.std_logic_1164.all;
use WORK.constants.all;


entity carrygen_generic is
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
end carrygen_generic;


architecture struct of carrygen_generic is

	component pgcell is   -- boxes
		port(
			a, b : in std_logic;
			p, g : out std_logic
		);
	end component;

	component white_box is  -- PG block
	port(
		Pik, Plow, Gik, Glow : in std_logic;
		Pij, Gij : out std_logic
	);
	end component;

	component grey_box is   -- G block
  port(
    Pik, Gik, Glow : in std_logic;
    Gij : out std_logic
  );
  end component;

--	function log2of ( op: integer ) return integer ;		-- function declaration

	function log2of ( op: integer )  return integer is	-- function implementation
		variable temp    : integer := op;
		variable res : integer := 0;
	begin
		while temp > 1 loop
			res := res + 1;
			temp    := temp / 2;
		end loop;

	  return res;
	 end function log2of ;

	-- block interconnection matrix
	type sig_matrix is array (log2of(NBIT)+1 downto 0) of std_logic_vector (NBIT-1 downto 0);
	signal Pmat, Gmat: sig_matrix;

begin

	top: for row in 0 to log2of(NBIT)generate -- iterates through n. rows (given by log2of(NBIT)) to make the whole structure

			row0: if row=0 generate 	-- first row: pg network

			col_gen0: for col in 0 to NBIT-1 generate
				pg_network: pgcell port map (A(col), B(col), Pmat(row+1)(col), Gmat(row+1)(col) );
			end generate col_gen0;

		end generate row0;

		row1: if row=1 generate	 -- second row

			col_gen1: for i in 0 to NBIT/2-1 generate
				grey_box1: if (i=0) generate
					upper_G: grey_box port map (Pmat(row)(i*2+1), Gmat(row)(i*2+1), Gmat(row)(i*2), Gmat(row+1)(i*2+1) );
				end generate grey_box1;

				white_box1: if ( i/=0 ) generate
					row1_PG: white_box port map (Pmat(row)(i*2+1), Pmat(row)(i*2), Gmat(row)(i*2+1), Gmat(row)(2*i), Pmat(row+1)(i*2+1), Gmat(row+1)(i*2+1) );
				end generate white_box1;
			end generate col_gen1;

		end generate row1;

		row2: if row=2 generate 	-- third row
			col_gen2:for i in 0 to NBIT/4-1 generate

				G_2: if (i=0) generate
					row2_G: grey_box port map (Pmat(row)(i*4+3), Gmat(row)(i*4+3), Gmat(row)(i*4+1), Gmat(row+1)(i*4+3) );
				end generate G_2;

				PG_2: if ( i/=0 ) generate
					row2_PG: white_box port map (Pmat(row)(i*4+3), Pmat(row)(i*4+1), Gmat(row)(i*4+3), Gmat(row)(i*4+1), Pmat(row+1)(i*4+3), Gmat(row+1)(i*4+3) );
				end generate PG_2;

			end generate col_gen2;
		end generate row2;

	other_rows: if row/=0 and row /=1 and row/=2 generate	-- from row 3 onward

		r_gen: for i in 1 to NBIT/(4*2*2**(row-3)) generate --index for blocks of signal lines and components

			block1: if i=1 generate

				mat0: for j in 1 to 2**(row-3) generate --first block of signal lines
					Gmat(row+1)( (i-1)*2**(row-3)*2*4+(j-1)*4+3 )<=Gmat(row)( (i-1)*2**(row-3)*2*4+(j-1)*4+3  ); --place the signal in the next row
					Pmat(row+1)( (i-1)*2**(row-3)*2*4+(j-1)*4+3 )<=Pmat(row)( (i-1)*2**(row-3)*2*4+(j-1)*4+3  );
				end generate mat0;

				G_gen: for j in 2**(row-3)+1 to 2**(row-3)*2 generate --block of components G
					rowN_G: grey_box port map ( Pmat(row)( (i-1)*2**(row-3)*2*4+(j-1)*4+3 ), Gmat(row)((i-1)*2**(row-3)*2*4+(j-1)*4+3), Gmat(row)((i-1)*2**(row-3)*2*4+(2**(row-3)-1)*4+3), Gmat(row+1)((i-1)*2**(row-3)*2*4+(j-1)*4+3)  );
				end generate G_gen;

			end generate block1;

			blockN: if i/=1 generate --block of signal lines

				matgen: for j in 1 to 2**(row-3) generate
					Gmat(row+1)( (i-1)*2**(row-3)*2*4+(j-1)*4+3 )<=Gmat(row)( (i-1)*2**(row-3)*2*4+(j-1)*4+3  );
					Pmat(row+1)( (i-1)*2**(row-3)*2*4+(j-1)*4+3 )<=Pmat(row)( (i-1)*2**(row-3)*2*4+(j-1)*4+3  );
				end generate matgen;

				PG_gen: for j in 2**(row-3)+1 to 2**(row-3)*2 generate --block of components white_box
					rowN_PG: white_box port map (Pmat(row)((i-1)*2**(row-3)*2*4+(j-1)*4+3), Pmat(row)((i-1)*2**(row-3)*2*4+(2**(row-3)-1)*4+3), Gmat(row)((i-1)*2**(row-3)*2*4+(j-1)*4+3),Gmat(row)((i-1)*2**(row-3)*2*4+(2**(row-3)-1)*4+3), Pmat(row+1)((i-1)*2**(row-3)*2*4+(j-1)*4+3),Gmat(row+1)((i-1)*2**(row-3)*2*4+(j-1)*4+3) );
				end generate PG_gen;

			end generate blockN;

		end generate r_gen;


	end generate other_rows;

	end generate top;

	c0_out <= cin;
	carry_prop: for i in 0 to NBIT/SIZE-1 generate 	--place the signals for output port carries
		carries(i) <= Gmat(log2of(NBIT)+1)((i+1)*SIZE-1 );
	end generate carry_prop;


end struct;
