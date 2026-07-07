-- =============================================================================
--  testbench.vhd  --  Banco de Testes  --  RISC-V 32-bit Monociclo
-- =============================================================================
--
--  O que este testbench cobre:
--    - Formato-R : ADD, SUB, AND, OR, XOR, SLT
--    - Formato-I : ADDI, ORI, ANDI, SLTI
--
--  Limitações (itens não implementados ainda no processador):
--    - Sem memória de dados  → LW e SW não são testados
--    - Sem PC                → instruções são aplicadas manualmente
--    - Sem memória de instrução → instrução é força externa via sinal
--
--  Como ler os resultados:
--    Acompanhe o sinal interno "resultado_para_escrita_registrador" dentro
--    do DUT na forma de onda. Cada borda de subida do clock escreve o
--    resultado calculado no registrador de destino indicado pela instrução.
--
--  Registradores carregados na Fase 1 (usados nas fases seguintes):
--    x1 = 10   (0x0000000A)   → ADDI x1, x0, 10
--    x2 =  3   (0x00000003)   → ADDI x2, x0, 3
--    x3 = -5   (0xFFFFFFFB)   → ADDI x3, x0, -5
--
--  Codificação dos formatos:
--    Formato-R:  funct7[6:0] | rs2[4:0] | rs1[4:0] | funct3[2:0] | rd[4:0] | opcode=0110011
--    Formato-I:  imm[11:0]               | rs1[4:0] | funct3[2:0] | rd[4:0] | opcode=0010011
--
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal clock     : std_logic := '0';
    signal instrucao : std_logic_vector(31 downto 0) := (others => '0');

    -- Identifica a fase atual do teste na forma de onda
    --   1  = carga inicial dos registradores (ADDI xN, x0, imm)
    --   2  = instruções formato-R
    --   3  = instruções formato-I aritméticas
    --   99 = fim
    signal fase : integer := 0;
