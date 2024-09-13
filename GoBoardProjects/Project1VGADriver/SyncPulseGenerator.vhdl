library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SyncPulseGenerator is
    generic (
        g_TOTAL_COLS  : integer := 800;
        g_TOTAL_ROWS  : integer := 525;
        g_ACTIVE_COLS : integer := 640;
        g_ACTIVE_ROWS : integer := 480
    );

    port (
        i_Clk       : in  std_logic;
        o_HSync     : out std_logic;
        o_VSync     : out std_logic;
        o_Col_Count : out std_logic_vector(9 downto 0);
        o_Row_Count : out std_logic_vector(9 downto 0)
    );
end entity SyncPulseGenerator;

architecture RTL of SyncPulseGenerator is

    signal r_Col_Count : integer range 0 to g_TOTAL_COLS-1 := 0;
    signal r_Row_Count : integer range 0 to g_TOTAL_ROWS-1 := 0;

begin
    process(i_Clk) is
    begin
        if rising_edge(i_Clk) then
            if r_Col_Count = g_TOTAL_COLS-1 then     -- Terminal count on column
                if r_Row_Count = g_TOTAL_ROWS-1 then -- Also terminal count on row
                    r_Row_Count <= 0;
                else                                 -- Not terminal count for row, increment counter
                    r_Row_Count <= r_Row_Count + 1;
                end if;
                r_Col_Count <= 0;
            else                                     -- Not terminal count on column, increment counter
                r_Col_Count <= r_Col_Count + 1;
            end if;
        end if;
    end process;

    o_HSync <= '1' when r_Col_Count < g_ACTIVE_COLS else '0';
    o_VSync <= '1' when r_Row_Count < g_ACTIVE_ROWS else '0';

    o_Col_Count <= std_logic_vector(to_unsigned(r_Col_Count, o_Col_Count'length));
    o_Row_Count <= std_logic_vector(to_unsigned(r_Row_Count, o_Col_Count'length));

end architecture RTL;