library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity set_volume is
	port(
		i_Clk 	   : in std_logic;
		i_Switch_1 : in std_logic;
		i_Switch_3 : in std_logic;
		
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
end set_volume;

architecture behave of set_volume is

type t_SM_VOL is (s_VOL_0, s_VOL_1, s_VOL_2, s_VOL_3, s_VOL_4, s_VOL_5,
				  s_VOL_6, s_VOL_7, s_VOL_8, s_VOL_9, s_VOL_10);

signal r_SM_VOL : t_SM_VOL;
signal r_Count_SM : integer range 0 to 20000 := 0;
signal r_RESET_LOW_SM : std_logic := '0';
signal r_Segment1 : std_logic_vector(7 downto 0);
signal r_Segment2 : std_logic_vector(7 downto 0);
signal r_LED : std_logic_vector(3 downto 0);

signal r_i_Switch_1_old : std_logic;
signal r_i_Switch_1_old2 : std_logic;
signal r_i_Switch_3_old : std_logic;
signal r_i_Switch_3_old2 : std_logic;

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
	
p_SET_SEGMENTS_AND_LEDS : process(r_RESET_LOW_SM, i_Clk) is

variable v_Segment1 : std_logic_vector(7 downto 0);
variable v_Segment2 : std_logic_vector(7 downto 0);
variable v_LED : std_logic_vector(3 downto 0);

	begin

	
	if (r_RESET_LOW_SM = '0') then
			r_SM_VOL <= s_VOL_0;
			v_Segment1 := c_zero;
			v_Segment2 := c_zero;
			v_LED := "0000";
			r_Segment1 <= v_Segment1;
			r_Segment2 <= v_Segment2;
			r_LED <= v_LED;

	elsif rising_edge(i_Clk) then
	
	r_i_Switch_1_old <= i_Switch_1;
	r_i_Switch_1_old2 <= r_i_Switch_1_old;
	
	r_i_Switch_3_old <= i_Switch_3;
	r_i_Switch_3_old2 <= r_i_Switch_3_old;
			
	if (r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
		
		case r_SM_VOL is
				
			when s_VOL_0 =>
				r_SM_VOL <= s_VOL_1;
				v_Segment1 := c_zero;
				v_Segment2 := c_one;
				v_LED := "1000";
				
			when s_VOL_1 =>
				r_SM_VOL <= s_VOL_2;
				v_Segment1 := c_zero;
				v_Segment2 := c_two;
				v_LED := "1000";

			when s_VOL_2 =>
				r_SM_VOL <= s_VOL_3;
				v_Segment1 := c_zero;
				v_Segment2 := c_three;
				v_LED := "1000";
				
			when s_VOL_3 =>
				r_SM_VOL <= s_VOL_4;
				v_Segment1 := c_zero;
				v_Segment2 := c_four;
				v_LED := "1100";
				
			when s_VOL_4 =>
				r_SM_VOL <= s_VOL_5;
				v_Segment1 := c_zero;
				v_Segment2 := c_five;
				v_LED := "1100";
				
			when s_VOL_5 =>
				r_SM_VOL <= s_VOL_6;
				v_Segment1 := c_zero;
				v_Segment2 := c_six;
				v_LED := "1100";
				
			when s_VOL_6 =>
				r_SM_VOL <= s_VOL_7;
				v_Segment1 := c_zero;
				v_Segment2 := c_seven;
				v_LED := "1110";
				
			when s_VOL_7 =>
				r_SM_VOL <= s_VOL_8;
				v_Segment1 := c_zero;
				v_Segment2 := c_eight;
				v_LED := "1110";
				
			when s_VOL_8 =>
				r_SM_VOL <= s_VOL_9;
				v_Segment1 := c_zero;
				v_Segment2 := c_nine;
				v_LED := "1110";
				
			when s_VOL_9 =>
				r_SM_VOL <= s_VOL_10;
				v_Segment1 := c_one;
				v_Segment2 := c_zero;
				v_LED := "1111";
				
			when s_VOL_10 =>
				r_SM_VOL <= s_VOL_10;
				v_Segment1 := c_one;
				v_Segment2 := c_zero;
				v_LED := "1111";
				
			when others =>
				null;
				
		end case;
		
	elsif (r_i_Switch_1_old2 = '1' and r_i_Switch_1_old = '0') then
	
		case r_SM_VOL is
				
			when s_VOL_0 =>
				r_SM_VOL <= s_VOL_0;
				v_Segment1 := c_zero;
				v_Segment2 := c_zero;
				v_LED := "0000";
				
			when s_VOL_1 =>
				r_SM_VOL <= s_VOL_0;
				v_Segment1 := c_zero;
				v_Segment2 := c_zero;
				v_LED := "0000";

			when s_VOL_2 =>
				r_SM_VOL <= s_VOL_1;
				v_Segment1 := c_zero;
				v_Segment2 := c_one;
				v_LED := "1000";
				
			when s_VOL_3 =>
				r_SM_VOL <= s_VOL_2;
				v_Segment1 := c_zero;
				v_Segment2 := c_two;
				v_LED := "1000";
				
			when s_VOL_4 =>
				r_SM_VOL <= s_VOL_3;
				v_Segment1 := c_zero;
				v_Segment2 := c_three;
				v_LED := "1000";
				
			when s_VOL_5 =>
				r_SM_VOL <= s_VOL_4;
				v_Segment1 := c_zero;
				v_Segment2 := c_four;
				v_LED := "1100";
				
			when s_VOL_6 =>
				r_SM_VOL <= s_VOL_5;
				v_Segment1 := c_zero;
				v_Segment2 := c_five;
				v_LED := "1100";
				
			when s_VOL_7 =>
				r_SM_VOL <= s_VOL_6;
				v_Segment1 := c_zero;
				v_Segment2 := c_six;
				v_LED := "1100";
				
			when s_VOL_8 =>
				r_SM_VOL <= s_VOL_7;
				v_Segment1 := c_zero;
				v_Segment2 := c_seven;
				v_LED := "1110";
				
			when s_VOL_9 =>
				r_SM_VOL <= s_VOL_8;
				v_Segment1 := c_zero;
				v_Segment2 := c_eight;
				v_LED := "1110";
				
			when s_VOL_10 =>
				r_SM_VOL <= s_VOL_9;
				v_Segment1 := c_zero;
				v_Segment2 := c_nine;
				v_LED := "1110";
				
			when others =>
				null;
				
		end case;
	
	end if;
	
	end if;
	
		r_Segment1 <= v_Segment1;
		r_Segment2 <= v_Segment2;
		r_LED <= v_LED;
		
	
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
			
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
			