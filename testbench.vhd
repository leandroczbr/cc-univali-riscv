--testbench.vhd
library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal immediate, reg_out_1, reg_out_2, ins : std_logic_vector(31 downto 0) := (others => '0');
    signal ctrl_ual_fonte : std_logic := '0';
    signal ual_res : std_logic_vector(31 downto 0) := (others => '0');
    signal ual_zero : std_logic := '0';

    signal teste_valorrrrrrrrrrrrrrrrrrrrrrrrrr : std_logic_vector(31 downto 0) := (others => '0');
    signal teste_registradorrrrrrrrrrrrrrrrrrrrrrrrrr : std_logic_vector(4 downto 0) := (others => '0');
    signal testar : std_logic := '0';

    signal clk : std_logic := '0';
    signal SinalMudancaTeste : integer := 0;
begin
    DUT: entity work.design
        port map (
            ins => ins,
            
            clk => clk,
            
            immediate => immediate,

            ual_res => ual_res,
            ual_zero => ual_zero,

            teste_valorrrrrrrrrrrrrrrrrrrrrrrrrr => teste_valorrrrrrrrrrrrrrrrrrrrrrrrrr,
            teste_registradorrrrrrrrrrrrrrrrrrrrrrrrrr => teste_registradorrrrrrrrrrrrrrrrrrrrrrrrrr,
            testar => testar
        );
    process
    begin

        -- Teste a seguir: testar a adição de valores aos registradores
        SinalMudancaTeste <= 0;

        wait for 10 ns;

        -- Settar reg x01 para 8195
        teste_registradorrrrrrrrrrrrrrrrrrrrrrrrrr <= "00001"; -- Registrador 1
        teste_valorrrrrrrrrrrrrrrrrrrrrrrrrr <= "00000000000000000010000000000011"; -- Valor 8195
        testar <= '1';
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;

        -- Settar reg x02 para 5
        teste_registradorrrrrrrrrrrrrrrrrrrrrrrrrr <= "00010"; -- Registrador 2
        teste_valorrrrrrrrrrrrrrrrrrrrrrrrrr <= "00000000000000000000000000000101"; -- Valor 5
        testar <= '1';
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;

        -- Settar instrução para ler reg x01 e reg x02
        ins <= "0000000" & "00001" & "00010" & "000" & "00000" & "0110011"; -- ADD
        wait for 10 ns;

        
        ----- Teste a seguir: testar mux do immediate e do reg_out_2
        --SinalMudancaTeste <= 1;
        --immediate <= "00000000000000000000000000001010"; -- Valor 10
        --ctrl_ual_fonte <= '0';
        --wait for 10 ns;
        --ctrl_ual_fonte <= '1';
        --wait for 10 ns;

        -- Teste a seguir: testar saída do controle "ualop"
        --
        -- resultados:
        -- 0000 = ADD    0001 = SUB    0010 = AND    0011 = OR
        -- 0100 = XOR    0101 = SLL    0110 = SRL    0111 = SRA
        -- 1000 = SLT    1001 = SLTU
        --
        SinalMudancaTeste <= 2;
        ctrl_ual_fonte <= '0';
        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "000" & "00000" & "0110011"; -- 0000 = ADD
        wait for 10 ns;
        ins <= "0100000" & "00001" & "00010" & "000" & "00000" & "0110011"; -- 0001 = SUB
        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "111" & "00000" & "0110011"; -- 0010 = AND
        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "110" & "00000" & "0110011"; -- 0011 = OR
    
        wait for 10 ns;
        SinalMudancaTeste <= 3;

        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "100" & "00000" & "0110011"; -- 0100 = XOR
        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "001" & "00000" & "0110011"; -- 0101 = SLL
        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "101" & "00000" & "0110011"; -- 0110 = SRL
        wait for 10 ns;
        ins <= "0100000" & "00001" & "00010" & "101" & "00000" & "0110011"; -- 0111 = SRA

        wait for 10 ns;
        SinalMudancaTeste <= 4;
        
        -- Settar reg x02 para -5
        teste_registradorrrrrrrrrrrrrrrrrrrrrrrrrr <= "00010"; -- Registrador 2
        teste_valorrrrrrrrrrrrrrrrrrrrrrrrrr <= "11111111111111111111111111111011"; -- Valor -5
        testar <= '1';
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;

        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "010" & "00000" & "0110011"; -- 1000 = SLT
        wait for 10 ns;
        ins <= "0000000" & "00001" & "00010" & "011" & "00000" & "0110011"; -- 1001 = SLTU
        wait for 10 ns;
        ins <= "0000000" & "00010" & "00001" & "010" & "00000" & "0110011"; -- 1000 = SLT
        wait for 10 ns;
        ins <= "0000000" & "00010" & "00001" & "011" & "00000" & "0110011"; -- 1001 = SLTU
        
        wait for 10 ns;
        SinalMudancaTeste <= 5;

        wait for 10 ns;
        wait;
    end process;
end;