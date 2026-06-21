-- =============================================================================
--  ula.vhd  --  Unidade Lógica e Aritmética  --  RISC-V 32-bit Monociclo
-- =============================================================================
--
--  Operações (op):
--    0000 = ADD    0001 = SUB    0010 = AND    0011 = OR
--    0100 = XOR    0101 = SLL    0110 = SRL    0111 = SRA
--    1000 = SLT    1001 = SLTU
--
--  Saídas:
--    res  : resultado de 32 bits
--    zero : '1' quando res = 0  (usado por BEQ/BNE)
--
-- Funções úteis: 
--   SLL : std_logic_vector(shift_left (unsigned(i_a), shamt))
--   SRL : std_logic_vector(shift_right (unsigned(i_a), shamt))
--   SRA : std_logic_vector(shift_right (signed(i_a), shamt))
--
-- Dicas: 
-- SLT : res 1 quando a < b (com sinal)
-- SLTU : res 1 quando a < b (sem sinal)
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port (
        a, b : in std_logic_vector(31 downto 0);
        op : in std_logic_vector(3 downto 0);
        res : out std_logic_vector(31 downto 0);
        zero : out std_logic
    );
end ula;

architecture arch of ula is
    signal result : std_logic_vector(31 downto 0);
begin
    process(a, b, op)
    begin
        if op = "0000" then
            result <= std_logic_vector(signed(a) + signed(b));
        elsif op = "0001" then
            result <= std_logic_vector(signed(a) - signed(b));
        elsif op = "0010" then
            result <= a and b;
        elsif op = "0011" then
            result <= a or b;
        elsif op = "0100" then
            result <= a xor b;
        elsif op = "0101" then
            result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
        elsif op = "0110" then  
            result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
        elsif op = "0111" then
            result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));
        elsif op = "1000" then
            if signed(a) < signed(b) then
                result <= "00000000000000000000000000000001";
            else
                result <= (others => '0');
            end if;
        elsif op = "1001" then
            if unsigned(a) < unsigned(b) then
                result <= "00000000000000000000000000000001";
            else
                result <= (others => '0');
            end if;
        else
            result <= (others => '0');
        end if;
    end process;
    
    process(result)
    begin
        res <= result;
        if result = "00000000000000000000000000000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;
end arch;