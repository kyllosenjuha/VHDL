library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity one_minute_timer is
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
end one_minute_timer;

architecture behave of one_minute_timer is

signal r_one_second_counter : integer range 0 to 25000000 := 0;
signal r_counter_enable : std_logic := '0';
signal r_seconds : integer range 0 to 9 := 0;
signal r_ten_seconds : integer range 0 to 5 := 0;
signal r_LED : std_logic_vector(3 downto 0);

signal r_i_Switch_1_old : std_logic;
signal r_i_Switch_1_old2 : std_logic;
signal r_i_Switch_3_old : std_logic;
signal r_i_Switch_3_old2 : std_logic;

signal r_Segment1 : std_logic_vector(7 downto 0);
signal r_Segment2 : std_logic_vector(7 downto 0);

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


p_COUNTER_ENABLE : process (i_Clk) is

begin

	if rising_edge(i_Clk) then
	
		r_i_Switch_1_old <= i_Switch_1;
		r_i_Switch_1_old2 <= r_i_Switch_1_old;
	
		r_i_Switch_3_old <= i_Switch_3;
		r_i_Switch_3_old2 <= r_i_Switch_3_old;
		
		if (r_i_Switch_1_old2 = '0' and r_i_Switch_1_old = '1') then 		
			r_counter_enable <= not r_counter_enable;
		
		elsif (r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
			r_counter_enable <= '0';
			
		end if;
	end if;

end process p_COUNTER_ENABLE;


p_ONE_SECOND_COUNTER : process(i_Clk) is

begin

	if rising_edge(i_Clk) then
		
		if(r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
			r_one_second_counter <= 0;
			
		elsif(r_counter_enable = '1') then
		
			if(r_one_second_counter < (25000000 - 1)) then
				r_one_second_counter <= r_one_second_counter + 1;
			else
				r_one_second_counter <= 0;
			end if;
		
		end if;
	end if;
	
end process p_ONE_SECOND_COUNTER;


p_UPDATE_TIMER : process (i_Clk) is
begin

if rising_edge(i_Clk) then

	if(r_one_second_counter < 5000000) then
		r_LED <= "0000";
	elsif(r_one_second_counter < 10000000) then
		r_LED <= "1000";
	elsif(r_one_second_counter < 15000000) then
		r_LED <= "1100";
	elsif(r_one_second_counter < 20000000) then
		r_LED <= "1110";
	elsif(r_one_second_counter < 25000000) then
		r_LED <= "1111";
	end if;
		
	if(r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
		r_seconds <= 0;
		r_ten_seconds <= 0;

	elsif(r_one_second_counter = (25000000 - 1) and r_counter_enable = '1') then

	if(r_seconds < 9) then
		r_seconds <= r_seconds + 1;
		elsif(r_ten_seconds < 5) then
			r_seconds <= 0;
			r_ten_seconds <= r_ten_seconds + 1;
		else
			r_seconds <= 0;
			r_ten_seconds <= 0;
		end if;
	end if;
	
end if;
	

end process p_UPDATE_TIMER;

p_UPDATE_SEGMENTS : process (i_Clk) is

variable v_Segment1 : std_logic_vector(7 downto 0);
variable v_Segment2 : std_logic_vector(7 downto 0);

begin

	if rising_edge(i_Clk) then
	
	case r_seconds is
		when 0 =>
			v_Segment2 := c_zero;
		when 1 =>
			v_Segment2 := c_one;
		when 2 =>
			v_Segment2 := c_two;
		when 3 =>
			v_Segment2 := c_three;
		when 4 =>
			v_Segment2 := c_four;
		when 5 =>
			v_Segment2 := c_five;
		when 6 =>
			v_Segment2 := c_six;
		when 7 =>
			v_Segment2 := c_seven;
		when 8 =>
			v_Segment2 := c_eight;
		when 9 =>
			v_Segment2 := c_nine;
		when others =>
			null;
	end case;
	
	case r_ten_seconds is
		when 0 =>
			v_Segment1 := c_zero;
		when 1 =>
			v_Segment1 := c_one;
		when 2 =>
			v_Segment1 := c_two;
		when 3 =>
			v_Segment1 := c_three;
		when 4 =>
			v_Segment1 := c_four;
		when 5 =>
			v_Segment1 := c_five;
		when others =>
			null;
	end case;
	
	r_Segment1 <= v_Segment1;
	r_Segment2 <= v_Segment2;
	
	end if;
	
end process p_UPDATE_SEGMENTS;

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