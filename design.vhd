library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity design is
    port (
        immediate : in std_logic_vector(31 downto 0); -- Saída do banco de registradores
        reg_out_1, reg_out_2 : in std_logic_vector(31 downto 0);
        ctrl_ual_fonte : in std_logic;
        
        funct50 : in std_logic_vector(5 downto 0); -- para Operação da UAL
        ctrl_ual_op : in std_logic_vector(1 downto 0);
        
        ual_res : out std_logic_vector(31 downto 0); -- Saída da UAL
        ual_zero : out std_logic
        );
end design;

architecture arch of design is
    signal mux_out : std_logic_vector(31 downto 0);
    signal ualop_out : std_logic_vector(3 downto 0);
begin
    MUX: entity work.mux
        port map (
            a => reg_out_2,
            b => immediate,
            sel => ctrl_ual_fonte,
            o => mux_out
        );
    ULAOP: entity work.ulaop
        port map (
            funct50 => funct50,
            ctrl_ual_op => ctrl_ual_op,
            ualop_out => ualop_out
        );
    ULA: entity work.ula
        port map (
            a => reg_out_1,
            b => mux_out,
            op => ualop_out,
            res => ual_res,
            zero => ual_zero
        );
end arch;