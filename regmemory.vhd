--regmemory.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity regmemory is
    port (
        clk : in std_logic;

        rs1 : in std_logic_vector(4 downto 0);
        rs2 : in std_logic_vector(4 downto 0);
        out1 : out std_logic_vector(31 downto 0);
        out2 : out std_logic_vector(31 downto 0);
        
        addr_write : in std_logic_vector(4 downto 0);
        rw : in std_logic;
        datain : in std_logic_vector(31 downto 0)
        );
    end entity regmemory;
    
architecture arch of regmemory is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0) ;
    signal memory : reg_array := (others => (others => '0'));

    -- Para conseguir ver no GTKWave

    signal x0 : std_logic_vector(31 downto 0) := (others => '0');
    signal x1 : std_logic_vector(31 downto 0) := (others => '0');
    signal x2 : std_logic_vector(31 downto 0) := (others => '0');
    signal x3 : std_logic_vector(31 downto 0) := (others => '0');
    signal x4 : std_logic_vector(31 downto 0) := (others => '0');
    signal x5 : std_logic_vector(31 downto 0) := (others => '0');
begin

    out1 <= memory(to_integer(unsigned(rs1)));
    out2 <= memory(to_integer(unsigned(rs2)));

    process(clk)
    begin
        if rising_edge(clk) then
            if rw = '1' then
                memory(to_integer(unsigned(addr_write))) <= datain;
                x0 <= memory(0);
                x1 <= memory(1);
                x2 <= memory(2);
                x3 <= memory(3);
                x4 <= memory(4);
                x5 <= memory(5);
            end if;
        end if;
    end process;

end architecture arch;