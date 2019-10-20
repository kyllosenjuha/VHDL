library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjust_RGB_top is
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
		o_Segment2_G : out std_logic;
		
		o_VGA_HSync : out std_logic;
		o_VGA_VSync : out std_logic;
		o_VGA_Red_0 : out std_logic;
		o_VGA_Red_1 : out std_logic;
		o_VGA_Red_2 : out std_logic;
		o_VGA_Grn_0 : out std_logic;
		o_VGA_Grn_1 : out std_logic;
		o_VGA_Grn_2 : out std_logic;
		o_VGA_Blu_0 : out std_logic;
		o_VGA_Blu_1 : out std_logic;
		o_VGA_Blu_2 : out std_logic
		);
end adjust_RGB_top;

architecture behave of adjust_RGB_top is

	  -- VGA Constants to set Frame Size
  constant c_VIDEO_WIDTH : integer := 3;
  constant c_TOTAL_COLS  : integer := 800;
  constant c_TOTAL_ROWS  : integer := 525;
  constant c_ACTIVE_COLS : integer := 640;
  constant c_ACTIVE_ROWS : integer := 480;
   
  signal r_TP_Index        : std_logic_vector(3 downto 0) := (others => '0');
 
  -- Common VGA Signals
  signal w_HSync_VGA       : std_logic;
  signal w_VSync_VGA       : std_logic;
  signal w_HSync_Porch     : std_logic;
  signal w_VSync_Porch     : std_logic;
  signal w_Red_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 
  -- VGA Test Pattern Signals
  signal w_HSync_TP     : std_logic;
  signal w_VSync_TP     : std_logic;
  signal w_Red_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0); 



	signal w_Switch_1_debounce : std_logic;
	signal w_Switch_2_debounce : std_logic;
	signal w_Switch_3_debounce : std_logic;
    signal w_Switch_4_debounce : std_logic;

	component debounce_switch is
	  port (
		i_Clk    : in  std_logic;
		i_Switch : in  std_logic;
		o_Switch : out std_logic
		);
	end component debounce_switch;
	
	
	component Test_Pattern_Gen is
  generic (
    g_VIDEO_WIDTH : integer := 3;
    g_TOTAL_COLS  : integer := 800;
    g_TOTAL_ROWS  : integer := 525;
    g_ACTIVE_COLS : integer := 640;
    g_ACTIVE_ROWS : integer := 480
    );
  port (
    i_Clk     : in std_logic;
	
	i_Switch_1 : in std_logic;
	i_Switch_2 : in std_logic;
	i_Switch_3 : in std_logic;
	i_Switch_4 : in std_logic;
	
	o_LED_1 : out std_logic;
	o_LED_2 : out std_logic;
	o_LED_3 : out std_logic;
	o_LED_4 : out std_logic;

    i_HSync   : in std_logic;
    i_VSync   : in std_logic;
    --
    o_HSync     : out std_logic := '0';
    o_VSync     : out std_logic := '0';


    o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	
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
end component Test_Pattern_Gen;	


begin

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

Inst_switch_3 : debounce_switch
		port map(i_Clk      => i_Clk,
				 i_Switch => i_Switch_3,
				 o_Switch => w_Switch_3_debounce
				);

Inst_switch_4 : debounce_switch
		port map(i_Clk      => i_Clk,
				 i_Switch => i_Switch_4,
				 o_Switch => w_Switch_4_debounce
				);

				
Inst_adjust_RGB : Test_Pattern_Gen
		generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS
      )

		port map(
		i_Clk 	   => i_Clk,
		i_Switch_1 => w_Switch_1_debounce,
		i_Switch_2 => w_Switch_2_debounce,
		i_Switch_3 => w_Switch_3_debounce,
		i_Switch_4 => w_Switch_4_debounce,
		
		o_LED_1 => o_LED_1,
		o_LED_2 => o_LED_2,
		o_LED_3 => o_LED_3,
		o_LED_4 => o_LED_4,
		
	  i_HSync     => w_HSync_VGA,
      i_VSync     => w_VSync_VGA,
      --
      o_HSync     => w_HSync_TP,
      o_VSync     => w_VSync_TP,
      o_Red_Video => w_Red_Video_TP,
      o_Blu_Video => w_Blu_Video_TP,
      o_Grn_Video => w_Grn_Video_TP,
		
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

VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses
    generic map (
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      o_HSync     => w_HSync_VGA,
      o_VSync     => w_VSync_VGA,
      o_Col_Count => open,
      o_Row_Count => open
      );
	  
	  
  VGA_Sync_Porch_Inst : entity work.VGA_Sync_Porch
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS 
      )
    port map (
      i_Clk       => i_Clk,
      i_HSync     => w_HSync_VGA,
      i_VSync     => w_VSync_VGA,
      i_Red_Video => w_Red_Video_TP,
      i_Grn_Video => w_Blu_Video_TP,
      i_Blu_Video => w_Grn_Video_TP,
      --
      o_HSync     => w_HSync_Porch,
      o_VSync     => w_VSync_Porch,
      o_Red_Video => w_Red_Video_Porch,
      o_Grn_Video => w_Blu_Video_Porch,
      o_Blu_Video => w_Grn_Video_Porch
      );
       
  o_VGA_HSync <= w_HSync_Porch;
  o_VGA_VSync <= w_VSync_Porch;
       
  o_VGA_Red_0 <= w_Red_Video_Porch(0);
  o_VGA_Red_1 <= w_Red_Video_Porch(1);
  o_VGA_Red_2 <= w_Red_Video_Porch(2);
   
  o_VGA_Grn_0 <= w_Grn_Video_Porch(0);
  o_VGA_Grn_1 <= w_Grn_Video_Porch(1);
  o_VGA_Grn_2 <= w_Grn_Video_Porch(2);
 
  o_VGA_Blu_0 <= w_Blu_Video_Porch(0);
  o_VGA_Blu_1 <= w_Blu_Video_Porch(1);
  o_VGA_Blu_2 <= w_Blu_Video_Porch(2);


				
end behave;

