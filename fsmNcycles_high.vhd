library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fsmNcycles_high is
  port(
    clk, rst : in std_logic;
    x : in std_logic;
    y : out std_logic
  );
end fsmNcycles_high;

architecture beh of fsmNcycles_high is
  type state_type is (S0, S1);
  signal current_state, next_state : state_type;
  signal count, count_next : std_logic_vector(7 downto 0);
begin

  comb_logic : process(current_state, x, count)
  begin
    case current_state is
      when S0 =>
        y = '0';
        count_next <= X"01";
        if(x = '0') then
          next_state <= S0;
        else
          next_state <= S1;
        end if;
      when S1 =>
        y = '1';
        count_next <= count_next + 1;
        if(cnt = X"FF")
          next_state <= S0;
        else
          next_state <= S1;
        end if;
      when others =>
        next_state <= S0;
      end case;
  end process;

  state_proc: process(clk)
  begin
    if(clk= '1' and clk'event) then
      if(rst = '1') then
        current_state <= S0;
        count <= X"00";
      else
        current_state <= next_state
        count <= count_next;
      end if;
    end if;
  end process;

end beh;

-- ctr + dp behavioral implementation
architecture ctrl_and_dp of fsmNcycles_high is
  type state_type is (S0, S1);
  signal current_state, next_state : state_type;
  -- shared signals
  signal cnt_cmd, cnt_ld, count_done : std_logic;
  -- dp signals
  signal count, count_next : std_logic_vector(7 downto 0);
begin
-- datapath processes --

  dpcomb_logic : process(cnt_cmd, count)
  begin
    if(cnt_cmd = '1') then
      count_next <= X"00";
    elsif(cnt_cmd = '0') then
      count_next <= count_next + X"01";
    end if;
    if(count = X"FF") then
      count_done <= '1';
    else
      count_done <= '0';
    end if;
  end process;

  dpreg_proc: process(clk)
  begin
    if(clk= '1' and clk'event) then
      if(rst = '1') then
        count <= X"00";
      elsif(cnt_ld = '1')
        count <= count_next;
      end if;
    end if;
  end process;

-- controller processes --

  comb_logic : process(current_state, x, count_done)
  begin
    case current_state is
      when S0 =>
        y <= '0';
        cnt_cmd <= '1';
        cnt_ld <= '1';
        if(x = '0') then
          next_state <= S0;
        else
          next_state <= S1;
        end if;
      when S1 =>
        y <= '1';
        cnt_cmd <= '0';
        cnt_ld <= '1';
        if(count_done = '1') then
          next_state <= S0;
        else
          next_state <= S1;
        end if;
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

end ctrl_and_dp;
