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
    signal resultado_calculado : std_logic_vector(31 downto 0);
begin
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
