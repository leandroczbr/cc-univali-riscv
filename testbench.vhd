library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal immediate, reg_out_1, reg_out_2 : std_logic_vector(31 downto 0);
    signal ctrl_ual_fonte : std_logic;
    signal funct50 : std_logic_vector(5 downto 0);
    signal ctrl_ual_op : std_logic_vector(1 downto 0);
    signal ual_res : std_logic_vector(31 downto 0);
    signal ual_zero : std_logic;
begin
    DUT: entity work.design
        port map (
            immediate => immediate,
            reg_out_1 => reg_out_1,
            reg_out_2 => reg_out_2,
            ctrl_ual_fonte => ctrl_ual_fonte,
            funct50 => funct50,
            ctrl_ual_op => ctrl_ual_op,
            ual_res => ual_res,
            ual_zero => ual_zero
        );
    process
    begin
        immediate <= (others => '0'); reg_out_1 <= (others => '0'); reg_out_2 <= (others => '0');
        funct50 <= (others => '0'); ctrl_ual_op <= "00";
        ctrl_ual_fonte <= '0'; ual_zero <= '0';
        wait for 10 ns;
        ----- Teste a seguir: testar mux do immediate e do reg_out_2
        --immediate <= "00000000000000000000000000001001"; -- 9
        --reg_out_1 <= "00000000000000000000000000000111"; -- 7
        --reg_out_2 <= "00000000000000000000000000000101"; -- 5
        --wait for 10 ns;
        --ctrl_ual_fonte <= '1';
        --wait for 10 ns;
        ----- TESTE ACIMA FUNCIONOU
        -- Teste a seguir: testar saída do controle "ualop"
        ctrl_ual_op <= "01";
        funct50 <= "000000";
        wait for 10 ns;
        ctrl_ual_op <= "10";
        wait for 10 ns;
        funct50 <= "000010";
        wait for 10 ns;
        funct50 <= "000100";
        wait for 10 ns;
        funct50 <= "000101";
        wait for 10 ns;
        funct50 <= "001010";
        wait for 10 ns;
        ----- TESTE ACIMA FUNCIONOU
        wait;
    end process;
end;