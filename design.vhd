--design.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity design is
    port (
        clk : in std_logic := '0';

        ins : in std_logic_vector(31 downto 0) := (others => '0'); -- Instrução

        immediate : in std_logic_vector(31 downto 0) := (others => '0');            -- Imediato
        --ctrl_ual_fonte : in std_logic := '0';                           -- responde Imediato Ou Registrador?
        
        ual_res : out std_logic_vector(31 downto 0); -- Saída da UAL
        ual_zero : out std_logic;

        teste_valorrrrrrrrrrrrrrrrrrrrrrrrrr : in std_logic_vector(31 downto 0) := (others => '0'); -- Valor a ser adicionado ao registrador
        teste_registradorrrrrrrrrrrrrrrrrrrrrrrrrr : in std_logic_vector(4 downto 0) := (others => '0'); -- Registrador a ser adicionado o valor
        testar : in std_logic := '0' -- Sinal para testar a adição do valor ao registrador
        );
end design;

architecture arch of design is
    signal mux_out : std_logic_vector(31 downto 0) := (others => '0');
    signal ualop_out : std_logic_vector(3 downto 0) := (others => '0');
    signal ins_signal : std_logic_vector(31 downto 0) := (others => '0');
    signal regmemory_out_1, regmemory_out_2 : std_logic_vector(31 downto 0) := (others => '0');

    signal saidadomuxdoRegDst : std_logic_vector(4 downto 0) := (others => '0');

    signal saidaDaUlaDeVoltaProReg : std_logic_vector(31 downto 0) := (others => '0');

    signal RegDst : std_logic := '0';
    signal AluSrc : std_logic := '0';
    signal MemparaReg : std_logic := '0';
    signal EscreveReg : std_logic := '0';
    signal LeMem : std_logic := '0';
    signal EscreveMem : std_logic := '0';
    signal Branch : std_logic := '0';
begin
    ins_signal <= ins;

    CONTROLE: entity work.controle
        port map (
            clk => clk,
            Sixbitsin => ins_signal(31 downto 26),

            RegDst => RegDst,
            AluSrc => AluSrc,
            MemparaReg => MemparaReg,
            EscreveReg => EscreveReg,
            LeMem => LeMem,
            EscreveMem => EscreveMem,
            Branch => Branch
        );

    MUXRegDst: entity work.mux5
        port map (
            a => ins_signal(19 downto 15),
            b => ins_signal(14 downto 10),
            sel => RegDst,
            o => saidadomuxdoRegDst
        );

    REGMEMORY: entity work.regmemory
        port map (
            clk => clk,
            
            rs1 => ins_signal(24 downto 20),
            rs2 => ins_signal(19 downto 15),
            out1 => regmemory_out_1,
            out2 => regmemory_out_2,
            
            addr_write => saidadomuxdoRegDst,
            rw => EscreveReg,
            datain => saidaDaUlaDeVoltaProReg
        );
    
    MUX: entity work.mux32
        port map (
            a => regmemory_out_2,
            b => immediate,
            sel => AluSrc,
            o => mux_out
        );
    ULAOP: entity work.ulaop
        port map (
            first3bits => ins_signal(14 downto 12),
            last1bit => ins(30),
            ualop_out => ualop_out
        );
    ULA: entity work.ula
        port map (
            a => regmemory_out_1,
            b => mux_out,
            op => ualop_out,
            res => saidaDaUlaDeVoltaProReg,
            zero => ual_zero
        );

end arch;