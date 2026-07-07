library IEEE;
use IEEE.std_logic_1164.all;

entity controle is
    port (
        campo_opcode_sete_bits : in std_logic_vector(6 downto 0); -- opcode da instrução (bits [6:0] do RISC-V)

        sinal_reg_dst    : out std_logic; -- não utilizado no datapath atual (rd sempre vem de instrucao[11:7])
        sinal_alu_src    : out std_logic; -- '1' = segundo operando da ULA vem do imediato
        sinal_mem_to_reg : out std_logic; -- '1' = dado escrito no registrador vem da memória (LW)
        sinal_reg_write  : out std_logic; -- '1' = habilita escrita no banco de registradores
        sinal_mem_read   : out std_logic; -- '1' = habilita leitura da memória de dados (LW)
        sinal_mem_write  : out std_logic; -- '1' = habilita escrita na memória de dados (SW)
        sinal_branch     : out std_logic; -- '1' = instrução é um desvio condicional (BEQ)
        sinal_tipo_instrucao : out std_logic_vector(1 downto 0); -- "00"=R, "01"=I/LW, "10"=SW, "11"=BEQ (formato do IMEDIATO, p/ immgen)
        sinal_alu_op         : out std_logic_vector(1 downto 0)  -- "00"=LW/SW (soma), "01"=BEQ (subtrai), "10"=R (funct), "11"=I aritmético (p/ ulaop)
    );
end controle;

architecture arch of controle is
begin
    process(campo_opcode_sete_bits)
        variable eh_instrucao_tipo_r : std_logic := '0'; -- '1' quando a instrução é formato-R
        variable eh_instrucao_lw     : std_logic := '0'; -- '1' quando a instrução é LW ou formato-I aritmético
        variable eh_instrucao_sw     : std_logic := '0'; -- '1' quando a instrução é SW
        variable eh_instrucao_beq    : std_logic := '0'; -- '1' quando a instrução é BEQ
    begin
        -- Passo 1: decodifica o opcode de 7 bits e liga apenas a
        -- variável correspondente ao tipo de instrução identificado.
        case campo_opcode_sete_bits is
            when "0110011" => -- Formato-R
                eh_instrucao_tipo_r := '1';
                eh_instrucao_lw     := '0';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "00";
                sinal_alu_op         <= "10"; -- formato-R: ULA decodifica funct3 + bit30

            when "0010011" => -- Formato-I aritmético (mesmo tratamento de imediato que LW)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '1';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "01";
                sinal_alu_op         <= "11"; -- I aritmético: ULA usa funct3 (bit30 só p/ shifts)

            when "0000011" => -- LW (load word)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '1';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "01";
                sinal_alu_op         <= "00"; -- LW: ULA sempre soma (endereço)

            when "0100011" => -- SW (store word)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '0';
                eh_instrucao_sw     := '1';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "10";
                sinal_alu_op         <= "00"; -- SW: ULA sempre soma (endereço)

            when "1100011" => -- BEQ (branch if equal)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '0';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '1';
                sinal_tipo_instrucao <= "11";
                sinal_alu_op         <= "01"; -- BEQ: ULA sempre subtrai

            when others => -- Opcode não reconhecido: nenhuma flag ativada
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '0';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "00";
                sinal_alu_op         <= "00";
        end case;

        -- Passo 2:
        sinal_reg_dst    <= '0'; -- não é mais utilizado (rd = instrucao[11:7] sempre)
        sinal_alu_src    <= eh_instrucao_lw or eh_instrucao_sw;
        sinal_mem_to_reg <= eh_instrucao_lw;
        sinal_reg_write  <= eh_instrucao_tipo_r or eh_instrucao_lw;
        sinal_mem_read   <= eh_instrucao_lw;
        sinal_mem_write  <= eh_instrucao_sw;
        sinal_branch     <= eh_instrucao_beq;
    end process;
end architecture arch;