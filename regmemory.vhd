-- =============================================================================
--  regmemory.vhd  --  Banco de Registradores  --  RISC-V 32-bit Monociclo
-- =============================================================================
--
--  Responsabilidade deste módulo:
--    Armazenar os 32 registradores de 32 bits do processador (x0 a x31) e
--    permitir:
--      - Leitura combinacional (assíncrona) de dois registradores ao mesmo
--        tempo, através dos endereços endereco_leitura_rs1/rs2.
--      - Escrita síncrona (na borda de subida do clock) de um valor em um
--        único registrador por vez, através de endereco_escrita_rd, quando
--        sinal_escreve_registrador estiver em '1'.
--
--  Observação: este módulo não impede escrita no registrador x0. Em uma
--  implementação real de RISC-V, x0 é sempre zero (hardwired a zero) e
--  escritas nele são ignoradas. Esse comportamento não foi alterado aqui,
--  pois a tarefa é apenas renomear e comentar, não corrigir a lógica.
-- =============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity regmemory is
    port (
        clock : in std_logic; -- clock do sistema, usado para a escrita síncrona

        endereco_leitura_rs1 : in std_logic_vector(4 downto 0); -- endereço do primeiro registrador a ser lido (rs1)
        endereco_leitura_rs2 : in std_logic_vector(4 downto 0); -- endereço do segundo registrador a ser lido (rs2)
        dado_lido_rs1 : out std_logic_vector(31 downto 0); -- valor lido do registrador rs1
        dado_lido_rs2 : out std_logic_vector(31 downto 0); -- valor lido do registrador rs2

        endereco_escrita_rd      : in std_logic_vector(4 downto 0);  -- endereço do registrador de destino a ser escrito (rd)
        sinal_escreve_registrador : in std_logic;                    -- '1' habilita a escrita síncrona no registrador de destino
        dado_para_escrita        : in std_logic_vector(31 downto 0)  -- valor a ser gravado no registrador de destino
        );
    end entity regmemory;
    
architecture arch of regmemory is
    -- Tipo e sinal que representam o banco de 32 registradores de 32 bits.
    type tipo_banco_de_registradores is array (0 to 31) of std_logic_vector(31 downto 0);
    signal banco_de_registradores : tipo_banco_de_registradores := (others => (others => '0'));

    -- Sinais auxiliares abaixo servem apenas para facilitar a visualização
    -- dos primeiros registradores em uma ferramenta de simulação de forma
    -- de onda (GTKWave). Eles não afetam a lógica do processador.

    signal registrador_debug_x0 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x1 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x2 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x3 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x4 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x5 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x6 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x7 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x8 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x9 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x10 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x11 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x12 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x13 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x14 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x15 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x16 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x17 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x18 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x19 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x20 : std_logic_vector(31 downto 0) := (others => '0');
    signal registrador_debug_x21 : std_logic_vector(31 downto 0) := (others => '0');
    
begin

    -- Leitura combinacional (assíncrona): os dois registradores endereçados
    -- por endereco_leitura_rs1/rs2 aparecem imediatamente nas saídas
    -- dado_lido_rs1/rs2, sem esperar borda de clock.
    dado_lido_rs1 <= banco_de_registradores(to_integer(unsigned(endereco_leitura_rs1)));
    dado_lido_rs2 <= banco_de_registradores(to_integer(unsigned(endereco_leitura_rs2)));

    -- Escrita síncrona: só acontece na borda de subida do clock e apenas
    -- quando sinal_escreve_registrador está em '1'.
    process(clock)
    begin
        if rising_edge(clock) then
            if sinal_escreve_registrador = '1' then
                banco_de_registradores(to_integer(unsigned(endereco_escrita_rd))) <= dado_para_escrita;

                -- Atualiza os sinais de depuração usados no GTKWave
                registrador_debug_x0 <= banco_de_registradores(0);
                registrador_debug_x1 <= banco_de_registradores(1);
                registrador_debug_x2 <= banco_de_registradores(2);
                registrador_debug_x3 <= banco_de_registradores(3);
                registrador_debug_x4 <= banco_de_registradores(4);
                registrador_debug_x5 <= banco_de_registradores(5);
                registrador_debug_x6 <= banco_de_registradores(6);
                registrador_debug_x7 <= banco_de_registradores(7);
                registrador_debug_x8 <= banco_de_registradores(8);
                registrador_debug_x9 <= banco_de_registradores(9);
                registrador_debug_x10 <= banco_de_registradores(10);
                registrador_debug_x11 <= banco_de_registradores(11);
                registrador_debug_x12 <= banco_de_registradores(12);
                registrador_debug_x13 <= banco_de_registradores(13);
                registrador_debug_x14 <= banco_de_registradores(14);
                registrador_debug_x15 <= banco_de_registradores(15);
                registrador_debug_x16 <= banco_de_registradores(16);
                registrador_debug_x17 <= banco_de_registradores(17);
                registrador_debug_x18 <= banco_de_registradores(18);
                registrador_debug_x19 <= banco_de_registradores(19);
                registrador_debug_x20 <= banco_de_registradores(20);
                registrador_debug_x21 <= banco_de_registradores(21);

                banco_de_registradores(0) <= (others => '0'); -- x0 é sempre zero
            end if;
        end if;
    end process;

end architecture arch;
