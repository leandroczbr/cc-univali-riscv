-- =============================================================================
--  ulaop.vhd  --  Decodificador do Código de Operação da ULA  --  RISC-V 32-bit
-- =============================================================================
--
--  Responsabilidade deste módulo:
--    Traduzir os campos "funct3" (3 bits) e o bit 30 da instrução (que faz
--    parte do campo "funct7" no formato-R do RISC-V) no código de 4 bits
--    que a ULA (ula.vhd) entende para saber qual operação executar.
--
--  Entradas:
--    campo_funct3       -> bits [14:12] da instrução (campo funct3 do RISC-V)
--    bit30_da_instrucao -> bit [30] da instrução (usado para diferenciar
--                           ADD/SUB e SRL/SRA, equivalente ao bit mais
--                           significativo do campo funct7)
--
--  Saída:
--    codigo_operacao_ula -> código de 4 bits enviado para a ULA
--
--  Tabela de tradução (igual à usada em ula.vhd):
--    0000 = ADD    0001 = SUB    0010 = AND    0011 = OR
--    0100 = XOR    0101 = SLL    0110 = SRL    0111 = SRA
--    1000 = SLT    1001 = SLTU
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity ulaop is
    port (
        campo_funct3         : in  std_logic_vector(2 downto 0); -- funct3 da instrução (bits 14 downto 12)
        bit30_da_instrucao   : in  std_logic;                    -- bit 30 da instrução (distingue ADD/SUB e SRL/SRA)
        codigo_operacao_ula  : out std_logic_vector(3 downto 0)  -- código de operação a ser enviado para a ULA
    );
end ulaop;

architecture arch of ulaop is
begin

    -- 0000 = ADD    0001 = SUB    0010 = AND    0011 = OR
    -- 0100 = XOR    0101 = SLL    0110 = SRL    0111 = SRA
    -- 1000 = SLT    1001 = SLTU

    -- Processo combinacional que decide o código de operação da ULA de
    -- acordo com o campo_funct3 e, quando necessário, também com o
    -- bit30_da_instrucao (para diferenciar instruções que compartilham o
    -- mesmo funct3, como ADD/SUB e SRL/SRA).
    process(campo_funct3, bit30_da_instrucao)
    begin
        case campo_funct3 is
            when "000" =>
                -- funct3 = 000 pode ser ADD ou SUB, diferenciados pelo bit 30
                if bit30_da_instrucao = '0' then
                    codigo_operacao_ula <= "0000"; -- ADD
                else
                    codigo_operacao_ula <= "0001"; -- SUB
                end if;

            when "001" =>
                codigo_operacao_ula <= "0101"; -- SLL

            when "010" =>
                codigo_operacao_ula <= "1000"; -- SLT

            when "011" =>
                codigo_operacao_ula <= "1001"; -- SLTU

            when "100" =>
                codigo_operacao_ula <= "0100"; -- XOR

            when "101" =>
                -- funct3 = 101 pode ser SRL ou SRA, diferenciados pelo bit 30
                if bit30_da_instrucao = '0' then
                    codigo_operacao_ula <= "0110"; -- SRL
                else
                    codigo_operacao_ula <= "0111"; -- SRA
                end if;

            when "110" =>
                codigo_operacao_ula <= "0011"; -- OR

            when "111" =>
                codigo_operacao_ula <= "0010"; -- AND

            when others =>
                -- funct3 não reconhecido: código de operação zerado
                codigo_operacao_ula <= (others => '0');
        end case;
    end process;

end architecture arch;
