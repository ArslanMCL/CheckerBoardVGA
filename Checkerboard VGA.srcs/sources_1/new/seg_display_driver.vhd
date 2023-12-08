library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg_display_driver is
    Port (
        clk_100MHz : in STD_LOGIC;
        reset : in STD_LOGIC;
        x1 : in STD_LOGIC_VECTOR(3 downto 0);
        x2 : in STD_LOGIC_VECTOR(3 downto 0);
        y1 : in STD_LOGIC_VECTOR(3 downto 0);
        y2 : in STD_LOGIC_VECTOR(3 downto 0);
        dummy1 : in STD_LOGIC_VECTOR(3 downto 0);
        dummy2 : in STD_LOGIC_VECTOR(3 downto 0);
        dummy3 : in STD_LOGIC_VECTOR(3 downto 0);
        dummy4 : in STD_LOGIC_VECTOR(3 downto 0);
        seg : out STD_LOGIC_VECTOR(6 downto 0);  -- segment pattern 0-9
        dp : out STD_LOGIC;                     -- decimal point
        digit : out STD_LOGIC_VECTOR(7 downto 0) -- digit select signals
    );
end seg_display_driver;

architecture Behavioral of seg_display_driver is
    -- Parameters for segment patterns
constant ZERO  : STD_LOGIC_VECTOR(6 downto 0) := "1000000";  -- 0
constant ONE   : STD_LOGIC_VECTOR(6 downto 0) := "1111001";  -- 1
constant TWO   : STD_LOGIC_VECTOR(6 downto 0) := "0100100";  -- 2 
constant THREE : STD_LOGIC_VECTOR(6 downto 0) := "0110000";  -- 3
constant FOUR  : STD_LOGIC_VECTOR(6 downto 0) := "0011001";  -- 4
constant FIVE  : STD_LOGIC_VECTOR(6 downto 0) := "0010010";  -- 5
constant SIX   : STD_LOGIC_VECTOR(6 downto 0) := "0000010";  -- 6
constant SEVEN : STD_LOGIC_VECTOR(6 downto 0) := "1111000";  -- 7
constant EIGHT : STD_LOGIC_VECTOR(6 downto 0) := "0000000";  -- 8
constant NINE  : STD_LOGIC_VECTOR(6 downto 0) := "0010000";  -- 9
constant A     : STD_LOGIC_VECTOR(6 downto 0) := "0001000";  -- A
constant B     : STD_LOGIC_VECTOR(6 downto 0) := "0000011";  -- B
constant C     : STD_LOGIC_VECTOR(6 downto 0) := "1000110";  -- C
constant D     : STD_LOGIC_VECTOR(6 downto 0) := "0100001";  -- D
constant E     : STD_LOGIC_VECTOR(6 downto 0) := "0000110";  -- E
constant F     : STD_LOGIC_VECTOR(6 downto 0) := "0001110";  -- F


    -- To select each digit in turn
    signal digit_select : STD_LOGIC_VECTOR(2 downto 0);    -- 3 bit counter for selecting each of 8 digits
    signal digit_timer : integer:=0;    -- counter for digit refresh

begin
    -- Logic for controlling digit select and digit timer
process (clk_100MHz, reset)
begin
    if (reset = '1') then
        digit_select <= "000";     -- Assuming digit_select is a 3-bit signal
        digit_timer <= 0;
        
    elsif rising_edge(clk_100MHz) then
        if digit_timer = 99999 then   -- Assuming digit_timer is 17-bit (from 0 to 99_999)
            digit_timer <= 0;
            digit_select <= std_logic_vector(unsigned(digit_select) + 1);
        else
            digit_timer <= digit_timer + 1;
        end if;
    end if;
end process;

-- Logic for driving the 8 bit anode output based on digit select
process (digit_select)
begin
    case digit_select is
        when "000" => digit <= "11111110";
        when "001" => digit <= "11111101";
        when "010" => digit <= "11111011";
        when "011" => digit <= "11110111";
        when "100" => digit <= "11101111";
        when "101" => digit <= "11011111";
        when "110" => digit <= "10111111";
        when "111" => digit <= "01111111";
        when others => digit <= (others => '1'); -- Default case if needed
    end case;
end process;


-- Logic for driving segments based on which digit is selected and the value of each digit
process (digit_select, x1, x2, y1, y2, dummy1, dummy2, dummy3, dummy4)
begin
    case digit_select is
        when "000" =>  -- 1/100 of Seconds 1s DIGIT
            dp <= '1';
            case x1 is
                when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;

        when "001" =>  -- 1/100 of Seconds 10s DIGIT
            dp <= '1';
            case x2 is
               when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;
                
        when "010" =>  -- Seconds 1s DIGIT
            dp <= '0';
            case y1 is
                 when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;

        when "011" =>  -- Seconds 10s DIGIT
            dp <= '1';
            case y2 is
                 when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;

        when "100" => 
            dp <= '1';
            case dummy1 is
                 when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;

        when "101" => 
            dp <= '1';
            case dummy2 is
                 when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;

        when "110" => 
            dp <= '1';
            case dummy3 is
                 when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;

        when "111" => 
            dp <= '1';
            case dummy4 is
                 when "0000" => seg <= ZERO;
                when "0001" => seg <= ONE;
                when "0010" => seg <= TWO;
                when "0011" => seg <= THREE;
                when "0100" => seg <= FOUR;
                when "0101" => seg <= FIVE;
                when "0110" => seg <= SIX;
                when "0111" => seg <= SEVEN;
                when "1000" => seg <= EIGHT;
                when "1001" => seg <= NINE;
                when "1010" => seg <= A;
                when "1011" => seg <= B;
                when "1100" => seg <= C;
                when "1101" => seg <= D;
                when "1110" => seg <= E;
                when "1111" => seg <= F;
                when others => null;
            end case;

        when others => 
            dp <= '0'; -- default value if needed
            seg <= (others => '0'); -- default value if needed
    end case;
end process;


end Behavioral;
