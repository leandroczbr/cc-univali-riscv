library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal immediate, reg_out_1, reg_out_2, ins : std_logic_vector(31 downto 0);
    signal ctrl_ual_fonte : std_logic;
    signal ual_res : std_logic_vector(31 downto 0);
    signal ual_zero : std_logic;
begin
    DUT: entity work.design
        port map (
            ins => ins,
            
            immediate => immediate,
            reg_out_1 => reg_out_1,
            reg_out_2 => reg_out_2,
            ctrl_ual_fonte => ctrl_ual_fonte,

            ual_res => ual_res,
            ual_zero => ual_zero
        );
    process
    begin
        ins <= (others => '0');
        immediate <= (others => '0');
        reg_out_1 <= (others => '0'); reg_out_2 <= (others => '0');
        ctrl_ual_fonte <= '0';
        wait for 10 ns;
        ----- Teste a seguir: testar mux do immediate e do reg_out_2
        reg_out_1 <= "00000000000000000000000000000111"; -- 7
        reg_out_2 <= "00000000000000000000000000000101"; -- 5 
        immediate <= "00000000000000000000000000001001"; -- 9
        wait for 10 ns;
        ctrl_ual_fonte <= '1';
        ----- TESTE ACIMA FUNCIONOU
        -- Teste a seguir: testar saída do controle "ualop"
        --
        -- resultados:
        -- 0000 = ADD    0001 = SUB    0010 = AND    0011 = OR
        -- 0100 = XOR    0101 = SLL    0110 = SRL    0111 = SRA
        -- 1000 = SLT    1001 = SLTU
        --
        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "000" & "00000" & "0110011"; -- 0000 = ADD
        wait for 10 ns;
        ins <= "0100000" & "00000" & "00000" & "000" & "00000" & "0110011"; -- 0001 = SUB
        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "111" & "00000" & "0110011"; -- 0010 = AND
        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "110" & "00000" & "0110011"; -- 0011 = OR
        
        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "100" & "00000" & "0110011"; -- 0100 = XOR
        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "001" & "00000" & "0110011"; -- 0101 = SLL
        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "101" & "00000" & "0110011"; -- 0110 = SRL
        wait for 10 ns;
        ins <= "0100000" & "00000" & "00000" & "101" & "00000" & "0110011"; -- 0111 = SRA

        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "010" & "00000" & "0110011"; -- 1000 = SLT
        wait for 10 ns;
        ins <= "0000000" & "00000" & "00000" & "011" & "00000" & "0110011"; -- 1001 = SLTU
        
        wait for 10 ns;
        wait;
    end process;
end;