library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity pixel_generation is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           video_on : in STD_LOGIC;
           x : in std_logic_vector(9 downto 0);
           y : in std_logic_vector(9 downto 0);
           up : in STD_LOGIC;
           down : in STD_LOGIC;
           left : in STD_LOGIC;
           right : in STD_LOGIC;
           rgb : out std_logic_vector(11 downto 0);
           ccountx : out std_logic_vector(7 downto 0);
           ccounty : out std_logic_vector(7 downto 0));
end pixel_generation;

architecture Behavioral of pixel_generation is
    -- Constants
    constant X_MAX : natural := 640;
    constant Y_MAX : natural := 480;
    constant RED_SQ_RGB : std_logic_vector(11 downto 0) := "000000001111";
    constant BLUE_SQUARE : std_logic_vector(11 downto 0) := "111100000000";
    constant GREEN_SQUARE : std_logic_vector(11 downto 0) := "000011110000";
    constant SQUARE_SIZE : natural := X_MAX/15;
    constant SQUARE_VELOCITY : natural := 1;
    constant DEBOUNCE_TIME : natural := 5000000;
    
    -- Signals
    signal up_counter, down_counter, left_counter, right_counter : integer:=0;
    signal up_debounced, down_debounced, left_debounced, right_debounced : std_logic;
    signal up_prev, down_prev, left_prev, right_prev : std_logic := '0';
    signal up_rising, down_rising, left_rising, right_rising : std_logic;
    signal sq_x_l, sq_x_r : integer;
    signal sq_y_t, sq_y_b : integer;
    signal sq_x_reg, sq_y_reg : integer:=0;
    signal is_green_square : std_logic;
    signal countx :  integer:=0;
    signal county :  integer:=0;
    signal xv,yv:integer;
    signal sq_on,vid_on : std_logic;
    --signal up_rising, down_rising, left_rising, right_rising : std_logic;
    
begin
process(x, y)
begin
    xv <= to_integer(unsigned(x));
    yv <= to_integer(unsigned(y));
end process;
debounce_process: process(clk, reset)
begin
    if reset = '1' then
        up_counter <= 0;
        up_debounced <= '0';
        down_counter <= 0;
        down_debounced <= '0';
        left_counter <= 0;
        left_debounced <= '0';
        right_counter <= 0;
        right_debounced <= '0';
    elsif rising_edge(clk) then
        -- Debounce logic for 'up' button
        if up = '1' then
            if up_counter < DEBOUNCE_TIME then
                up_counter <= up_counter + 1;
            else
                up_debounced <= '1';
            end if;
        else
            up_counter <= 0;
            up_debounced <= '0';
        end if;
        -- Debounce logic for 'down' button
        if down = '1' then
            if down_counter < DEBOUNCE_TIME then
                down_counter <= down_counter + 1;
            else
                down_debounced <= '1';
            end if;
        else
            down_counter <= 0;
            down_debounced <= '0';
        end if;

        -- Debounce logic for 'left' button
        if left = '1' then
            if left_counter < DEBOUNCE_TIME then
                left_counter <= left_counter + 1;
            else
                left_debounced <= '1';
            end if;
        else
            left_counter <= 0;
            left_debounced <= '0';
        end if;

        -- Debounce logic for 'right' button
        if right = '1' then
            if right_counter < DEBOUNCE_TIME then
                right_counter <= right_counter + 1;
            else
                right_debounced <= '1';
            end if;
        else
            right_counter <= 0;
            right_debounced <= '0';
        end if;
    end if;
end process debounce_process;



store_prev_state_process: process(clk, reset)
begin
    if reset = '1' then
        up_prev <= '0';
        down_prev <= '0';
        left_prev <= '0';
        right_prev <= '0';
    elsif rising_edge(clk) then
        up_prev <= up_debounced;
        down_prev <= down_debounced;
        left_prev <= left_debounced;
        right_prev <= right_debounced;
    end if;
end process store_prev_state_process;

process(clk, reset)
begin
    if reset = '1' then
        sq_x_reg <= 0;
        sq_y_reg <= 0;
        countx <= 0;
        county <= 0000;

    elsif rising_edge(clk) then
        -- Up Movement
        if up_rising = '1' then
            if sq_y_reg > 0 then
                sq_y_reg <= sq_y_reg - SQUARE_SIZE;
            else
                sq_y_reg <= SQUARE_SIZE * 19;
            end if;
            
            if county = 0 then
                county <= 19;
            else
                county <= county - 1;
            end if;
        end if;

        -- Down Movement
        if down_rising = '1' then
            if sq_y_reg < SQUARE_SIZE * 19 then
                sq_y_reg <= sq_y_reg + SQUARE_SIZE;
            else
                sq_y_reg <= 0;
            end if;
            
            if county = 19 then
                county <= 0;
            else
                county <= county + 1;
            end if;
        end if;

        -- Left Movement
        if left_rising = '1' then
            if sq_x_reg > 0 then
                sq_x_reg <= sq_x_reg - SQUARE_SIZE;
            else
                sq_x_reg <= SQUARE_SIZE * 14;
            end if;

            if countx = 0 then
                countx <= 14;
            else
                countx <= countx - 1;
            end if;
        end if;

        -- Right Movement
        if right_rising = '1' then
            if sq_x_reg < SQUARE_SIZE * 14 then
                sq_x_reg <= sq_x_reg + SQUARE_SIZE;
            else
                sq_x_reg <= 0;
            end if;

            if countx = 14 then
                countx <= 0;
            else
                countx <= countx + 1;
            end if;
        end if;
    end if;
end process;

-- Checkerboard pattern logic
    process(xv, yv)
begin
    if ((xv / SQUARE_SIZE) + (yv / SQUARE_SIZE)) mod 2 = 1 then
        is_green_square <= '1';
    else
        is_green_square <= '0';
    end if;
end process;

    -- Detect the rising edge for debounced buttons
    up_rising <= up_debounced and (not up_prev);
    down_rising <= down_debounced and (not down_prev);
    left_rising <= left_debounced and (not left_prev);
    right_rising <= right_debounced and (not right_prev);
    

-- Boundaries for moving square
sq_x_l <= sq_x_reg;
sq_y_t <= sq_y_reg;
sq_x_r <= sq_x_l + SQUARE_SIZE - 1;
sq_y_b <= sq_y_t + SQUARE_SIZE - 1;

-- Status signal for moving square

process(sq_x_l, sq_x_r, sq_y_t, sq_y_b, x, y)
begin
    if (sq_x_l <= xv) and (xv <= sq_x_r) and (sq_y_t <= yv) and (yv <= sq_y_b) then
        sq_on <= '1';
    else
        sq_on <= '0';
    end if;
end process;



-- RGB control
process(video_on, sq_on, is_green_square)
begin

    if  (video_on='0') then
        rgb <= X"000";
    elsif sq_on = '1' then
        rgb <= RED_SQ_RGB;
    elsif is_green_square = '1' then
        rgb <= GREEN_SQUARE;
    else
        rgb <= BLUE_SQUARE;
    end if;
end process;

process(countx,county)
begin
    ccountx <= std_logic_vector(to_unsigned(countx, ccountx'length));
    ccounty <= std_logic_vector(to_unsigned(county, ccounty'length));
end process;

end Behavioral;
