library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SyncPorchGenerator is
    generic (
        g_ACTIVE_COLS       : integer := 640;
        g_COLS_FRONT_PORCH  : integer :=  18;
        g_COLS_SYNC         : integer :=  92;
        g_COLS_BACK_PORCH   : integer :=  50;

        g_ACTIVE_ROWS       : integer := 480;
        g_ROWS_FRONT_PORCH  : integer :=  10;
        g_ROWS_SYNC         : integer :=   2;
        g_ROWS_BACK_PORCH   : integer :=  33
    );

    port (
        i_Clk               : in  std_logic;
        i_HSync             : in  std_logic;
        i_VSync             : in  std_logic;
        i_Col_Count         : in  std_logic_vector(9 downto 0);
        i_Row_Count         : in  std_logic_vector(9 downto 0);
        o_Porched_HSync     : out std_logic;
        o_Porched_VSync     : out std_logic
    );
end entity SyncPorchGenerator;

architecture RTL of SyncPorchGenerator is

    signal r_Col_Low_Count : integer range 0 to g_COLS_FRONT_PORCH + g_COLS_SYNC + g_COLS_BACK_PORCH := 0;
    signal r_Row_Low_Count : integer range 0 to g_ROWS_FRONT_PORCH + g_ROWS_SYNC + g_ROWS_BACK_PORCH := 0;

begin
    process(i_Clk) is
    begin
        if rising_edge(i_Clk) then
            if i_HSync = '0' and g_ACTIVE_COLS-1 <= to_integer(unsigned(i_Col_Count)) then
                r_Col_Low_Count <= r_Col_Low_Count + 1; -- Keep track of how many column count events we spend with HSync low 
            else
                r_Col_Low_Count <= 0;
            end if;

            if i_VSync = '0' and 0 = to_integer(unsigned(i_Col_Count))
                             and g_ACTIVE_ROWS-1 <= to_integer(unsigned(i_Row_Count)) then
                r_Row_Low_Count <= r_Row_Low_Count + 1; -- Keep track of how many row count events we spend with VSync low
            else
                r_Row_Low_Count <= 0;
            end if;
        end if;
    end process;

    -- The sync signals will go low earlier than we want with a front and back porch.
    -- When the sync signal is low, we want our signal to go low when it's in the sync pulse window of the sync signal being low
    -- The way I track where we are in the sync window is by counting how many counts have occurred while the sync signal has been low.
    -- When that "low count" is within the sync pulse range, drive the signal low, otherwise, keep it high.
    -- That window begins when the low count is equivalent to the front porch count and ends when we get past the front porch count and sync count combined.
    o_Porched_HSync <= '0' when r_Col_Low_Count >= g_COLS_FRONT_PORCH and r_Col_Low_Count < g_COLS_FRONT_PORCH + g_COLS_SYNC else '1';
    o_Porched_VSync <= '0' when r_Row_Low_Count >= g_ROWS_FRONT_PORCH and r_Row_Low_Count < g_ROWS_FRONT_PORCH + g_ROWS_SYNC else '1';

end architecture RTL;