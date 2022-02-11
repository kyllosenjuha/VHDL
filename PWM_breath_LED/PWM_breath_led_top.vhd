library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_breath_led_top is
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
end PWM_breath_led_top;

architecture behave of PWM_breath_led_top is

type t_suunta is (ylos, alas);
type t_SM_PWM is (s_PWM_0, s_PWM_10, s_PWM_20, s_PWM_30, s_PWM_40, s_PWM_50,
				  s_PWM_60, s_PWM_70, s_PWM_80, s_PWM_90, s_PWM_100);

signal r_SM_PWM : t_SM_PWM;
signal r_suunta : t_suunta;
signal r_Count_SM : integer range 0 to 20000 := 0;
signal r_RESET_LOW_SM : std_logic := '0';
signal r_Segment1 : std_logic_vector(7 downto 0);
signal r_Segment2 : std_logic_vector(7 downto 0);
signal r_Segment1_sykkiva : std_logic_vector(7 downto 0);
signal r_Segment2_sykkiva : std_logic_vector(7 downto 0);
signal r_LED : std_logic_vector(3 downto 0);

signal r_i_Switch_1_old : std_logic;
signal r_i_Switch_1_old2 : std_logic;
signal r_i_Switch_2_old : std_logic;
signal r_i_Switch_2_old2 : std_logic;

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

constant c_PWM_freq_counter : integer := c_clock_25MHz/c_PWM_frequency_Hz;
constant c_PWM_freq_counter_PWM_part : integer := c_PWM_freq_counter/c_PWM_parts;
constant c_PWM_freq_counter_ten_part : integer := c_PWM_freq_counter/10;



signal r_counter : integer range 0 to c_PWM_freq_counter := 0;
signal r_upp_time : integer := 0;
signal w_Switch_1_debounce : std_logic;
signal w_Switch_2_debounce : std_logic;

signal r_final : integer := 0;
signal r_PWM : integer range 0 to c_PWM_parts := 0;
signal r_uptime : integer := 0;

	
	component debounce_switch is
	  port (
		i_Clk    : in  std_logic;
		i_Switch : in  std_logic;
		o_Switch : out std_logic
		);
	end component debounce_switch;

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
	
	
	Inst_switch_1 : debounce_switch
		port map(i_Clk      => i_Clk,
				 i_Switch => i_Switch_1,
				 o_Switch => w_Switch_1_debounce
				);

	Inst_switch_2 : debounce_switch
		port map(i_Clk      => i_Clk,
				 i_Switch => i_Switch_2,
				 o_Switch => w_Switch_2_debounce
				);
	
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
	
	omapwm : process (r_RESET_LOW_SM, i_Clk) is
	
	begin
	
	if (r_RESET_LOW_SM = '0') then
			r_suunta <= ylos;
			
	elsif rising_edge (i_Clk) then
	
		if r_final < c_delay_final_counter-1 then 
			r_final <= r_final + 1;
		else
			r_final <= 0;
		end if;
		
		if r_final = c_delay_final_counter-1 then	
			if r_suunta = ylos then
				if r_PWM < c_PWM_parts then
					r_PWM <= r_PWM + 1;		
				elsif r_PWM = c_PWM_parts then
					r_suunta <= alas;
				else
					r_suunta <= r_suunta;
				end if;
			elsif r_suunta = alas then
				if r_PWM > 0 then
					r_PWM <= r_PWM - 1;
				elsif r_PWM = 0 then
					r_suunta <= ylos;
				else
					r_suunta <= r_suunta;
				end if;
			end if;
		else
			r_PWM <= r_PWM;
		end if;
	end if;
		
	r_uptime <= r_PWM * c_PWM_freq_counter_PWM_part;

	end process omapwm;
	
	
	
	uptime : process (i_Clk) is
	
	variable v_LED : std_logic_vector(3 downto 0);
	
	begin
	
		if rising_edge (i_Clk) then
		
		if r_counter < r_uptime then
			v_LED := "1111";
		else
			v_LED := "0000";
		end if;
		
		r_LED <= v_LED;
		end if;
		
	end process uptime;
	
p_SET_SEGMENTS_AND_LEDS : process(r_RESET_LOW_SM, i_Clk) is

