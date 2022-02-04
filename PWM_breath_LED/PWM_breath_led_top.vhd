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

constant c_500_Hz : integer := 50000;

signal r_counter : integer range 0 to c_500_Hz := 0;
signal r_upp_time : integer := 0;
signal w_Switch_1_debounce : std_logic;
signal w_Switch_2_debounce : std_logic;

signal r_40ms : integer := 0;
signal r_hundred : integer range 0 to 100 := 0;
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
	
	freq500Hz : process (r_RESET_LOW_SM, i_Clk) is
	begin
	
	if (r_RESET_LOW_SM = '0') then
			r_counter <= 0;
	
		elsif rising_edge(i_Clk) then
			
		
		    if r_counter < c_500_Hz then
				r_counter <= r_counter + 1;
			else
				r_counter <= 0;
			end if;
		end if;
		
	end process freq500Hz;
	
	omapwm : process (r_RESET_LOW_SM, i_Clk) is
	
	begin
	
	if (r_RESET_LOW_SM = '0') then
			r_suunta <= ylos;
			
	elsif rising_edge (i_Clk) then
	
		if r_40ms < 1000000 then 
			r_40ms <= r_40ms + 1;
		else
			r_40ms <= 0;
		end if;
		
		if r_40ms = 1000000 then	
			if r_suunta = ylos then
				if r_hundred < 100 then
					r_hundred <= r_hundred + 1;		
				elsif r_hundred = 100 then
					r_suunta <= alas;
				else
					r_suunta <= r_suunta;
				end if;
			elsif r_suunta = alas then
				if r_hundred > 0 then
					r_hundred <= r_hundred - 1;
				elsif r_hundred = 0 then
					r_suunta <= ylos;
				else
					r_suunta <= r_suunta;
				end if;
			end if;
		else
			r_hundred <= r_hundred;
		end if;
	end if;
		
	r_uptime <= r_hundred * 1000000;

	end process omapwm;
	
	
	
	uptime : process (i_Clk) is
	
	variable v_LED : std_logic_vector(3 downto 0);
	
	begin
	
		if rising_edge (i_Clk) then
		
		if r_counter < (r_uptime / 2000) then
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
				r_upp_time <= 5000;
				r_SM_PWM <= s_PWM_10;
				v_Segment1 := c_zero;
				v_Segment2 := c_one;
				
				
			when s_PWM_10 =>
				r_upp_time <= 10000;
				r_SM_PWM <= s_PWM_20;
				v_Segment1 := c_zero;
				v_Segment2 := c_two;
				

			when s_PWM_20 =>
				r_upp_time <= 15000;
				r_SM_PWM <= s_PWM_30;
				v_Segment1 := c_zero;
				v_Segment2 := c_three;
				
				
			when s_PWM_30 =>
				r_upp_time <= 20000;
				r_SM_PWM <= s_PWM_40;
				v_Segment1 := c_zero;
				v_Segment2 := c_four;
				
				
			when s_PWM_40 =>
				r_upp_time <= 25000;
				r_SM_PWM <= s_PWM_50;
				v_Segment1 := c_zero;
				v_Segment2 := c_five;
			
				
			when s_PWM_50 =>
				r_upp_time <= 30000;
				r_SM_PWM <= s_PWM_60;
				v_Segment1 := c_zero;
				v_Segment2 := c_six;
				
				
			when s_PWM_60 =>
				r_upp_time <= 35000;
				r_SM_PWM <= s_PWM_70;
				v_Segment1 := c_zero;
				v_Segment2 := c_seven;
				
				
			when s_PWM_70 =>
				r_upp_time <= 40000;
				r_SM_PWM <= s_PWM_80;
				v_Segment1 := c_zero;
				v_Segment2 := c_eight;
			
				
			when s_PWM_80 =>
				r_upp_time <= 45000;
				r_SM_PWM <= s_PWM_90;
				v_Segment1 := c_zero;
				v_Segment2 := c_nine;
			
				
			when s_PWM_90 =>
				r_upp_time <= 50000;
				r_SM_PWM <= s_PWM_100;
				v_Segment1 := c_one;
				v_Segment2 := c_zero;
			
				
			when s_PWM_100 =>
				r_upp_time <= 50000;
				r_SM_PWM <= s_PWM_100;
				v_Segment1 := c_one;
				v_Segment2 := c_zero;
				
				
			when others =>
				null;
				
		end case;
		
	elsif (r_i_Switch_2_old2 = '0' and r_i_Switch_2_old = '1') then
	
		case r_SM_PWM is
				
			when s_PWM_0 =>
				r_upp_time <= 0;
				r_SM_PWM <= s_PWM_0;
				v_Segment1 := c_zero;
				v_Segment2 := c_zero;
			
				
			when s_PWM_10 =>
				r_upp_time <= 0;
				r_SM_PWM <= s_PWM_0;
				v_Segment1 := c_zero;
				v_Segment2 := c_zero;
			

			when s_PWM_20 =>
				r_upp_time <= 5000;
				r_SM_PWM <= s_PWM_10;
				v_Segment1 := c_zero;
				v_Segment2 := c_one;
			
				
			when s_PWM_30 =>
				r_upp_time <= 10000;
				r_SM_PWM <= s_PWM_20;
				v_Segment1 := c_zero;
				v_Segment2 := c_two;
			
				
			when s_PWM_40 =>
				r_upp_time <= 15000;
				r_SM_PWM <= s_PWM_30;
				v_Segment1 := c_zero;
				v_Segment2 := c_three;
			
				
			when s_PWM_50 =>
				r_upp_time <= 20000;
				r_SM_PWM <= s_PWM_40;
				v_Segment1 := c_zero;
				v_Segment2 := c_four;
			
				
			when s_PWM_60 =>
				r_upp_time <= 25000;
				r_SM_PWM <= s_PWM_50;
				v_Segment1 := c_zero;
				v_Segment2 := c_five;
			
				
			when s_PWM_70 =>
				r_upp_time <= 30000;
				r_SM_PWM <= s_PWM_60;
				v_Segment1 := c_zero;
				v_Segment2 := c_six;
			
				
			when s_PWM_80 =>
				r_upp_time <= 35000;
				r_SM_PWM <= s_PWM_70;
				v_Segment1 := c_zero;
				v_Segment2 := c_seven;
			
				
			when s_PWM_90 =>
				r_upp_time <= 40000;
				r_SM_PWM <= s_PWM_80;
				v_Segment1 := c_zero;
				v_Segment2 := c_eight;
			
				
			when s_PWM_100 =>
				r_upp_time <= 45000;
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


o_Segment1_A <= not r_Segment1(6);
o_Segment1_B <= not r_Segment1(5);
o_Segment1_C <= not r_Segment1(4);
o_Segment1_D <= not r_Segment1(3);
o_Segment1_E <= not r_Segment1(2);
o_Segment1_F <= not r_Segment1(1);
o_Segment1_G <= not r_Segment1(0);

o_Segment2_A <= not r_Segment2(6);
o_Segment2_B <= not r_Segment2(5);
o_Segment2_C <= not r_Segment2(4);
o_Segment2_D <= not r_Segment2(3);
o_Segment2_E <= not r_Segment2(2);
o_Segment2_F <= not r_Segment2(1);
o_Segment2_G <= not r_Segment2(0);

o_LED_1 <= r_LED(3);
o_LED_2 <= r_LED(2);
o_LED_3 <= r_LED(1);
o_LED_4 <= r_LED(0);

end behave;