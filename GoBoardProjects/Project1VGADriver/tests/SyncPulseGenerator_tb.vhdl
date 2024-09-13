library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SyncPulseGenerator_tb is
end entity SyncPulseGenerator_tb;

architecture test of SyncPulseGenerator_tb is
    signal r_Clk, w_HSync, w_VSync  : std_logic := '0';
    signal w_Col_Count, w_Row_Count : std_logic_vector(9 downto 0) := "0000000000";
begin
    r_Clk <= not r_Clk after 1 ns;
    
    UUT : entity work.SyncPulseGenerator
        generic map (
            g_TOTAL_COLS  => 10,
            g_TOTAL_ROWS  => 10,
            g_ACTIVE_COLS => 6,
            g_ACTIVE_ROWS => 6
        )

        port map (
            i_Clk       => r_Clk,
            o_HSync     => w_HSync,
            o_VSync     => w_VSync,
            o_Row_Count => w_Row_Count,
            o_Col_Count => w_Col_Count
        );

    process is
    begin
        wait until w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '1') report "Initial check not working." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(1, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '1') report "Column count increased and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(5, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '1') report "Column count approaching end of active region and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(6, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '0') report "Column count out of active region and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(1, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '1') report "Row count increased and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(5, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '1') report "Row count approaching end of active region and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(5, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(5, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '1') report "Both row and column are approaching the end of their respective active regions and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(5, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(6, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '0') report "Row is approaching the end of its active region and column outside of it and an error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(6, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length));
        assert(w_VSync = '0' and w_HSync = '1') report "Row count out of active region and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(6, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(6, w_Col_Count'length));
        assert(w_VSync = '0' and w_HSync = '0') report "Row and column count out of active region and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(9, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(9, w_Col_Count'length));
        assert(w_VSync = '0' and w_HSync = '0') report "Row and column count approaching beginning of active region and error occurred." severity error;

        wait until w_Row_Count = std_logic_vector(to_unsigned(0, w_Row_Count'length)) and w_Col_Count = std_logic_vector(to_unsigned(0, w_Col_Count'length));
        assert(w_VSync = '1' and w_HSync = '1') report "Row and column did not loop back properly." severity error;

        wait for 10 ns; -- Give it a few more clock cycles at the end for graph visualization

        assert false report "Test: OK" severity failure;
    end process;
end test;