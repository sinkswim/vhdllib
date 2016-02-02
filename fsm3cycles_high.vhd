library ieee;
use ieee.std_logic_1164.all;

entity fsm3cycles_high is
  port(
    clk, rst : in std_logic;
    x : in std_logic;
    y : out std_logic
  );
end fsm3cycles_high;

architecture beh of fsm3cycles_high is
  type state_type is (S0, S1, S2, S3);
  signal current_state, next_state : state_type;
  begin

    comb_logic: process(current_state, x)
    begin
      case current_state is
        when S0 =>
          y = '0';
          if(x = '0') then
            next_state <= S0;
          else
            next_state <= S1;
          end if;
        when S1 =>
          y = '1';
          next_state <= S2;
        when S2 =>
          y = '1';
          next_state <= S3;
        when S3 =>
          y = '1';
          next_state <= S0;
        when others =>
          next_state <= S0;
        end case;
    end process;

    state_proc: process(clk)
    begin
      if(clk= '1' and clk'event) then
        if(rst = '1') then
          current_state <= S0;
        else
          current_state <= next_state
        end if;
      end if;
    end process;

end beh;


architecture struct of fsm3cycles_high is
  subtype state_type is std_logic_vector(1 downto 0);
  constant S0 : state_type := "00";
  signal current_state, next_state : state_type;
  begin

    comb_logic: process(current_state, x)
    begin
      x <= (current_state(1) or current_state(0));
      next_state(0) <= ((not(current_state(0)) and x) or (current_state(1) and not(current_state(0))));
      next_state(1) <= ((current_state(0) and not(current_state(1))) or (current_state(1) and not(current_state(0))));
    end process;

    state_proc: process(clk)
    begin
      if(clk= '1' and clk'event) then
        if(rst = '1') then
          current_state <= S0;
        else
          current_state <= next_state
        end if;
      end if;
    end process;

end struct;
