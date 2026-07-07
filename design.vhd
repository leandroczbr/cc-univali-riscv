library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity design is
    port (
        clock : in std_logic := '0'; -- clock do sistema
        instrucao : in std_logic_vector(31 downto 0) := (others => '0') -- instrução de 32 bits a ser executada
        );
end design;

architecture arch of design is
    -- Segundo operando da ULA, já escolhido entre o valor do registrador
    -- rs2 e o valor imediato (saída do multiplexador MUX_FONTE_ULA).
    signal segundo_operando_ula : std_logic_vector(31 downto 0) := (others => '0');

    -- Código de operação de 4 bits que informa à ULA qual operação executar
    -- (saída do decodificador ulaop).
    signal codigo_operacao_ula : std_logic_vector(3 downto 0) := (others => '0');

    -- Cópia interna da instrução de entrada, usada para facilitar a leitura
    -- dos campos (fatias de bits) ao longo da arquitetura.
    signal instrucao_interna : std_logic_vector(31 downto 0) := (others => '0');

    -- Valores lidos do banco de registradores para rs1 e rs2.
    signal dado_registrador_rs1 : std_logic_vector(31 downto 0) := (others => '0');
    signal dado_registrador_rs2 : std_logic_vector(31 downto 0) := (others => '0');

    -- Resultado da ULA que retorna para ser escrito no banco de
    -- registradores.
    signal resultado_para_escrita_registrador : std_logic_vector(31 downto 0) := (others => '0');

    -- Sinais de controle gerados pela unidade de controle.
    signal sinal_reg_dst    : std_logic := '0'; -- escolhe o campo de registrador de destino
    signal sinal_alu_src    : std_logic := '0'; -- escolhe a fonte do 2º operando da ULA (registrador x imediato)
    signal sinal_mem_to_reg : std_logic := '0'; -- escolhe a fonte do dado a escrever no registrador (memória x ULA)
    signal sinal_reg_write  : std_logic := '0'; -- habilita escrita no banco de registradores
    signal sinal_mem_read   : std_logic := '0'; -- habilita leitura da memória de dados
    signal sinal_mem_write  : std_logic := '0'; -- habilita escrita na memória de dados
    signal sinal_branch     : std_logic := '0'; -- indica instrução de desvio condicional
    signal sinal_tipo_instrucao : std_logic_vector(1 downto 0) := (others => '0'); -- '00' = tipo-R, '01' = LW, '10' = SW, '11' = BEQ
    signal sinal_alu_op         : std_logic_vector(1 downto 0) := (others => '0'); -- classe de operação p/ o decodificador da ULA
    signal sinal_valor_imediato : std_logic_vector(31 downto 0) := (others => '0');
    signal sinal_zero_ula : std_logic := '0'; -- indica se o resultado da ULA é zero (usado para BEQ)
begin
    -- Apenas replica a instrução de entrada em um sinal interno, para que
    -- os campos (fatias de bits) possam ser referenciados mais facilmente
    -- ao longo da arquitetura.
    instrucao_interna <= instrucao;

    -- -------------------------------------------------------------------
    -- Unidade de controle: decodifica o campo de opcode da instrução e
    -- gera todos os sinais de controle usados pelo resto do datapath.
    -- -------------------------------------------------------------------
    UNIDADE_CONTROLE: entity work.controle
        port map (
            campo_opcode_sete_bits => instrucao_interna(6 downto 0), -- opcode real do RISC-V (bits [6:0])

            sinal_reg_dst    => sinal_reg_dst,
            sinal_alu_src    => sinal_alu_src,
            sinal_mem_to_reg => sinal_mem_to_reg,
            sinal_reg_write  => sinal_reg_write,
            sinal_mem_read   => sinal_mem_read,
            sinal_mem_write  => sinal_mem_write,
            sinal_branch     => sinal_branch,
            sinal_tipo_instrucao => sinal_tipo_instrucao,
            sinal_alu_op         => sinal_alu_op
        );

    -- -------------------------------------------------------------------
    -- Banco de registradores: fornece os valores de rs1 e rs2 para a ULA
    -- e recebe o resultado da ULA para escrita no registrador de destino.
    -- -------------------------------------------------------------------
    BANCO_DE_REGISTRADORES: entity work.regmemory
        port map (
            clock => clock,

            endereco_leitura_rs1 => instrucao_interna(19 downto 15),
            endereco_leitura_rs2 => instrucao_interna(24 downto 20),
            dado_lido_rs1 => dado_registrador_rs1,
            dado_lido_rs2 => dado_registrador_rs2,

            endereco_escrita_rd       => instrucao_interna(11 downto 7),
            sinal_escreve_registrador => sinal_reg_write,
            dado_para_escrita         => resultado_para_escrita_registrador
        );
    -- Transforma o campo de imediato da instrução em um valor de 32 bits, de acordo com o tipo da instrução (R, LW, SW, BEQ).
    IMMGEN: entity work.immgen
        port map (
            ins_in => instrucao_interna,
            imm_out => sinal_valor_imediato,
            sinal_tipo_instrucao_in => sinal_tipo_instrucao
        );

    -- -------------------------------------------------------------------
    -- Multiplexador de 32 bits: escolhe se o 2º operando da ULA vem do
    -- registrador rs2 ou do valor imediato, de acordo com sinal_alu_src.
    -- -------------------------------------------------------------------
    MUX_FONTE_ULA: entity work.mux32
        port map (
            a   => dado_registrador_rs2,
            b   => sinal_valor_imediato,
            sel => sinal_alu_src,
            o   => segundo_operando_ula
        );

    -- -------------------------------------------------------------------
    -- Decodificador do código de operação da ULA: traduz funct3 (bits
    -- 14 downto 12) e o bit 30 da instrução no código de 4 bits que a
    -- ULA entende.
    -- -------------------------------------------------------------------
    DECODIFICADOR_ULAOP: entity work.ulaop
        port map (
            campo_funct3        => instrucao_interna(14 downto 12),
            bit30_da_instrucao  => instrucao_interna(30),
            sinal_alu_op        => sinal_alu_op, -- CORREÇÃO: informa o tipo p/ não usar bit30 em ADDI
            codigo_operacao_ula => codigo_operacao_ula
        );

    -- -------------------------------------------------------------------
    -- Unidade Lógica e Aritmética: executa a operação selecionada sobre
    -- o valor de rs1 e o segundo operando (registrador ou imediato).
    -- -------------------------------------------------------------------
    UNIDADE_LOGICA_ARITMETICA: entity work.ula
        port map (
            operando_a => dado_registrador_rs1,
            operando_b => segundo_operando_ula,
            codigo_operacao_ula  => codigo_operacao_ula,
            resultado_ula        => resultado_para_escrita_registrador,
            sinal_resultado_zero => sinal_zero_ula
        );

    -- NOTA: assim como no arquivo original, a porta de saída "saida_ula"
    -- (antes "ual_res") NÃO é conectada a nenhum sinal interno dentro
    -- desta arquitetura — apenas "sinal_zero_ula" (antes "ual_zero") é
    -- de fato ligada à saída "zero" da ULA. Esse comportamento foi
    -- mantido propositalmente, pois a tarefa é apenas renomear/comentar,
    -- e não corrigir a lógica original.

end arch;
