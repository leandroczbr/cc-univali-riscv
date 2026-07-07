--controle.vhd
library IEEE;
use IEEE.std_logic_1164.all;

entity controle is
    port (
        clk : in std_logic;
        Sixbitsin : in std_logic_vector(5 downto 0);
        
        RegDst : out std_logic;
        AluSrc : out std_logic;
        MemparaReg : out std_logic;
        EscreveReg : out std_logic;
        LeMem : out std_logic;
        EscreveMem : out std_logic;
        Branch : out std_logic
        --OpALU1
        --OpALU0
    );
end controle;

architecture arch of controle is
    signal formatoR, lw, sw, beq : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case Sixbitsin is
                when "000000" =>
                    formatoR <= '1';
                    lw <= '0';
                    sw <= '0';
                    beq <= '0';
                when "100011" =>
                    formatoR <= '0';
                    lw <= '1';
                    sw <= '0';
                    beq <= '0';
                when "101011" =>
                    formatoR <= '0';
                    lw <= '0';
                    sw <= '1';
                    beq <= '0';
                when "000100" =>
                    formatoR <= '0';
                    lw <= '0';
                    sw <= '0';
                    beq <= '1';
                when others =>
                    formatoR <= '0';
                    lw <= '0';
                    sw <= '0';
                    beq <= '0';                   
            end case;
            regDst <= formatoR;
            aluSrc <= lw or sw;
            memparaReg <= lw;
            escreveReg <= formatoR or lw;
            leMem <= lw;
            escreveMem <= sw;
            branch <= beq;
            --OpALU1 <= formatoR;
            --OpALU0 <= beq;
        end if;
    end process;
end architecture arch;