library ieee;
use ieee.std_logic_1164.all;

entity magn_comp_stage is
  port(
    a, b : in std_logic;
    in_eq, in_lt, in_gt : in std_logic;
    out_eq, out_lt, out_gt : out std_logic
  );
end magn_comp_stage;

architecture circ of magn_comp_stage is
  begin
    out_eq <= in_eq * (a xnor b);
    out_lt <= in_lt + (in_eq * not(a) * b);
    out_gt <= in_gt + (in_eq * a * not(b));
end circ;
