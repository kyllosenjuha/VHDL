library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity set_volume_top is
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
end set_volume_top;

architecture behave of set_volume_top is

	signal w_Switch_1_debounce : std_logic;
	signal w_Switch_3_debounce : std_logic;

	component debounce_switch is
	  port (
		i_Clk    : in  std_logic;
		i_Switch : in  std_logic;
		o_Switch : out std_logic
		);
	end component debounce_switch;
	
	component set_volume is
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
end component set_volume;


begin

Inst_switch_1 : debounce_switch
		port map(i_Clk      => i_Clk,
				 i_Switch => i_Switch_1,
				 o_Switch => w_Switch_1_debounce
				);

Inst_switch_3 : debounce_switch
		port map(i_Clk      => i_Clk,
				 i_Switch => i_Switch_3,
				 o_Switch => w_Switch_3_debounce
				);
				
Inst_set_VOL : set_volume
		port map(
		i_Clk 	   => i_Clk,
		i_Switch_1 => w_Switch_1_debounce,
		i_Switch_3 => w_Switch_3_debounce,
		
		o_LED_1 => o_LED_1,
		o_LED_2 => o_LED_2,
		o_LED_3 => o_LED_3,
		o_LED_4 => o_LED_4,
		
		o_Segment1_A => o_Segment1_A,
		o_Segment1_B => o_Segment1_B,
		o_Segment1_C => o_Segment1_C,
		o_Segment1_D => o_Segment1_D,
		o_Segment1_E => o_Segment1_E,
		o_Segment1_F => o_Segment1_F,
		o_Segment1_G => o_Segment1_G,
		
		o_Segment2_A => o_Segment2_A,
		o_Segment2_B => o_Segment2_B,
		o_Segment2_C => o_Segment2_C,
		o_Segment2_D => o_Segment2_D,
		o_Segment2_E => o_Segment2_E,
		o_Segment2_F => o_Segment2_F,
		o_Segment2_G => o_Segment2_G
				);


				
end behave;

