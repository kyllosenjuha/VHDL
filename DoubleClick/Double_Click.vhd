library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity double_click is
	port(
		i_Clk 	   : in std_logic;
		i_Switch_1 : in std_logic;
		i_Switch_3 : in std_logic;
		i_Switch_4 : in std_logic;

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
end double_click;

architecture behave of double_click is

signal r_LED_4 : std_logic;

signal r_i_Switch_1_old : std_logic;
signal r_i_Switch_1_old2 : std_logic;
signal r_i_Switch_3_old : std_logic;
signal r_i_Switch_3_old2 : std_logic;
signal r_i_Switch_4_old : std_logic;
signal r_i_Switch_4_old2 : std_logic;

signal r_enable_cnt : std_logic;
signal r_enable_cnt_old : std_logic;
signal r_enable_cnt_old2 : std_logic;

signal r_one_sec_cnt : integer range 0 to 25000000;
signal r_click_time : integer range 0 to 25000000;

signal r_SelectClickSpeed : integer range 0 to 9;
signal r_SelectSpeed : integer range 0 to 25000000;


constant c_1_0_sec : integer := 25000000;
constant c_0_9_sec : integer := 22500000;
constant c_0_8_sec : integer := 20000000;
constant c_0_7_sec : integer := 17500000;
constant c_0_6_sec : integer := 15000000;
constant c_0_5_sec : integer := 12500000;
constant c_0_4_sec : integer := 10000000;
constant c_0_3_sec : integer := 7500000;
constant c_0_2_sec : integer := 5000000;
constant c_0_1_sec : integer := 2500000;

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

p_SYNC_SWITCH_AND_ENABLE : process(i_Clk) is

begin
	if rising_edge(i_Clk) then
		r_i_Switch_1_old  <= i_Switch_1;
		r_i_Switch_1_old2 <= r_i_Switch_1_old;
		
		r_i_Switch_3_old  <= i_Switch_3;
		r_i_Switch_3_old2 <= r_i_Switch_3_old;
		
		r_i_Switch_4_old  <= i_Switch_4;
		r_i_Switch_4_old2 <= r_i_Switch_4_old;
		
		r_enable_cnt_old  <= r_enable_cnt;
		r_enable_cnt_old2 <= r_enable_cnt_old;
	end if;
end process p_SYNC_SWITCH_AND_ENABLE;


p_SelectClickSpeed : process (i_Clk) is
  begin
		if rising_edge(i_Clk) then
			if (r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
				if (r_SelectClickSpeed < 9) then
					r_SelectClickSpeed <= r_SelectClickSpeed + 1;
				end if;
				
			elsif (r_i_Switch_4_old2 = '0' and r_i_Switch_4_old = '1') then
				if (r_SelectClickSpeed > 0) then
					r_SelectClickSpeed <= r_SelectClickSpeed - 1;
				end if;
			end if;
		end if;
end process p_SelectClickSpeed;

p_UPDATE_SPEED : process(i_Clk) is

	begin

	if rising_edge(i_Clk) then
		case r_SelectClickSpeed is
			when 0 => 
				r_SelectSpeed <= c_1_0_sec;
			when 1 => 
				r_SelectSpeed <= c_0_9_sec;
			when 2 => 
				r_SelectSpeed <= c_0_8_sec;
			when 3 => 
				r_SelectSpeed <= c_0_7_sec;
			when 4 => 
				r_SelectSpeed <= c_0_6_sec;
			when 5 => 
				r_SelectSpeed <= c_0_5_sec;
			when 6 => 
				r_SelectSpeed <= c_0_4_sec;
			when 7 => 
				r_SelectSpeed <= c_0_3_sec;
			when 8 => 
				r_SelectSpeed <= c_0_2_sec;
			when 9 => 
				r_SelectSpeed <= c_0_1_sec;
			when others => 
				r_SelectSpeed <= c_1_0_sec;
			end case;
	end if;
	
end process p_UPDATE_SPEED;
	
p_ENABLE_COUNTER : process(i_Clk) is

begin
	if rising_edge(i_Clk) then
	
		if(r_one_sec_cnt = r_SelectSpeed) then
			r_enable_cnt <= '0';
	
		elsif(r_i_Switch_1_old2 = '0' and r_i_Switch_1_old = '1') then
	
			if(r_one_sec_cnt = 0) then
				r_enable_cnt <= '1';
			else
				r_enable_cnt <= '0';	
			end if;
		end if;
	end if;
end process p_ENABLE_COUNTER;


p_UPDATE_COUNTER : process(i_Clk) is

begin
	if rising_edge(i_Clk) then
		if(r_enable_cnt = '1') then
			if(r_one_sec_cnt < r_SelectSpeed) then
				r_one_sec_cnt <= r_one_sec_cnt + 1;
				r_click_time <= r_one_sec_cnt + 1;				
			end if;
		else
			r_one_sec_cnt <= 0;
		end if;
	end if;
	
end process p_UPDATE_COUNTER;


p_CLICK_TEST : process(i_Clk) is

begin
	if rising_edge(i_Clk) then
	
		if(r_enable_cnt_old2 = '1' and r_enable_cnt_old = '0') then
			if(r_click_time < r_SelectSpeed and r_click_time > 0) then
				r_LED_4 <= not r_LED_4;
			end if;
		end if;
	end if;

end process p_CLICK_TEST;

p_UPDATE_SEGMENTS : process (i_Clk) is

variable v_Segment2 : std_logic_vector(7 downto 0);

begin

	if rising_edge(i_Clk) then
	
	case r_SelectClickSpeed is
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

	r_Segment2 <= v_Segment2;
	
	end if;
end process p_UPDATE_SEGMENTS;

o_LED_1 <= '0';
o_LED_2 <= '0';
o_LED_3 <= '0';
o_LED_4 <= r_LED_4;
	
o_Segment1_A <= '1';
o_Segment1_B <= '1';
o_Segment1_C <= '1';
o_Segment1_D <= '1';
o_Segment1_E <= '1';
o_Segment1_F <= '1';
o_Segment1_G <= '1';

o_Segment2_A <= not r_Segment2(6);
o_Segment2_B <= not r_Segment2(5);
o_Segment2_C <= not r_Segment2(4);
o_Segment2_D <= not r_Segment2(3);
o_Segment2_E <= not r_Segment2(2);
o_Segment2_F <= not r_Segment2(1);
o_Segment2_G <= not r_Segment2(0);

end behave;
			