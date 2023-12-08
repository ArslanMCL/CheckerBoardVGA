library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
    Port (
        clk_100MHz : in STD_LOGIC;
        reset      : in STD_LOGIC;
        up         : in STD_LOGIC;
        down       : in STD_LOGIC;
        left       : in STD_LOGIC;
        right      : in STD_LOGIC;
        hsync      : out STD_LOGIC;
        vsync      : out STD_LOGIC;
        rgb        : out STD_LOGIC_VECTOR(11 downto 0);
        seg        : out STD_LOGIC_VECTOR(6 downto 0);
        LED        : out STD_LOGIC_VECTOR(7 downto 0);
        an         : out STD_LOGIC_VECTOR(7 downto 0)
    );
end top;

architecture Behavioral of top is
    signal w_video_on, w_p_tick  : STD_LOGIC;
    signal w_x, w_y              : STD_LOGIC_VECTOR(9 downto 0);
    signal rgb_reg               : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal rgb_next              : STD_LOGIC_VECTOR(11 downto 0);
    signal cntx, cnty            : STD_LOGIC_VECTOR(7 downto 0);
    signal dp                    : STD_LOGIC;
    signal clk_divider : integer:=0;
    signal clk_60Hz              : STD_LOGIC := '0';
    signal led_counter           : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
 
begin

    process (clk_100MHz, reset)
    begin
        if reset = '1' then
            clk_divider <= 0;
        elsif rising_edge(clk_100MHz) then
            if clk_divider = 1666666 then
                clk_divider <= 0;
                clk_60Hz <= not clk_60Hz;
            else
                clk_divider <= clk_divider + 1;
            end if;
        end if;
    end process;
    
    process (clk_60Hz, reset)
    begin
        if reset = '1' then
            led_counter <= "00000000";
        elsif rising_edge(clk_60Hz) then
            led_counter <= led_counter + 1;
        end if;
    end process;

    LED <= led_counter;
    
    vga_controller : entity work.vga_controller
    port map(
        clk_100MHz => clk_100MHz, 
        reset => reset, 
        video_on => w_video_on, 
        hsync => hsync, 
        vsync => vsync, 
        p_tick => w_p_tick, 
        x => w_x, 
        y => w_y
    );

    pixel_generation : entity work.pixel_generation
    port map(
        clk => clk_100MHz, 
        reset => reset, 
        video_on => w_video_on,
        up => up, 
        down => down, 
        left => left, 
        right => right,
        x => w_x, 
        y => w_y, 
        rgb => rgb_next,
        ccountx => cntx,
        ccounty => cnty
    );
    
    seg_display_driver : entity work.seg_display_driver
    port map(
        clk_100MHz => clk_100MHz,
        reset => reset,
        x1 => cntx(3 downto 0),
        x2 => cntx(7 downto 4),
        y1 => cnty(3 downto 0),
        y2 => cnty(7 downto 4),
        seg => seg,
        dp => dp,
        dummy1 => "0000", 
        dummy2 => "0000",
        dummy3 => "0000", 
        dummy4 => "0000",
        digit => an
    );

    process (clk_100MHz)
    begin
        if rising_edge(clk_100MHz) then
            if w_p_tick = '1' then
                rgb_reg <= rgb_next;
            end if;
        end if;
    end process;
    
    rgb <= rgb_reg;
    
end Behavioral;
