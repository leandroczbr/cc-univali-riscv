library ieee;
use ieee.std_logic_1164.all;

entity mux5 is
    port (
        a, b : in std_logic_vector(4 downto 0);
        sel : in std_logic;
        o : out std_logic_vector(4 downto 0)
    );
end mux5;

architecture arch of mux5 is
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