library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_KITT2 is
	port(
		i_Clk 	   : in std_logic;
		i_Switch_1 : in std_logic;
		i_Switch_2 : in std_logic;
		
		o_LED_1 : out std_logic;
		o_LED_2 : out std_logic;
		o_LED_3 : out std_logic;
		o_LED_4 : out std_logic;
		
		o_Segment1_A : out std_logic;
		o_Segment1_B : out std_logic;
		o_Segment1_C : out std_logic;
		o_Segment1_D : out std_logic;
		o_Segment1_E : out std_logic;
		o_Segment1_F : out std_logic;
		o_Segment1_G : out std_logic;
		
		o_Segment2_A : out std_logic;
		o_Segment2_B : out std_logic;
		o_Segment2_C : out std_logic;
		o_Segment2_D : out std_logic;
		o_Segment2_E : out std_logic;
		o_Segment2_F : out std_logic;
		o_Segment2_G : out std_logic
		);
end PWM_KITT2;

architecture behave of PWM_KITT2 is

type t_SM_KITT is (s_one, s_two, s_three, s_four, s_five, s_six);
type t_suunta is (ylos, alas);
type t_SM_PWM is (s_PWM_0, s_PWM_10, s_PWM_20, s_PWM_30, s_PWM_40, s_PWM_50,
				  s_PWM_60, s_PWM_70, s_PWM_80, s_PWM_90, s_PWM_100);
signal r_SM_KITT : t_SM_KITT;
signal r_SM_PWM : t_SM_PWM;
signal r_suunta : t_suunta;
signal r_Count_SM : integer range 0 to 20000 := 0;
signal r_RESET_LOW_SM : std_logic := '0';
signal r_Segment1 : std_logic_vector(7 downto 0);
signal r_Segment2 : std_logic_vector(7 downto 0);
signal r_Segment1_sykkiva : std_logic_vector(7 downto 0);
signal r_Segment2_sykkiva : std_logic_vector(7 downto 0);
signal r_LED : std_logic_vector(3 downto 0);


constant c_zero 	: std_logic_vector(7 downto 0) := X"7E";
constant c_one 		: std_logic_vector(7 downto 0) := X"30";
constant c_two 		: std_logic_vector(7 downto 0) := X"6D";
constant c_three 	: std_logic_vector(7 downto 0) := X"79";
constant c_four 	: std_logic_vector(7 downto 0) := X"33";
constant c_five 	: std_logic_vector(7 downto 0) := X"5B";
constant c_six 		: std_logic_vector(7 downto 0) := X"5F";
constant c_seven 	: std_logic_vector(7 downto 0) := X"70";
constant c_eight 	: std_logic_vector(7 downto 0) := X"7F";
constant c_nine 	: std_logic_vector(7 downto 0) := X"7B";

constant c_PWM_parts : integer := 100;
constant c_PWM_frequency_Hz : integer := 500;
constant c_clock_25MHz : integer := 25000000;
constant c_half_period_ms : integer := 1000;

constant c_delay_ms : integer := c_half_period_ms/c_PWM_parts;
constant c_delay_final_counter : integer := c_clock_25MHz*c_delay_ms/1000;
constant c_delay_final_half_second : integer := c_clock_25MHz/2;

constant c_PWM_freq_counter : integer := c_clock_25MHz/c_PWM_frequency_Hz;
constant c_PWM_freq_counter_PWM_part : integer := c_PWM_freq_counter/c_PWM_parts;
constant c_PWM_freq_counter_ten_part : integer := c_PWM_freq_counter/10;



signal r_counter : integer range 0 to c_PWM_freq_counter := 0;
signal r_upp_time : integer := 0;
signal w_Switch_1_debounce : std_logic;
signal w_Switch_2_debounce : std_logic;

signal r_final : integer := 0;
signal r_final_500 : integer := 0;

signal r_PWM : integer range 0 to c_PWM_parts := 0;
signal r_LED_PWM_1 : integer := 0;
signal r_LED_PWM_2 : integer := 0;
signal r_LED_PWM_3 : integer := 0;
signal r_LED_PWM_4 : integer := 0;

signal r_uptime : integer := 0;

constant c_uptime_0 : integer := 0;
constant c_uptime_12 : integer := 1;
constant c_uptime_25 : integer := 5;
constant c_uptime_50 : integer := 10;
constant c_uptime_100 : integer := 50;
signal r_uptime_1 : integer := 0;
signal r_uptime_2 : integer := 0;
signal r_uptime_3 : integer := 0;
signal r_uptime_4 : integer := 0;


begin

