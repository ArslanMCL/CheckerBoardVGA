library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_controller is
    Port ( clk_100MHz : in STD_LOGIC;
           reset      : in STD_LOGIC;
           video_on   : out STD_LOGIC;
           hsync      : out STD_LOGIC;
           vsync      : out STD_LOGIC;
           p_tick     : out STD_LOGIC;
           x          : out STD_LOGIC_VECTOR(9 downto 0);
           y          : out STD_LOGIC_VECTOR(9 downto 0));
end vga_controller;

architecture Behavioral of vga_controller is

    -- Parameters based on VGA standards for 640x480 resolution
    constant HD   : natural := 640;
    constant HF   : natural := 48;
    constant HB   : natural := 16;
    constant HR   : natural := 96;
    constant HMAX : natural := HD + HF + HB + HR - 1;
    constant VD   : natural := 480;
    constant VF   : natural := 10;
    constant VB   : natural := 33;
    constant VR   : natural := 2;
    constant VMAX : natural := VD + VF + VB + VR - 1;

    signal r_25MHz        : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal w_25MHz        : STD_LOGIC;
    signal h_count_reg    : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
    signal h_count_next   : STD_LOGIC_VECTOR(9 downto 0);
    signal v_count_reg    : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
    signal v_count_next   : STD_LOGIC_VECTOR(9 downto 0);
    signal v_sync_reg     : STD_LOGIC := '0';
    signal v_sync_next    : STD_LOGIC;
    signal h_sync_reg     : STD_LOGIC := '0';
    signal h_sync_next    : STD_LOGIC;

begin

    -- Generate 25MHz from 100MHz
    process(clk_100MHz, reset)
    begin
        if reset = '1' then
            r_25MHz <= "00";
        elsif rising_edge(clk_100MHz) then
            r_25MHz <= r_25MHz + 1;
        end if;
    end process;

    w_25MHz <= '1' when r_25MHz = "00" else '0';

    -- Register Control
    process(clk_100MHz, reset)
    begin
        if reset = '1' then
            v_count_reg <= "0000000000";
            h_count_reg <= "0000000000";
            v_sync_reg  <= '0';
            h_sync_reg  <= '0';
        elsif rising_edge(clk_100MHz) then
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end if;
    end process;

    -- Logic for horizontal counter
    process(w_25MHz, reset)
    begin
        if reset = '1' then
            h_count_next <= "0000000000";
        elsif rising_edge(w_25MHz) then
            if h_count_reg = HMAX then
                h_count_next <= "0000000000";
            else
                h_count_next <= h_count_reg + 1;
            end if;
        end if;
    end process;

    -- Logic for vertical counter
    process(w_25MHz, reset)
    begin
        if reset = '1' then
            v_count_next <= "0000000000";
        elsif rising_edge(w_25MHz) then
            if h_count_reg = HMAX then
                if v_count_reg = VMAX then
                    v_count_next <= "0000000000";
                else
                    v_count_next <= v_count_reg + 1;
                end if;
            end if;
        end if;
    end process;

    h_sync_next <= '1' when (h_count_reg >= (HD + HB)) and (h_count_reg <= (HD + HB + HR - 1)) else '0';
    v_sync_next <= '1' when (v_count_reg >= (VD + VB)) and (v_count_reg <= (VD + VB + VR - 1)) else '0';

    video_on <= '1' when (h_count_reg < HD) and (v_count_reg < VD) else '0';

    -- Outputs
    hsync  <= h_sync_reg;
    vsync  <= v_sync_reg;
    x      <= h_count_reg;
    y      <= v_count_reg;
    p_tick <= w_25MHz;

end Behavioral;
