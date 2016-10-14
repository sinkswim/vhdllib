----------------------------------------------------------------------------------------------------------
-- Testbench Window Register File
----------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.constants.all;



ENTITY tb_WRF1 IS
END tb_WRF1;

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

 
ARCHITECTURE behavior OF tb_WRF1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT WRF
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         ENABLE : IN  std_logic;
         RD1 : IN  std_logic;
         RD2 : IN  std_logic;
         WR : IN  std_logic;
         CALL : IN  std_logic;
         RET : IN  std_logic;
         ADD_WR : IN  std_logic_vector(ADDR_SIZE-1 downto 0);
         ADD_RD1 : IN  std_logic_vector(ADDR_SIZE-1 downto 0);
         ADD_RD2 : IN  std_logic_vector(ADDR_SIZE-1 downto 0);
         DATAIN : IN  std_logic_vector(31 downto 0);
         FILL : OUT  std_logic;
         SPILL : OUT  std_logic;
         OUT1 : OUT  std_logic_vector(31 downto 0);
         OUT2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal ENABLE : std_logic := '0';
   signal RD1 : std_logic := '0';
   signal RD2 : std_logic := '0';
   signal WR : std_logic := '0';
   signal CALL : std_logic := '0';
   signal RET : std_logic := '0';
   signal ADDR_W1 : std_logic_vector(ADDR_SIZE-1 downto 0) := (others => '0');
   signal ADDR_RD1 : std_logic_vector(ADDR_SIZE-1 downto 0) := (others => '0');
   signal ADDR_RD2 : std_logic_vector(ADDR_SIZE-1 downto 0) := (others => '0');
   signal DATAIN : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal FILL : std_logic;
   signal SPILL : std_logic;
   signal OUT1 : std_logic_vector(31 downto 0);
   signal OUT2 : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: WRF PORT MAP (
          CLK => CLK,
          RST => RST,
          ENABLE => ENABLE,
          RD1 => RD1,
          RD2 => RD2,
          WR => WR,
          CALL => CALL,
          RET => RET,
          ADD_WR => ADDR_W1,
          ADD_RD1 => ADDR_RD1,
          ADD_RD2 => ADDR_RD2,
          DATAIN => DATAIN,
          FILL => FILL,
          SPILL => SPILL,
          OUT1 => OUT1,
          OUT2 => OUT2
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
     wait for clk_period;
	  
		RST <= '1';
		
     wait for clk_period;
	  
	  ENABLE <= '1';
	  RST <= '0';
	  
	  wait for 5*clk_period;
	  
	  -- WRITE 1 IN SUB 0
	  
	  RD1 <= '0';
	  RD2 <= '0';	
	  WR <= '1';
	  DATAIN <= std_logic_vector(to_unsigned(1, REGWIDTH));		-- for sub0 (and globals) write all 0..01s
		for i in 0 to 15 loop
			ADDR_W1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			ADDR_RD1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			ADDR_RD2 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			wait for clk_period;
		end loop;
	  
	  wait for 3*clk_period;
	  
	  -- READ 1 IN SUB 0
	  RD1 <= '1';
	  WR <= '0';
	  
	  for i in 0 to 15 loop
			ADDR_W1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			ADDR_RD1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			ADDR_RD2 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			wait for clk_period;
		end loop;
	  
	  wait for 3*clk_period;
	  
	  -- CALL SUB 1
	  
	  RD1 <= '0';
	  WR <= '0';
	  CALL <= '1';	  
	  
     wait for 3*clk_period;	-- call sub1 (no spill)
	  
	  -- WRITE 2 IN SUB 1
	  
	  RD1 <= '0';
	  WR <= '1';
	  CALL <= '0';
	  DATAIN <= std_logic_vector(to_unsigned(2, REGWIDTH));		-- for sub1  write all 0..10s
		for i in 4 to 15 loop
			ADDR_W1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			ADDR_RD1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			ADDR_RD2 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
			wait for clk_period;
		end loop;
	
		wait for 3*clk_period;
		
		-- READ 2 IN SUB 1
		
		
		  RD1 <= '1';
		  WR <= '0';
		  
		  for i in 4 to 15 loop
				ADDR_W1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD2 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				wait for clk_period;
			end loop;
		  
		  wait for 3*clk_period;

		-- CALL SUB 2 (TEST SPILL OPERATION)
		
		 RD1 <= '0';
		 WR <= '0';
		 CALL <= '1';				-- call sub2 (spill occurs)
		
		wait for 18*clk_period;		-- AFTER 20 CC FSM GOES BACK TO WSUB STATE
		
		-- WRITE 3 IN SUB 2
		RD1 <= '0';
		RD2 <= '0';
		WR <= '1';
		
		CALL <= '0';
      DATAIN <= std_logic_vector(to_unsigned(3, REGWIDTH));		-- for sub2  write all 0..011s
		for i in 4 to 15 loop
			ADDR_W1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD2 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				wait for clk_period;
		end loop;
		
		wait for 3*clk_period;

		-- CALL SUB 3 (TEST SPILL OPERATION)
		RD1 <= '0';
		RD2 <= '0';
		WR <=  '0';

		CALL <= '1';				-- call sub3 (spill occurs)

		wait for 18*clk_period;

		-- WRITE 4 IN SUB 3

		RD1 <= '0';
		RD2 <= '0';
		WR <= '1';

		CALL <= '0';
	  DATAIN <= std_logic_vector(to_unsigned(4, REGWIDTH));		-- for sub3  write all 0..0100s
		for i in 4 to 15 loop
			ADDR_W1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD2 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				wait for clk_period;
		end loop;
		
		wait for 3*clk_period;

		RD1 <= '0';
		RD2 <= '0';
		WR <= '0';

		CALL <= '0';

		wait for 2*clk_period;
		
		-- test subroutine returns + fills
		RET <= '1';
		
		wait for 3*clk_period;	-- return from sub3 
			
		RET <= '0';
		
		wait for 3*clk_period;
		
		
		RET <= '1';		-- return from sub2 (a fill occurs here)
		
		-- emulate data coming from memory (one word per clk cycle)
		DATAIN <= std_logic_vector(to_unsigned(2, REGWIDTH));
		-- write signal to RF is raised to 1 in FILL state of RF_CU 
		wait for 18*clk_period;
		
		RET <= '0';
		
		-- check that we have filled the RF with the right stuff (all 0.0010s)
		RD1 <= '1';
		WR <= '0';
		for i in 4 to 15 loop
			ADDR_W1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD1 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				ADDR_RD2 <= std_logic_vector(to_unsigned(i, ADDR_SIZE));
				wait for clk_period;
		end loop;
		

      wait;
   end process;

END;
