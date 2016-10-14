----------------------------------------------------------------------------------
-- Useful functions
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package functions is

---------------------------------------------------------------------
-------------------- FUNCTIONS --------------------------------------
---------------------------------------------------------------------
function log2of ( op: integer ) return integer ;		-- function declaration
end functions;

package body functions is

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

end functions;
 
