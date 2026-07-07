-- =============================================================================
--  controle.vhd  --  Unidade de Controle Principal  --  RISC-V 32-bit Monociclo
-- =============================================================================
--
--  Responsabilidade deste módulo:
--    Olhar para o campo "opcode" da instrução e, a partir dele, decidir o
--    valor de todos os sinais de controle que o restante do datapath
--    (multiplexadores, ULA, memória, banco de registradores, etc.) precisa
--    para executar a instrução corretamente.
--
--  CORREÇÃO 1 (histórico): o campo de opcode passou de 6 bits vindos de
--    instrucao[31:26] (posição do MIPS) para 7 bits vindos de
--    instrucao[6:0] (posição real do RISC-V).
--
--  CORREÇÃO 2 (histórico): removido o clock — a unidade de controle é
--    puramente combinacional (não guarda estado, só traduz opcode em
--    sinais de controle). O único bloco síncrono do processador deve ser
--    o banco de registradores.
--
--  CORREÇÃO 3 (esta versão): os sinais intermediários que guardavam o
--    tipo de instrução decodificado (eh_instrucao_tipo_r, eh_instrucao_lw,
--    eh_instrucao_sw, eh_instrucao_beq) eram declarados como "signal".
--    Em VHDL, um "signal" só assume seu novo valor depois que o processo
--    termina de executar — então, quando o mesmo processo tentava USAR
--    esses valores logo em seguida (para montar sinal_reg_write,
--    sinal_alu_src, etc.), ele ainda enxergava o valor ANTIGO, de uma
--    execução anterior do processo. Além disso, como esses sinais não
--    estavam na sensitivity list, o processo não era re-executado quando
--    eles mudavam — o resultado era sinais de controle sempre "um opcode
--    atrasados" em relação à instrução atual.
--    A correção foi trocar esses quatro sinais por "variable", que dentro
--    de um processo VHDL são atualizadas IMEDIATAMENTE (no mesmo instante
--    da atribuição), permitindo que sejam lidas corretamente logo depois,
--    ainda dentro do mesmo processo e da mesma execução.
--
--  Opcodes reconhecidos (RV32I):
--    0110011 -> formato-R   (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
--    0010011 -> formato-I aritmético (ADDI, ANDI, ORI, XORI, SLTI, SLTIU...)
--    0000011 -> LW          (load word — também formato-I)
--    0100011 -> SW          (store word)
--    1100011 -> BEQ         (branch if equal)
--
--  Sinais de controle gerados (nomes e significado):
--    sinal_alu_src    -> '1' = segundo operando da ULA vem do imediato
--                         (formato-I, LW, SW)
--    sinal_mem_to_reg -> '1' = dado escrito no registrador vem da memória (LW)
--    sinal_reg_write  -> habilita a escrita no banco de registradores
--    sinal_mem_read   -> habilita leitura na memória de dados (LW)
--    sinal_mem_write  -> habilita escrita na memória de dados (SW)
--    sinal_branch     -> instrução é um desvio condicional (BEQ)
--    sinal_tipo_instrucao -> "00"=R, "01"=I/LW, "10"=SW, "11"=BEQ (usado
--                            pelo IMMGEN para saber como montar o imediato)
-- =============================================================================

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
        sinal_tipo_instrucao : out std_logic_vector(1 downto 0) -- "00"=R, "01"=I/LW, "10"=SW, "11"=BEQ
    );
end controle;

architecture arch of controle is
begin
    -- Processo puramente combinacional: dispara sempre que o opcode muda.
    -- Todos os "flags" de tipo de instrução são VARIÁVEIS locais, então
    -- ficam disponíveis com o valor correto assim que são atribuídas,
    -- podendo ser usadas ainda dentro do mesmo processo/execução.
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

            when "0010011" => -- Formato-I aritmético (mesmo tratamento de imediato que LW)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '1';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "01";

            when "0000011" => -- LW (load word)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '1';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "01";

            when "0100011" => -- SW (store word)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '0';
                eh_instrucao_sw     := '1';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "10";

            when "1100011" => -- BEQ (branch if equal)
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '0';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '1';
                sinal_tipo_instrucao <= "11";

            when others => -- Opcode não reconhecido: nenhuma flag ativada
                eh_instrucao_tipo_r := '0';
                eh_instrucao_lw     := '0';
                eh_instrucao_sw     := '0';
                eh_instrucao_beq    := '0';
                sinal_tipo_instrucao <= "00";
        end case;

        -- Passo 2: a partir das variáveis já atualizadas no passo 1,
        -- monta os sinais de controle de saída. Como são variáveis, aqui
        -- já enxergamos o valor correto para a instrução ATUAL.
        sinal_reg_dst    <= '0'; -- não é mais utilizado (rd = instrucao[11:7] sempre)
        sinal_alu_src    <= eh_instrucao_lw or eh_instrucao_sw;
        sinal_mem_to_reg <= eh_instrucao_lw;
        sinal_reg_write  <= eh_instrucao_tipo_r or eh_instrucao_lw;
        sinal_mem_read   <= eh_instrucao_lw;
        sinal_mem_write  <= eh_instrucao_sw;
        sinal_branch     <= eh_instrucao_beq;
    end process;
end architecture arch;