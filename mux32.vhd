library ieee;
use ieee.std_logic_1164.all;

entity mux32 is
    port (
        a, b : in std_logic_vector(31 downto 0);
        sel : in std_logic;
        o : out std_logic_vector(31 downto 0)
    );
end mux32;

architecture arch of mux32 is
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