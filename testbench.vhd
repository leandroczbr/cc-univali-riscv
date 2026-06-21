library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal a, b, res : std_logic_vector(31 downto 0);
    signal op : std_logic_vector(3 downto 0);
    signal zero : std_logic;
begin
    DUT: entity work.Ula
        port map (
            a => a,
            b => b,
            op => op,
            res => res,
            zero => zero
        );
    process
    begin
        a <= "00000000000000000000000000001001"; -- 9
        b <= "00000000000000000000000000000111"; -- 7
        op <= "0000"; -- ADD
        wait for 10 ns;
        op <= "0001"; -- SUB
        wait for 10 ns;
        op <= "0010"; -- AND
        wait for 10 ns;
        op <= "0011"; -- OR
        wait for 10 ns;
        op <= "0100"; -- XOR
        wait for 10 ns;
        op <= "0101"; -- SLL
        wait for 10 ns;
        a <= "00000000000000000000111100000000";
        b <= "00000000000000000000000000001000";
        op <= "0110"; -- SRL
        wait for 10 ns;
        op <= "0111"; -- SRA
        wait for 10 ns;
        op <= "1000"; -- SLT
        wait for 10 ns;
        op <= "1001"; -- SLTU
        wait for 10 ns;
        wait;
    end process;
end;