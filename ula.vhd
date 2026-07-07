-- =============================================================================
--  ula.vhd  --  Unidade Lógica e Aritmética (ULA)  --  RISC-V 32-bit Monociclo
-- =============================================================================
--
--  Responsabilidade deste módulo:
--    Receber dois operandos de 32 bits (operando_a e operando_b) e um
--    código de operação de 4 bits (codigo_operacao_ula), e calcular o
--    resultado correspondente. Também informa, através da saída
--    sinal_resultado_zero, se o resultado calculado é igual a zero
--    (informação usada pelas instruções de desvio condicional, como BEQ).
--
--  Códigos de operação (codigo_operacao_ula):
--    0000 = ADD    0001 = SUB    0010 = AND    0011 = OR
--    0100 = XOR    0101 = SLL    0110 = SRL    0111 = SRA
--    1000 = SLT    1001 = SLTU
--
--  Saídas:
--    resultado_ula      : resultado de 32 bits da operação selecionada
--    sinal_resultado_zero : '1' quando resultado_ula = 0  (usado por BEQ/BNE)
--
--  Funções úteis:
--    SLL : std_logic_vector(shift_left (unsigned(operando_a), quantidade_deslocamento))
--    SRL : std_logic_vector(shift_right(unsigned(operando_a), quantidade_deslocamento))
--    SRA : std_logic_vector(shift_right(signed(operando_a),   quantidade_deslocamento))
--
--  Dicas:
--    SLT  : resultado = 1 quando operando_a < operando_b (comparação COM sinal)
--    SLTU : resultado = 1 quando operando_a < operando_b (comparação SEM sinal)
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port (
        operando_a, operando_b : in std_logic_vector(31 downto 0); -- operandos de entrada da ULA
        codigo_operacao_ula    : in std_logic_vector(3 downto 0);  -- seleciona qual operação será executada
        resultado_ula          : out std_logic_vector(31 downto 0); -- resultado da operação selecionada
        sinal_resultado_zero   : out std_logic -- '1' quando resultado_ula for igual a zero
    );
end ula;

architecture arch of ula is
    -- Sinal interno que guarda o resultado calculado antes de ser
    -- direcionado para a saída resultado_ula e verificado pelo comparador
    -- de zero.
    signal resultado_calculado : std_logic_vector(31 downto 0);
begin
    -- Processo combinacional responsável por executar a operação
    -- aritmética/lógica indicada por codigo_operacao_ula sobre os
    -- operandos operando_a e operando_b.
    process(operando_a, operando_b, codigo_operacao_ula)
    begin
        if codigo_operacao_ula = "0000" then
            -- ADD: soma com sinal dos dois operandos
            resultado_calculado <= std_logic_vector(signed(operando_a) + signed(operando_b));

        elsif codigo_operacao_ula = "0001" then
            -- SUB: subtração com sinal dos dois operandos
            resultado_calculado <= std_logic_vector(signed(operando_a) - signed(operando_b));

        elsif codigo_operacao_ula = "0010" then
            -- AND: E lógico bit a bit
            resultado_calculado <= operando_a and operando_b;

        elsif codigo_operacao_ula = "0011" then
            -- OR: OU lógico bit a bit
            resultado_calculado <= operando_a or operando_b;

        elsif codigo_operacao_ula = "0100" then
            -- XOR: OU-exclusivo bit a bit
            resultado_calculado <= operando_a xor operando_b;

        elsif codigo_operacao_ula = "0101" then
            -- SLL: deslocamento lógico para a esquerda. A quantidade de
            -- deslocamento vem dos 5 bits menos significativos de operando_b.
            resultado_calculado <= std_logic_vector(shift_left(unsigned(operando_a), to_integer(unsigned(operando_b(4 downto 0)))));

        elsif codigo_operacao_ula = "0110" then
            -- SRL: deslocamento lógico para a direita (preenche com zeros).
            resultado_calculado <= std_logic_vector(shift_right(unsigned(operando_a), to_integer(unsigned(operando_b(4 downto 0)))));

        elsif codigo_operacao_ula = "0111" then
            -- SRA: deslocamento aritmético para a direita (preserva o sinal).
            resultado_calculado <= std_logic_vector(shift_right(signed(operando_a), to_integer(unsigned(operando_b(4 downto 0)))));

        elsif codigo_operacao_ula = "1000" then
            -- SLT: comparação COM sinal. Resultado = 1 se operando_a < operando_b.
            if signed(operando_a) < signed(operando_b) then
                resultado_calculado <= "00000000000000000000000000000001";
            else
                resultado_calculado <= (others => '0');
            end if;

        elsif codigo_operacao_ula = "1001" then
            -- SLTU: comparação SEM sinal. Resultado = 1 se operando_a < operando_b.
            if unsigned(operando_a) < unsigned(operando_b) then
                resultado_calculado <= "00000000000000000000000000000001";
            else
                resultado_calculado <= (others => '0');
            end if;

        else
            -- Código de operação não reconhecido: resultado fica zerado.
            resultado_calculado <= (others => '0');
        end if;
    end process;

    -- Processo combinacional responsável por: (1) enviar o resultado
    -- calculado para a saída resultado_ula, e (2) verificar se esse
    -- resultado é igual a zero, atualizando sinal_resultado_zero.
    process(resultado_calculado)
    begin
        resultado_ula <= resultado_calculado;

        if resultado_calculado = "00000000000000000000000000000000" then
            sinal_resultado_zero <= '1';
        else
            sinal_resultado_zero <= '0';
        end if;
    end process;
end arch;
