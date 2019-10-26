library ieee;
use ieee.std_logic_1164.all;

entity Seven_Segments is
	generic(
		g_resolution       : INTEGER := 10;   
		g_DECIMAL_DIGITS : in positive := 3
		);
	port(
		i_Clk : in std_logic;
		i_BCD : in std_logic_vector(g_DECIMAL_DIGITS*4-1 downto 0);
		i_sign : in std_logic;
		i_decimals : in std_logic_vector(g_resolution-9 downto 0);
		i_DV : in std_logic;
		
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
end Seven_Segments;

architecture behave of Seven_Segments is

signal r_select : std_logic;
signal r_sign : std_logic;
signal r_hundreds : std_logic;
signal r_Segment1 : std_logic_vector(7 downto 0);
signal r_Segment2 : std_logic_vector(7 downto 0);

signal i_Switch_3_old : std_logic;
signal i_Switch_3_old2 : std_logic;

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

p_SYNC_INT_DEC : process(i_Clk) is
begin
	if rising_edge(i_Clk) then
		i_Switch_3_old <= i_Switch_3;
		i_Switch_3_old2 <= i_Switch_3_old;
	end if;
end process p_SYNC_INT_DEC;

p_SELECT_INT_DEC : process(i_Clk) is
begin
	if rising_edge(i_Clk) then
		if (i_Switch_3_old2 = '0' and i_Switch_3_old = '1') then
			r_select <= not r_select;
		end if;
	end if;
end process p_SELECT_INT_DEC;

p_UPDATE_SEVEN_SEGMENTS : process(i_Clk) is

variable v_Segment1_INT : std_logic_vector(7 downto 0);
variable v_Segment2_INT : std_logic_vector(7 downto 0);

variable v_Segment1_DEC : std_logic_vector(7 downto 0);
variable v_Segment2_DEC : std_logic_vector(7 downto 0);

variable v_integer_zero : std_logic_vector(3 downto 0);
variable v_integer_one : std_logic_vector(3 downto 0);
variable v_decimals : std_logic_vector(1 downto 0);
variable v_hundreds : std_logic;

begin

	if rising_edge(i_Clk) then
		if i_DV = '1' then
		
		v_integer_zero := i_BCD(3 downto 0);
		v_integer_one := i_BCD(7 downto 4);
		v_decimals := i_decimals;
		v_hundreds := i_BCD(8);
		
		case v_integer_zero is
			when "0000" =>
				v_Segment2_INT := c_zero;
			when "0001" =>
				v_Segment2_INT := c_one;
			when "0010" =>
				v_Segment2_INT := c_two;
			when "0011" =>
				v_Segment2_INT := c_three;
			when "0100" =>
				v_Segment2_INT := c_four;
			when "0101" =>
				v_Segment2_INT := c_five;
			when "0110" =>
				v_Segment2_INT := c_six;
			when "0111" =>
				v_Segment2_INT := c_seven;
			when "1000" =>
				v_Segment2_INT := c_eight;
			when "1001" =>
				v_Segment2_INT := c_nine;
			when others =>
				null;
		end case;
		
		case v_integer_one is
			when "0000" =>
				v_Segment1_INT := c_zero;
			when "0001" =>
				v_Segment1_INT := c_one;
			when "0010" =>
				v_Segment1_INT := c_two;
			when "0011" =>
				v_Segment1_INT := c_three;
			when "0100" =>
				v_Segment1_INT := c_four;
			when "0101" =>
				v_Segment1_INT := c_five;
			when "0110" =>
				v_Segment1_INT := c_six;
			when "0111" =>
				v_Segment1_INT := c_seven;
			when "1000" =>
				v_Segment1_INT := c_eight;
			when "1001" =>
				v_Segment1_INT := c_nine;
			when others =>
				null;
		end case;
		
		case v_decimals is
			when "00" =>
				v_Segment1_DEC := c_zero;
				v_Segment2_DEC := c_zero;
			when "01" =>
				v_Segment1_DEC := c_two;
				v_Segment2_DEC := c_five;
			when "10" =>
				v_Segment1_DEC := c_five;
				v_Segment2_DEC := c_zero;
			when "11" =>
				v_Segment1_DEC := c_seven;
				v_Segment2_DEC := c_five;
			when others =>
				null;
		end case;
			
		if r_select = '0' then
			r_Segment1 <= v_Segment1_INT;
			r_Segment2 <= v_Segment2_INT;
		else
			r_Segment1 <= v_Segment1_DEC;
			r_Segment2 <= v_Segment2_DEC;
		end if;
		
		r_hundreds <= v_hundreds;
		r_sign <= i_sign;
		
		end if;		
			
	end if;

end process p_UPDATE_SEVEN_SEGMENTS;

o_LED_1 <= r_sign;
o_LED_2 <= r_hundreds;
o_LED_3 <= '0';
o_LED_4 <= r_select;

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

end behave;