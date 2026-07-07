library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity immgen is
    port (
        ins_in : in std_logic_vector(31 downto 0);
        imm_out : out std_logic_vector(31 downto 0);
        sinal_tipo_instrucao_in : in std_logic_vector(1 downto 0) -- '00' = tipo-R, '01' = LW, '10' = SW, '11' = BEQ
    );
end entity immgen;

architecture arch of immgen is
begin
    process(sinal_tipo_instrucao_in)
    begin
            case sinal_tipo_instrucao_in is
                when "00" => -- tipo-R
                    imm_out <= (others => '0'); -- Para instruções tipo-R, o imediato é zero
                when "01" => -- LW
                    imm_out <= std_logic_vector(resize(signed(ins_in(31 downto 20)), 32)); -- Imediato de 12 bits para LW
                when "10" => -- SW
                    imm_out <= std_logic_vector(resize(signed(ins_in(31 downto 25) & ins_in(11 downto 7)), 32)); -- Imediato de 12 bits para SW
                when "11" => -- BEQ
                    imm_out <= std_logic_vector(resize(signed(ins_in(31) & ins_in(7) & ins_in(30 downto 25) & ins_in(11 downto 8) & '0'), 32)); -- Imediato de 13 bits para BEQ (deslocado à esquerda)
                when others =>
                    imm_out <= (others => '0'); -- Default para outros casos
            end case;
    end process;
end arch;