library ieee;
use ieee.std_logic_1164.all;

entity ulaop is
    port (
        funct50 : in std_logic_vector(5 downto 0);
        ctrl_ual_op : in std_logic_vector(1 downto 0);
        ualop_out : out std_logic_vector(3 downto 0)
    );
end ulaop;

architecture arch of ulaop is
begin
    
    ualop_out(3) <= '0';
    ualop_out(2) <=  ctrl_ual_op(0) or (ctrl_ual_op(1) and funct50(1));
    ualop_out(1) <=  (not ctrl_ual_op(1)) or (not funct50(2));
    ualop_out(0) <=  ctrl_ual_op(1) and (funct50(3) or funct50(0));
    
end arch;