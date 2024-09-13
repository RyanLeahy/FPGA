library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SyncPorchGenerator_tb is
end entity SyncPorchGenerator_tb;

architecture test of SyncPorchGenerator_tb is
    signal r_Clk, w_HSync, w_VSync          : std_logic := '0';
    signal w_Porched_HSync, w_Porched_VSync : std_logic := '0';
    signal w_Col_Count, w_Row_Count         : std_logic_vector(9 downto 0) := "0000000000";
begin
    r_Clk <= not r_Clk after 1 ns;

    SPG : entity work.SyncPulseGenerator
        port map (
            i_Clk       => r_Clk,
            o_HSync     => w_HSync,
            o_VSync     => w_VSync,
            o_Row_Count => w_Row_Count,
            o_Col_Count => w_Col_Count
        );

    UUT : entity work.SyncPorchGenerator
        port map (
            i_Clk           => r_Clk,
            i_HSync         => w_HSync,
            i_VSync         => w_VSync,
            i_Row_Count     => w_Row_Count,
            i_Col_Count     => w_Col_Count,
            o_Porched_HSync => w_Porched_HSync,
            o_Porched_VSync => w_Porched_VSync
        );

    process is
    begin
        wait until w_Porched_HSync = '1' and w_Porched_VSync = '1';
        assert(w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and
               w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length)))
               report "Initial condition not working."
               severity error;
    
        wait until w_Porched_HSync = '0' and w_Porched_VSync = '1';
        assert(w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and
               w_Col_Count = std_logic_vector(to_unsigned(658, w_Col_Count'length)))
                report "First column front porch not occurring at the right column."
                severity error;

        wait until w_Porched_HSync = '1' and w_Porched_VSync = '1';
        assert(w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and
               w_Col_Count = std_logic_vector(to_unsigned(750, w_Col_Count'length)))
                report "First column back porch not occurring at the right column."
                severity error;

        wait until w_Porched_HSync = '1' and w_Porched_VSync = '0';
        assert(w_Row_Count = std_logic_vector(to_unsigned(490, w_Row_Count'length)) and
               w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length)))
                report "First row front porch not occurring at the right row."
                severity error;

        wait until w_Porched_HSync = '0' and w_Porched_VSync = '1';
        assert(w_Row_Count = std_logic_vector(to_unsigned(492, w_Row_Count'length)) and
               w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length)))
                report "First row back porch not occurring at the right row."
                severity error;

        wait until w_Porched_HSync = '0' and w_Porched_VSync = '0';
        assert(w_Row_Count = std_logic_vector(to_unsigned(490, w_Row_Count'length)) and
               w_Col_Count = std_logic_vector(to_unsigned(658, w_Col_Count'length)))
                report "Column and row front porch not occurring at the right column and row."
                severity error;

        wait until w_Porched_HSync = '1' and w_Porched_VSync = '1';
        assert(w_Row_Count = std_logic_vector(to_unsigned(492, w_Row_Count'length)) and
               w_Col_Count = std_logic_vector(to_unsigned(750, w_Col_Count'length)))
                report "Column and row back porch not occurring at the right column and row."
                severity error;

        wait for 10 ns; -- Give it a few more clock cycles at the end for graph visualization

        assert false report "Test: OK" severity failure;
    end process;
end test;