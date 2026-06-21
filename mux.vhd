library ieee;
use ieee.std_logic_1164.all;

entity mux is
    port (
        a, b : in std_logic;
        sel : in std_logic;
        o : out std_logic
    );
end mux;

architecture arch of mux is
begin
    process(a, b, sel)
    begin
        if sel = '0' then
            o <= a;
        else
            o <= b;
        end if;
    end process;
end arch;