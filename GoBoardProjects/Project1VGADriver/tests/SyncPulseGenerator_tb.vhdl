library ieee;
use ieee.std_logic_1164.all;

entity SyncPulseGenerator_tb is
end entity SyncPulseGenerator_tb;

architecture test of SyncPulseGenerator_tb is
    signal r_Clk, w_HSync, w_VSync  : std_logic := '0';
    signal w_Col_Count, w_Row_Count : std_logic_vector(9 downto 0) := "0000000000";
begin
    r_Clk <= not r_Clk after 1 ns;
    
    UUT : entity work.SyncPulseGenerator
        generic map (
            g_TOTAL_COLS  => 4,
            g_TOTAL_ROWS  => 4,
            g_ACTIVE_COLS => 2,
            g_ACTIVE_ROWS => 2
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
        wait until w_Row_Count = "0000000000" and w_Col_Count = "0000000000";
        assert(w_VSync = '1' and w_HSync = '1') report "Initial check not working." severity error;

        wait until w_Row_Count = "0000000000" and w_Col_Count = "0000000001";
        assert(w_VSync = '1' and w_HSync = '1') report "Column count increased and error occurred." severity error;

        wait until w_Row_Count = "0000000000" and w_Col_Count = "0000000011";
        assert(w_VSync = '1' and w_HSync = '0') report "Column count out of active region and error occurred." severity error;

        wait until w_Row_Count = "0000000001" and w_Col_Count = "0000000000";
        assert(w_VSync = '1' and w_HSync = '1') report "Row count increased and error occurred." severity error;

        wait until w_Row_Count = "0000000010" and w_Col_Count = "0000000000";
        assert(w_VSync = '0' and w_HSync = '1') report "Row count out of active region and error occurred." severity error;

        wait until w_Row_Count = "0000000010" and w_Col_Count = "0000000010";
        assert(w_VSync = '0' and w_HSync = '0') report "Both row and column out of active region and error occurred." severity error;

        assert false report "Test: OK" severity failure;
    end process;
end test;