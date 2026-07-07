library ieee;
use ieee.std_logic_1164.all;

entity ulaop is
    port (
        campo_funct3         : in  std_logic_vector(2 downto 0); -- funct3 da instrução (bits 14 downto 12)
        bit30_da_instrucao   : in  std_logic;                    -- bit 30 da instrução (funct7[5] no formato-R)
        sinal_alu_op         : in  std_logic_vector(1 downto 0); -- "00"=LW/SW, "01"=BEQ, "10"=R, "11"=I aritmético
        codigo_operacao_ula  : out std_logic_vector(3 downto 0)  -- código de operação enviado para a ULA
    );
end ulaop;

architecture arch of ulaop is
begin
    process(campo_funct3, bit30_da_instrucao, sinal_alu_op)
    begin
        case sinal_alu_op is

            when "00" => -- LW / SW: a ULA calcula endereço (base + offset)
                codigo_operacao_ula <= "0000"; -- ADD

            when "01" => -- BEQ: a ULA subtrai para testar igualdade (zero)
                codigo_operacao_ula <= "0001"; -- SUB

            when others => -- "10" = formato-R, "11" = formato-I aritmético
                case campo_funct3 is
                    when "000" =>
                        -- Formato-R: bit30 diferencia ADD (0) de SUB (1).
                        -- Formato-I: SEMPRE ADD — o bit30 é parte do imediato!
                        if sinal_alu_op = "10" and bit30_da_instrucao = '1' then
                            codigo_operacao_ula <= "0001"; -- SUB
                        else
                            codigo_operacao_ula <= "0000"; -- ADD / ADDI
                        end if;

                    when "001" =>
                        codigo_operacao_ula <= "0101"; -- SLL / SLLI

                    when "010" =>
                        codigo_operacao_ula <= "1000"; -- SLT / SLTI

                    when "011" =>
                        codigo_operacao_ula <= "1001"; -- SLTU / SLTIU

                    when "100" =>
                        codigo_operacao_ula <= "0100"; -- XOR / XORI

                    when "101" =>
                        if bit30_da_instrucao = '0' then
                            codigo_operacao_ula <= "0110"; -- SRL / SRLI
                        else
                            codigo_operacao_ula <= "0111"; -- SRA / SRAI
                        end if;

                    when "110" =>
                        codigo_operacao_ula <= "0011"; -- OR / ORI

                    when "111" =>
                        codigo_operacao_ula <= "0010"; -- AND / ANDI

                    when others =>
                        codigo_operacao_ula <= (others => '0');
                end case;
        end case;
    end process;
end architecture arch;
