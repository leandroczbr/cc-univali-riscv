library ieee;
use ieee.std_logic_1164.all;

entity ulaop is
    port (
        first3bits : in  std_logic_vector(2 downto 0);
        last1bit   : in  std_logic;
        ualop_out  : out std_logic_vector(3 downto 0)
    );
end ulaop;

architecture arch of ulaop is
begin

    -- 0000 = ADD    0001 = SUB    0010 = AND    0011 = OR
    -- 0100 = XOR    0101 = SLL    0110 = SRL    0111 = SRA
    -- 1000 = SLT    1001 = SLTU

    process(first3bits, last1bit)
    begin
        case first3bits is
            when "000" =>
                if last1bit = '0' then
                    ualop_out <= "0000"; -- ADD
                else
                    ualop_out <= "0001"; -- SUB
                end if;

            when "001" =>
                ualop_out <= "0101"; -- SLL
            
            when "010" =>
                ualop_out <= "1000"; -- SLT

            when "011" =>
                ualop_out <= "1001"; -- SLTU

            when "100" =>
                ualop_out <= "0100"; -- XOR

            when "101" =>
                if last1bit = '0' then
                    ualop_out <= "0110"; -- SRL
                else
                    ualop_out <= "0111"; -- SRA
                end if;

            when "110" =>
                ualop_out <= "0011"; -- OR

            when "111" =>
                ualop_out <= "0010"; -- AND

            when others =>
                ualop_out <= (others => '0');
        end case;
    end process;

end architecture arch;