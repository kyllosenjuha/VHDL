library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bintohex is
	port(
		i_Clk 	   : in std_logic;
		i_Switch_1 : in std_logic;
		i_Switch_2 : in std_logic;
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
end bintohex;

architecture behave of bintohex is

signal r_LED_1 : std_logic;
signal r_LED_2 : std_logic;
signal r_LED_3 : std_logic;
signal r_LED_4 : std_logic;
signal r_LEDS  : std_logic_vector(3 downto 0);

signal r_i_Switch_1_old : std_logic;
signal r_i_Switch_1_old2 : std_logic;
signal r_i_Switch_2_old : std_logic;
signal r_i_Switch_2_old2 : std_logic;
signal r_i_Switch_3_old : std_logic;
signal r_i_Switch_3_old2 : std_logic;
signal r_i_Switch_4_old : std_logic;
signal r_i_Switch_4_old2 : std_logic;

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
constant c_A 		: std_logic_vector(7 downto 0) := X"77";
constant c_B 		: std_logic_vector(7 downto 0) := X"1F";
constant c_C 		: std_logic_vector(7 downto 0) := X"4E";
constant c_D		: std_logic_vector(7 downto 0) := X"3D";
constant c_E		: std_logic_vector(7 downto 0) := X"4F";
constant c_F		: std_logic_vector(7 downto 0) := X"47";

begin

	p_SWITCHES : process(i_Clk) is
	begin
	
	if rising_edge(i_Clk) then
		r_i_Switch_1_old  <= i_Switch_1;
		r_i_Switch_1_old2 <= r_i_Switch_1_old;
		
		r_i_Switch_2_old  <= i_Switch_2;
		r_i_Switch_2_old2 <= r_i_Switch_2_old;
		
		r_i_Switch_3_old  <= i_Switch_3;
		r_i_Switch_3_old2 <= r_i_Switch_3_old;
		
		r_i_Switch_4_old  <= i_Switch_4;
		r_i_Switch_4_old2 <= r_i_Switch_4_old;
		
	end if;
	
	end process p_SWITCHES;
	
	
	p_CHANGE_SWITCHES : process(i_Clk) is
	
	begin
	
	if rising_edge(i_Clk) then
	
		if(r_i_Switch_1_old2 = '0' and r_i_Switch_1_old = '1') then
			r_LED_1 <= not r_LED_1;
		end if;
		
		if(r_i_Switch_2_old2 = '0' and r_i_Switch_2_old = '1') then
			r_LED_2 <= not r_LED_2;
		end if;
		
		if(r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
			r_LED_3 <= not r_LED_3;
		end if;
		
		if(r_i_Switch_4_old2 = '0' and r_i_Switch_4_old = '1') then
			r_LED_4 <= not r_LED_4;
		end if;
		
	end if;
	
	end process p_CHANGE_SWITCHES;
	
	
	p_CONCATE : process(i_Clk) is
	begin
	
	if rising_edge(i_Clk) then
		r_LEDS <= r_LED_1 & r_LED_2 & r_LED_3 & r_LED_4;
	end if;
	
	end process p_CONCATE;
	
	p_UPDATE_SEGMENTS : process(i_Clk) is
	
	variable v_Segment2 : std_logic_vector(7 downto 0);
	
	begin
	if rising_edge(i_Clk) then
	case r_LEDS is
		when "0000" =>
			v_Segment2 := c_zero;
		when "0001" =>
			v_Segment2 := c_one;
		when "0010" =>
			v_Segment2 := c_two;
		when "0011" =>
			v_Segment2 := c_three;
		when "0100" =>
			v_Segment2 := c_four;
		when "0101" =>
			v_Segment2 := c_five;
		when "0110" =>
			v_Segment2 := c_six;
		when "0111" =>
			v_Segment2 := c_seven;
		when "1000" =>
			v_Segment2 := c_eight;
		when "1001" =>
			v_Segment2 := c_nine;
		when "1010" =>
			v_Segment2 := c_A;
		when "1011" =>
			v_Segment2 := c_B;			
		when "1100" =>
			v_Segment2 := c_C;
		when "1101" =>
			v_Segment2 := c_D;
		when "1110" =>
			v_Segment2 := c_E;
		when "1111" =>
			v_Segment2 := c_F;		
		when others =>
			null;
	end case;
	
		r_Segment2 <= v_Segment2;
	
	end if;
	
end process p_UPDATE_SEGMENTS;
	
o_LED_1 <= r_LEDS(3);
o_LED_2 <= r_LEDS(2);
o_LED_3 <= r_LEDS(1);
o_LED_4 <= r_LEDS(0);
	
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
		
		
		
		