Initialize_SM : process (i_Clk) is
	
	begin
		if rising_edge(i_Clk) then
		
			if (r_Count_SM < 10000) then
				r_Count_SM <= r_count_SM + 1;
				r_RESET_LOW_SM <= '1';
			elsif (r_Count_SM < 20000) then
				r_Count_SM <= r_count_SM + 1;
				r_RESET_LOW_SM <= '0';
			else
				r_RESET_LOW_SM <= '1';
			end if;
			
		end if;
	end process Initialize_SM;
	
	freqHz : process (r_RESET_LOW_SM, i_Clk) is
	begin
	
	if (r_RESET_LOW_SM = '0') then
			r_counter <= 0;
	
		elsif rising_edge(i_Clk) then
			
		
		    if r_counter < c_PWM_freq_counter-1 then
				r_counter <= r_counter + 1;
			else
				r_counter <= 0;
			end if;
		end if;
		
	end process freqHz;
	

p_KITT_SM : process(r_RESET_LOW_SM, i_Clk) is


begin

	if (r_RESET_LOW_SM = '0') then
			r_SM_KITT <= s_one;
			--v_LEDS := c_one;
			r_LED_PWM_1 <= c_uptime_0;
			r_LED_PWM_2 <= c_uptime_0;
			r_LED_PWM_3 <= c_uptime_0;
			r_LED_PWM_4 <= c_uptime_0;

	elsif rising_edge(i_Clk) then
	
		if r_final_500 < c_delay_final_half_second-1 then 
			r_final_500 <= r_final_500 + 1;
		else
			r_final_500 <= 0;
		end if;
		
		if r_final_500 = c_delay_final_half_second-1 then
		
			case r_SM_KITT is
			
			when s_one =>
				r_LED_PWM_1 <= c_uptime_12;
				r_LED_PWM_2 <= c_uptime_25;
				r_LED_PWM_3 <= c_uptime_50;
				r_LED_PWM_4 <= c_uptime_100;
				r_SM_KITT <= s_two;
				
			when s_two =>
				r_LED_PWM_1 <= c_uptime_0;
				r_LED_PWM_2 <= c_uptime_12;
				r_LED_PWM_3 <= c_uptime_100;
				r_LED_PWM_4 <= c_uptime_50;
				r_SM_KITT <= s_three;
				
			when s_three =>
				r_LED_PWM_1 <= c_uptime_0;
				r_LED_PWM_2 <= c_uptime_100;
				r_LED_PWM_3 <= c_uptime_50;
				r_LED_PWM_4 <= c_uptime_25;
				r_SM_KITT <= s_four;
				
			when s_four =>
				r_LED_PWM_1 <= c_uptime_100;
				r_LED_PWM_2 <= c_uptime_50;
				r_LED_PWM_3 <= c_uptime_25;
				r_LED_PWM_4 <= c_uptime_12;
				r_SM_KITT <= s_five;
			
			when s_five =>
				r_LED_PWM_1 <= c_uptime_50;
				r_LED_PWM_2 <= c_uptime_100;
				r_LED_PWM_3 <= c_uptime_12;
				r_LED_PWM_4 <= c_uptime_0;
				r_SM_KITT <= s_six;
				
			when s_six =>
				r_LED_PWM_1 <= c_uptime_25;
				r_LED_PWM_2 <= c_uptime_50;
				r_LED_PWM_3 <= c_uptime_100;
				r_LED_PWM_4 <= c_uptime_0;
				r_SM_KITT <= s_one;
			
			when others =>
				null;
				
			end case;
			
		end if;
		
		end if;
			
			
			r_uptime_1 <= r_LED_PWM_1 * c_PWM_freq_counter_PWM_part;
			r_uptime_2 <= r_LED_PWM_2 * c_PWM_freq_counter_PWM_part;
			r_uptime_3 <= r_LED_PWM_3 * c_PWM_freq_counter_PWM_part;
			r_uptime_4 <= r_LED_PWM_4 * c_PWM_freq_counter_PWM_part;
			
		

end process p_KITT_SM;


uptime_KITT : process (i_Clk) is
	
	begin
	
		if rising_edge (i_Clk) then
		
		if r_counter < r_uptime_1 then
			r_LED(3) <= '1';
		else
			r_LED(3) <= '0';
		end if;
		
		if r_counter < r_uptime_2 then
			r_LED(2) <= '1';
		else
			r_LED(2) <= '0';
		end if;
		
		if r_counter < r_uptime_3 then
			r_LED(1) <= '1';
		else
			r_LED(1) <= '0';
		end if;
		
		if r_counter < r_uptime_4 then
			r_LED(0) <= '1';
		else
			r_LED(0) <= '0';
		end if;
		
		end if;
		
	end process uptime_KITT;


o_Segment1_A <= '1';
o_Segment1_B <= '1';
o_Segment1_C <= '1';
o_Segment1_D <= '1';
o_Segment1_E <= '1';
o_Segment1_F <= '1';
o_Segment1_G <= '1';

o_Segment2_A <= '1';
o_Segment2_B <= '1';
o_Segment2_C <= '1';
o_Segment2_D <= '1';
o_Segment2_E <= '1';
o_Segment2_F <= '1';
o_Segment2_G <= '1';

o_LED_1 <= r_LED(3);
o_LED_2 <= r_LED(2);
o_LED_3 <= r_LED(1);
o_LED_4 <= r_LED(0);

end behave;

