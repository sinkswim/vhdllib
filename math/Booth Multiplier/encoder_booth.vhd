----------------------------------------------------------------------------
-- Booth's Encoder
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity encoder_booth is
  
  port (
    B       : in  std_logic_vector(2 downto 0);
    enc_out : out std_logic_vector(2 downto 0)
    );
end encoder_booth;

architecture beh of encoder_booth is

begin  -- beh

	Encoder_CombLogic: process(B)
	begin
		case B is
		when "000" => enc_out <= "000";        -- 0
		when "001" => enc_out <= "001";        -- +A
		when "010" => enc_out <= "001";	       -- +A
		when "011" => enc_out <= "011";	       -- +2A
		when "100" => enc_out <= "100";        -- -2A
		when "101" => enc_out <= "010";        -- -A
		when "110" => enc_out <= "010";        -- -A
		when "111" => enc_out <= "000";	       -- 0
		when others => enc_out <= (others => 'Z');
		end case;
	end process;

end beh;

configuration cfg_beh_encbooth of encoder_booth is

  for beh
    
  end for;

end cfg_beh_encbooth;