begin

    DUT: entity work.design
        port map (
            clock     => clock,
            instrucao => instrucao
        );

    process
    begin

        -- =================================================================
        -- FASE 1: Carregar valores nos registradores via ADDI xN, x0, imm
        --         x0 é sempre 0, então ADDI xN, x0, K  faz  xN = K
        --
        --         Formato-I: imm[11:0] | rs1 | funct3 | rd | 0010011
        -- =================================================================
        fase <= 1;

        -- ADDI x1, x0, 10  →  x1 = 10
        -- imm = 000000001010, rs1 = x0 = 00000, funct3 = 000, rd = x1 = 00001
        instrucao <= "000000001010" & "00000" & "000" & "00001" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x1 = 0x0000000A = 10

        -- ADDI x2, x0, 3   →  x2 = 3
        instrucao <= "000000000011" & "00000" & "000" & "00010" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x2 = 0x00000003 = 3

        -- ADDI x3, x0, -5  →  x3 = -5
        -- -5 em complemento de 2 com 12 bits = 111111111011
        instrucao <= "111111111011" & "00000" & "000" & "00011" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x3 = 0xFFFFFFFB = -5

        wait for 10 ns;

        -- =================================================================
        -- FASE 2: Instruções Formato-R  (opcode = 0110011)
        --         Operandos: x1=10, x2=3, x3=-5
        --
        --         Formato: funct7 | rs2 | rs1 | funct3 | rd | 0110011
        -- =================================================================
        fase <= 2;

        -- ADD x4, x1, x2  →  x4 = 10 + 3 = 13
        -- funct7=0000000, rs2=x2=00010, rs1=x1=00001, funct3=000, rd=x4=00100
        instrucao <= "0000000" & "00010" & "00001" & "000" & "00100" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x4 = 0x0000000D = 13

        -- SUB x5, x1, x2  →  x5 = 10 - 3 = 7
        -- funct7=0100000 (diferencia SUB de ADD)
        instrucao <= "0100000" & "00010" & "00001" & "000" & "00101" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x5 = 0x00000007 = 7

        -- AND x6, x1, x2  →  x6 = 10 AND 3
        -- 10 = 0b01010,  3 = 0b00011,  AND = 0b00010 = 2
        instrucao <= "0000000" & "00010" & "00001" & "111" & "00110" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x6 = 0x00000002 = 2

        -- OR x7, x1, x2   →  x7 = 10 OR 3
        -- 10 = 0b01010,  3 = 0b00011,  OR  = 0b01011 = 11
        instrucao <= "0000000" & "00010" & "00001" & "110" & "00111" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x7 = 0x0000000B = 11

        -- XOR x8, x1, x2  →  x8 = 10 XOR 3
        -- 10 = 0b01010,  3 = 0b00011,  XOR = 0b01001 = 9
        instrucao <= "0000000" & "00010" & "00001" & "100" & "01000" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x8 = 0x00000009 = 9

        -- SLT x9, x3, x1  →  x9 = (x3 < x1) com sinal = (-5 < 10) = 1
        -- rs2=x1=00001, rs1=x3=00011, funct3=010
        instrucao <= "0000000" & "00001" & "00011" & "010" & "01001" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x9 = 0x00000001 = 1  (verdadeiro: -5 < 10)

        -- SLT x10, x1, x3  →  x10 = (x1 < x3) com sinal = (10 < -5) = 0
        -- rs2=x3=00011, rs1=x1=00001, funct3=010
        instrucao <= "0000000" & "00011" & "00001" & "010" & "01010" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x10 = 0x00000000 = 0  (falso: 10 não é menor que -5)

        -- SUB x11, x1, x1  →  x11 = 10 - 10 = 0  (testa sinal_zero_ula)
        instrucao <= "0100000" & "00001" & "00001" & "000" & "01011" & "0110011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x11 = 0x00000000 = 0
        -- Neste ciclo sinal_zero_ula deve estar em '1'

        wait for 10 ns;

        -- =================================================================
        -- FASE 3: Instruções Formato-I aritméticas  (opcode = 0010011)
        --         Operando base: x1=10, x3=-5
        --
        --         Formato: imm[11:0] | rs1 | funct3 | rd | 0010011
        -- =================================================================
        fase <= 3;

        -- ADDI x12, x1, 5   →  x12 = 10 + 5 = 15
        instrucao <= "000000000101" & "00001" & "000" & "01100" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x12 = 0x0000000F = 15

        -- ADDI x13, x1, -10  →  x13 = 10 + (-10) = 0
        -- -10 em 12 bits complemento de 2 = 111111110110
        instrucao <= "111111110110" & "00001" & "000" & "01101" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x13 = 0x00000000 = 0
        -- Neste ciclo sinal_zero_ula deve estar em '1'

        -- ORI x14, x1, 5    →  x14 = 10 OR 5
        -- 10 = 0b1010,  5 = 0b0101,  OR = 0b1111 = 15
        instrucao <= "000000000101" & "00001" & "110" & "01110" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x14 = 0x0000000F = 15

        -- ANDI x15, x1, 12  →  x15 = 10 AND 12
        -- 10 = 0b1010,  12 = 0b1100,  AND = 0b1000 = 8
        instrucao <= "000000001100" & "00001" & "111" & "01111" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x15 = 0x00000008 = 8

        -- SLTI x16, x3, 0   →  x16 = (x3 < 0) com sinal = (-5 < 0) = 1
        -- imm = 000000000000 (zero)
        instrucao <= "000000000000" & "00011" & "010" & "10000" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x16 = 0x00000001 = 1  (verdadeiro: -5 < 0)

        -- SLTI x17, x1, 0   →  x17 = (x1 < 0) com sinal = (10 < 0) = 0
        instrucao <= "000000000000" & "00001" & "010" & "10001" & "0010011";
        clock <= '1'; wait for 5 ns; clock <= '0'; wait for 5 ns;
        -- Esperado: x17 = 0x00000000 = 0  (falso: 10 não é menor que 0)

        wait for 10 ns;
        fase <= 99; -- fim dos testes
        wait;
    end process;
end architecture arch;