variable v_Segment1 : std_logic_vector(7 downto 0);
variable v_Segment2 : std_logic_vector(7 downto 0);

	begin

	
	if (r_RESET_LOW_SM = '0') then
			r_SM_PWM <= s_PWM_0;
			v_Segment1 := c_zero;
			v_Segment2 := c_zero;

	elsif rising_edge(i_Clk) then
	
	r_i_Switch_1_old <= w_Switch_1_debounce;
	r_i_Switch_1_old2 <= r_i_Switch_1_old;
	
	r_i_Switch_2_old <= w_Switch_2_debounce;
	r_i_Switch_2_old2 <= r_i_Switch_2_old;
			
	if (r_i_Switch_1_old2 = '0' and r_i_Switch_1_old = '1') then
		
		case r_SM_PWM is
				
			when s_PWM_0 =>
				r_upp_time <= c_PWM_freq_counter_ten_part;
				r_SM_PWM <= s_PWM_10;
				v_Segment1 := c_zero;
				v_Segment2 := c_one;
				
				
			when s_PWM_10 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*2;
				r_SM_PWM <= s_PWM_20;
				v_Segment1 := c_zero;
				v_Segment2 := c_two;
				

			when s_PWM_20 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*3;
				r_SM_PWM <= s_PWM_30;
				v_Segment1 := c_zero;
				v_Segment2 := c_three;
				
				
			when s_PWM_30 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*4;
				r_SM_PWM <= s_PWM_40;
				v_Segment1 := c_zero;
				v_Segment2 := c_four;
				
				
			when s_PWM_40 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*5;
				r_SM_PWM <= s_PWM_50;
				v_Segment1 := c_zero;
				v_Segment2 := c_five;
			
				
			when s_PWM_50 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*6;
				r_SM_PWM <= s_PWM_60;
				v_Segment1 := c_zero;
				v_Segment2 := c_six;
				
				
			when s_PWM_60 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*7;
				r_SM_PWM <= s_PWM_70;
				v_Segment1 := c_zero;
				v_Segment2 := c_seven;
				
				
			when s_PWM_70 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*8;
				r_SM_PWM <= s_PWM_80;
				v_Segment1 := c_zero;
				v_Segment2 := c_eight;
			
				
			when s_PWM_80 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*9;
				r_SM_PWM <= s_PWM_90;
				v_Segment1 := c_zero;
				v_Segment2 := c_nine;
			
				
			when s_PWM_90 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*10;
				r_SM_PWM <= s_PWM_100;
				v_Segment1 := c_one;
				v_Segment2 := c_zero;
			
				
			when s_PWM_100 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*10;
				r_SM_PWM <= s_PWM_100;
				v_Segment1 := c_one;
				v_Segment2 := c_zero;
				
				
			when others =>
				null;
				
		end case;
		
	elsif (r_i_Switch_2_old2 = '0' and r_i_Switch_2_old = '1') then
	
		case r_SM_PWM is
				
			when s_PWM_0 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*0;
				r_SM_PWM <= s_PWM_0;
				v_Segment1 := c_zero;
				v_Segment2 := c_zero;
			
				
			when s_PWM_10 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*0;
				r_SM_PWM <= s_PWM_0;
				v_Segment1 := c_zero;
				v_Segment2 := c_zero;
			

			when s_PWM_20 =>
				r_upp_time <= c_PWM_freq_counter_ten_part;
				r_SM_PWM <= s_PWM_10;
				v_Segment1 := c_zero;
				v_Segment2 := c_one;
			
				
			when s_PWM_30 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*2;
				r_SM_PWM <= s_PWM_20;
				v_Segment1 := c_zero;
				v_Segment2 := c_two;
			
				
			when s_PWM_40 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*3;
				r_SM_PWM <= s_PWM_30;
				v_Segment1 := c_zero;
				v_Segment2 := c_three;
			
				
			when s_PWM_50 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*4;
				r_SM_PWM <= s_PWM_40;
				v_Segment1 := c_zero;
				v_Segment2 := c_four;
			
				
			when s_PWM_60 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*5;
				r_SM_PWM <= s_PWM_50;
				v_Segment1 := c_zero;
				v_Segment2 := c_five;
			
				
			when s_PWM_70 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*6;
				r_SM_PWM <= s_PWM_60;
				v_Segment1 := c_zero;
				v_Segment2 := c_six;
			
				
			when s_PWM_80 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*7;
				r_SM_PWM <= s_PWM_70;
				v_Segment1 := c_zero;
				v_Segment2 := c_seven;
			
				
			when s_PWM_90 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*8;
				r_SM_PWM <= s_PWM_80;
				v_Segment1 := c_zero;
				v_Segment2 := c_eight;
			
				
			when s_PWM_100 =>
				r_upp_time <= c_PWM_freq_counter_ten_part*9;
				r_SM_PWM <= s_PWM_90;
				v_Segment1 := c_zero;
				v_Segment2 := c_nine;
			
				
			when others =>
				null;
				
		end case;
	
	end if;
	
	end if;
	
	r_Segment1 <= v_Segment1;
	r_Segment2 <= v_Segment2;	
	
end process p_SET_SEGMENTS_AND_LEDS;

sevenSegSykkiva : process (i_Clk) is
begin
	if rising_edge(i_Clk) then
		if r_counter < r_uptime then
			r_Segment1_sykkiva <= not r_Segment1;
			r_Segment2_sykkiva <= not r_Segment2;
		else
			r_Segment1_sykkiva <= X"FF";
			r_Segment2_sykkiva <= X"FF";
		end if;
	end if;
		
end process sevenSegSykkiva; 


o_Segment1_A <= r_Segment1_sykkiva(6);
o_Segment1_B <= r_Segment1_sykkiva(5);
o_Segment1_C <= r_Segment1_sykkiva(4);
o_Segment1_D <= r_Segment1_sykkiva(3);
o_Segment1_E <= r_Segment1_sykkiva(2);
o_Segment1_F <= r_Segment1_sykkiva(1);
o_Segment1_G <= r_Segment1_sykkiva(0);

o_Segment2_A <= r_Segment2_sykkiva(6);
o_Segment2_B <= r_Segment2_sykkiva(5);
o_Segment2_C <= r_Segment2_sykkiva(4);
o_Segment2_D <= r_Segment2_sykkiva(3);
o_Segment2_E <= r_Segment2_sykkiva(2);
o_Segment2_F <= r_Segment2_sykkiva(1);
o_Segment2_G <= r_Segment2_sykkiva(0);

o_LED_1 <= r_LED(3);
o_LED_2 <= r_LED(2);
o_LED_3 <= r_LED(1);
o_LED_4 <= r_LED(0);

end behave;

