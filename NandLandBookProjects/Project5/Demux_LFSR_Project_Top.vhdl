library ieee;
use ieee.std_logic_1164.all;

entity Demux_LFSR_Project_Top is
    port (
        i_Clk      : in  std_logic;
        i_Switch_1 : in  std_logic;
        i_Switch_2 : in  std_logic;
        o_LED_1    : out std_logic;
        o_LED_2    : out std_logic;
        o_LED_3    : out std_logic;
        o_LED_4    : out std_logic
    );
end entity Demux_LFSR_Project_Top;


-- All commented out code uses the LFSR instead of a counter for toggling
architecture RTL of Demux_LFSR_Project_Top is
    --signal r_LFSR_Toggle : std_logic := '0';
    --signal w_LFSR_Done   : std_logic;
    constant COUNT_LIMIT      : integer := 4194303;
    signal   w_Counter_Toggle : std_logic;

begin
    --LFSR_22 : entity work.LFSR_22
    --port map (
        --i_Clk       => i_Clk,
        --o_LFSR_Data => open, -- unconnected (we don't need the data, just the done signal)
        --o_LFSR_Done => w_LFSR_Done
    --);

    --process (i_Clk) is
    --begin
        --if rising_edge(i_Clk) then
            --if w_LFSR_Done = '1' then
                --r_LFSR_Toggle <= not r_LFSR_Toggle;
            --end if;
        --end if;
    --end process;
    Toggle_Counter : entity work.Count_And_Toggle
    generic map (
        COUNT_LIMIT => COUNT_LIMIT
    )
    port map (
        i_Clk    => i_Clk,
        i_Enable => '1',
        o_Toggle => w_Counter_Toggle
    );

    Demux_Inst : entity work.Demux_1_To_4
    port map (
        --i_Data  => r_LFSR_Toggle,
        i_Data  => w_Counter_Toggle,
        i_Sel0  => i_Switch_1,
        i_Sel1  => i_Switch_2,
        o_Data0 => o_LED_1,
        o_Data1 => o_LED_2,
        o_Data2 => o_LED_3,
        o_Data3 => o_LED_4
    );
end architecture RTL;