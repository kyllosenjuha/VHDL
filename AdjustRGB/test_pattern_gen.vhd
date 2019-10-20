library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Test_Pattern_Gen is
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
end entity Test_Pattern_Gen;

architecture RTL of Test_Pattern_Gen is

  component Sync_To_Count is
    generic (
      g_TOTAL_COLS : integer;
      g_TOTAL_ROWS : integer
      );
    port (
      i_Clk   : in std_logic;
      i_HSync : in std_logic;
      i_VSync : in std_logic;

      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component Sync_To_Count;

  signal w_VSync : std_logic;
  signal w_HSync : std_logic;
  
  -- Make these unsigned counters (always positive)
  signal w_Col_Count : std_logic_vector(9 downto 0);
  signal w_Row_Count : std_logic_vector(9 downto 0);

  signal w_Bar_Width  : integer range 0 to g_ACTIVE_COLS/8;
  signal w_Bar_Select : integer range 0 to 7;  -- Color Bars
  
  signal r_i_Switch_1_old : std_logic;
  signal r_i_Switch_1_old2 : std_logic;
  signal r_i_Switch_2_old : std_logic;
  signal r_i_Switch_2_old2 : std_logic;
  signal r_i_Switch_3_old : std_logic;
  signal r_i_Switch_3_old2 : std_logic;
  signal r_i_Switch_4_old : std_logic;
  signal r_i_Switch_4_old2 : std_logic;	

  signal SelectColor : integer range 0 to 5;
  signal SelectRGB_RED : integer range 0 to 7;
  signal SelectRGB_GRN : integer range 0 to 7;
  signal SelectRGB_BLU : integer range 0 to 7;
  
  type t_Patterns is array (0 to 7) of std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  signal Red : t_Patterns;
  signal Grn : t_Patterns;
  signal Blu : t_Patterns;
  
  signal r_RED_Temp : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal r_GRN_Temp : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal r_BLU_Temp : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  signal pattern_checboard_red : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal pattern_checboard_grn : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal pattern_checboard_blu : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  signal pattern_color_bars_RED : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal pattern_color_bars_GRN : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal pattern_color_bars_BLU : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  signal pattern_BW_border_RED : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal pattern_BW_border_GRN : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal pattern_BW_border_BLU : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  
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
	constant c_Aa 		: std_logic_vector(7 downto 0) := X"77";
	constant c_Bee 		: std_logic_vector(7 downto 0) := X"1F";
	constant c_Cee 		: std_logic_vector(7 downto 0) := X"4E";
	constant c_Dee		: std_logic_vector(7 downto 0) := X"3D";
	constant c_Ee		: std_logic_vector(7 downto 0) := X"4F";
    constant c_aF		: std_logic_vector(7 downto 0) := X"47";
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
  

  p_SelectColor : process (i_Clk) is
  begin
		if rising_edge(i_Clk) then
			if (r_i_Switch_1_old2 = '0' and r_i_Switch_1_old = '1') then
				if (SelectColor < 5) then
					SelectColor <= SelectColor + 1;
				end if;
				
			elsif (r_i_Switch_2_old2 = '0' and r_i_Switch_2_old = '1') then
				if (SelectColor > 0) then
					SelectColor <= SelectColor - 1;
				end if;
			end if;
		end if;
  end process p_SelectColor;


  
  
  p_SelectAdjustColors : process (i_Clk) is
  begin
		if rising_edge(i_Clk) then
		
			if(SelectColor = 0) then
			
			if (r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
				if (SelectRGB_RED < 7) then
					SelectRGB_RED <= SelectRGB_RED + 1;
				end if;
					
				
			
				elsif(r_i_Switch_4_old2 = '0' and r_i_Switch_4_old = '1') then
					if (SelectRGB_RED > 0) then
					SelectRGB_RED <= SelectRGB_RED - 1;
					end if;
				end if;
				
			elsif(SelectColor = 1) then
			
			if (r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
				if (SelectRGB_GRN < 7) then
					SelectRGB_GRN <= SelectRGB_GRN + 1;
				end if;
					
				
			
				elsif(r_i_Switch_4_old2 = '0' and r_i_Switch_4_old = '1') then
					if (SelectRGB_GRN > 0) then
					SelectRGB_GRN <= SelectRGB_GRN - 1;
					end if;
				end if;
			
			elsif(SelectColor = 2) then

			if (r_i_Switch_3_old2 = '0' and r_i_Switch_3_old = '1') then
				if (SelectRGB_BLU < 7) then
					SelectRGB_BLU <= SelectRGB_BLU + 1;
				end if;
					
				
			
				elsif(r_i_Switch_4_old2 = '0' and r_i_Switch_4_old = '1') then
					if (SelectRGB_BLU > 0) then
					SelectRGB_BLU <= SelectRGB_BLU - 1;
					end if;
				end if;

			end if;

		end if;
  end process p_SelectAdjustColors;
  

	g_RED: for ii in 0 to 7 generate

		Red(ii) <= std_logic_vector(to_unsigned(ii, 3)) when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
									 to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
				(others => '0');
	end generate g_RED;
	
	

	g_GRN: for ii in 0 to 7 generate

		Grn(ii) <= std_logic_vector(to_unsigned(ii, 3)) when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
									 to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
				(others => '0');
	end generate g_GRN;
	
	g_BLU: for ii in 0 to 7 generate
	
		Blu(ii) <= std_logic_vector(to_unsigned(ii, 3)) when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
									 to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
				(others => '0');
	end generate g_BLU;
	
	------------------
	-- Checkboard
	------------------
	
	pattern_checboard_red <= (others => '1') when (w_Col_Count(5) = '0' xor
                                          w_Row_Count(5) = '1') else
                    (others => '0');
	
	pattern_checboard_grn <= pattern_checboard_red;
	pattern_checboard_blu <= pattern_checboard_red;
	
	------------------
	-- Color Bars
	------------------
	
	w_Bar_Width <= g_ACTIVE_COLS/8;
  
	w_Bar_Select <= 0 when unsigned(w_Col_Count) < w_Bar_Width*1 else
					1 when unsigned(w_Col_Count) < w_Bar_Width*2 else
					2 when unsigned(w_Col_Count) < w_Bar_Width*3 else
					3 when unsigned(w_Col_Count) < w_Bar_Width*4 else
					4 when unsigned(w_Col_Count) < w_Bar_Width*5 else
					5 when unsigned(w_Col_Count) < w_Bar_Width*6 else
					6 when unsigned(w_Col_Count) < w_Bar_Width*7 else
					7;

  -- Implement Truth Table above with Conditional Assignments
	pattern_color_bars_RED <= (others => '1') when (w_Bar_Select = 4 or w_Bar_Select = 5 or
                                          w_Bar_Select = 6 or w_Bar_Select = 7) else
                    (others => '0');

	pattern_color_bars_GRN <= (others => '1') when (w_Bar_Select = 2 or w_Bar_Select = 3 or
                                          w_Bar_Select = 6 or w_Bar_Select = 7) else
                    (others => '0');

	pattern_color_bars_BLU <= (others => '1') when (w_Bar_Select = 1 or w_Bar_Select = 3 or
                                          w_Bar_Select = 5 or w_Bar_Select = 7) else
                    (others => '0');
	
	----------------------------
	-- Black and White Border
	----------------------------
	
	pattern_BW_border_RED <= (others => '1') when (to_integer(unsigned(w_Row_Count)) <= 1 or
                                          to_integer(unsigned(w_Row_Count)) >= g_ACTIVE_ROWS-1-1 or
                                          to_integer(unsigned(w_Col_Count)) <= 1 or
                                          to_integer(unsigned(w_Col_Count)) >= g_ACTIVE_COLS-1-1) else
                    (others => '0');

	pattern_BW_border_GRN <= pattern_BW_border_RED;
	pattern_BW_border_BLU <= pattern_BW_border_RED;
				
	
	p_SET_PATTERNS : process (i_Clk) is
	
	variable v_RED_VIDEO : std_logic_vector(g_VIDEO_WIDTH - 1 downto 0);
	variable v_GRN_VIDEO : std_logic_vector(g_VIDEO_WIDTH - 1 downto 0);
	variable v_BLU_VIDEO : std_logic_vector(g_VIDEO_WIDTH - 1 downto 0);
	
	begin
		if rising_edge (i_Clk) then
		
			case SelectRGB_RED is
			
			when 0 =>
				v_RED_VIDEO := Red(0);
				
			when 1 =>
				v_RED_VIDEO := Red(1);
				
			when 2 =>
				v_RED_VIDEO := Red(2);

			when 3 =>
				v_RED_VIDEO := Red(3);

			when 4 =>
				v_RED_VIDEO := Red(4);

			when 5 =>
				v_RED_VIDEO := Red(5);

			when 6 =>
				v_RED_VIDEO := Red(6);

			when 7 =>
				v_RED_VIDEO := Red(7);

			when others =>
				null;
			end case;
			
		
		
			case SelectRGB_GRN is
			
			when 0 =>
				v_GRN_VIDEO := Grn(0);

			when 1 =>
				v_GRN_VIDEO := Grn(1);

			when 2 =>
				v_GRN_VIDEO := Grn(2);

			when 3 =>
				v_GRN_VIDEO := Grn(3);

			when 4 =>
				v_GRN_VIDEO := Grn(4);

			when 5 =>
				v_GRN_VIDEO := Grn(5);

			when 6 =>
				v_GRN_VIDEO := Grn(6);

			when 7 =>
				v_GRN_VIDEO := Grn(7);

			when others =>
				null;
			end case;
			

		
			case SelectRGB_BLU is
			
			when 0 =>
				v_BLU_VIDEO := Blu(0);
				
			when 1 =>
				v_BLU_VIDEO := Blu(1);
				
			when 2 =>
				v_BLU_VIDEO := Blu(2);
				
			when 3 =>
				v_BLU_VIDEO := Blu(3);
				
			when 4 =>
				v_BLU_VIDEO := Blu(4);
				
			when 5 =>
				v_BLU_VIDEO := Blu(5);
				
			when 6 =>
				v_BLU_VIDEO := Blu(6);
				
			when 7 =>
				v_BLU_VIDEO := Blu(7);
				
			when others =>
				null;
			end case;
			
			r_RED_Temp <= v_RED_VIDEO;
			r_GRN_Temp <= v_GRN_VIDEO;
			r_BLU_Temp <= v_BLU_VIDEO;
			
		end if;
	end process p_SET_PATTERNS;			
	
	p_TP_Select : process(i_Clk) is
	begin	
	if rising_edge(i_Clk) then
	
		case SelectColor is
		
			when 0 =>
				o_Red_Video <= r_RED_Temp;
				o_Grn_Video <= r_GRN_Temp;
				o_Blu_Video <= r_BLU_Temp;
				
			when 1 =>
				o_Red_Video <= r_RED_Temp;
				o_Grn_Video <= r_GRN_Temp;
				o_Blu_Video <= r_BLU_Temp;
				
			when 2 =>
				o_Red_Video <= r_RED_Temp;
				o_Grn_Video <= r_GRN_Temp;
				o_Blu_Video <= r_BLU_Temp;
	
			when 3 =>
				o_Red_Video <= pattern_checboard_red;
				o_Grn_Video <= pattern_checboard_grn;
				o_Blu_Video <= pattern_checboard_blu;
				
			when 4 =>
				o_Red_Video <= pattern_color_bars_RED;
				o_Grn_Video <= pattern_color_bars_GRN;
				o_Blu_Video <= pattern_color_bars_BLU;
				
			when 5 =>
				o_Red_Video <= pattern_BW_border_RED;
				o_Grn_Video <= pattern_BW_border_GRN;
				o_Blu_Video <= pattern_BW_border_BLU;

			when others =>
				o_Red_Video <= (others => '0');
				o_Grn_Video <= (others => '0');
				o_Blu_Video <= (others => '0');
				
		end case;
	end if;
			
	end process p_TP_Select;

	
	
p_UPDATE_SEGMENTS : process (i_Clk) is

variable v_Segment1 : std_logic_vector(7 downto 0);
variable v_Segment2_Red : std_logic_vector(7 downto 0);
variable v_Segment2_Grn : std_logic_vector(7 downto 0);
variable v_Segment2_Blu : std_logic_vector(7 downto 0);
variable v_LEDS : std_logic_vector(3 downto 0);

begin

	if rising_edge(i_Clk) then
	
	case SelectRGB_RED is
		when 0 =>
			v_Segment2_Red := c_zero;

		when 1 =>
			v_Segment2_Red := c_one;

		when 2 =>
			v_Segment2_Red := c_two;

		when 3 =>
			v_Segment2_Red := c_three;

		when 4 =>
			v_Segment2_Red := c_four;

		when 5 =>
			v_Segment2_Red := c_five;

		when 6 =>
			v_Segment2_Red := c_six;
	
		when 7 =>
			v_Segment2_Red := c_seven;

		when others =>
			null;
	end case;
	
	case SelectRGB_GRN is
		when 0 =>
			v_Segment2_Grn := c_zero;
	
		when 1 =>
			v_Segment2_Grn := c_one;
			
		when 2 =>
			v_Segment2_Grn := c_two;
		
		when 3 =>
			v_Segment2_Grn := c_three;
			
		when 4 =>
			v_Segment2_Grn := c_four;
			
		when 5 =>
			v_Segment2_Grn := c_five;
		
		when 6 =>
			v_Segment2_Grn := c_six;
		
		when 7 =>
			v_Segment2_Grn := c_seven;
			
		when others =>
			null;
	end case;
	
	case SelectRGB_BLU is
		when 0 =>
			v_Segment2_Blu := c_zero;
	
		when 1 =>
			v_Segment2_Blu := c_one;
		
		when 2 =>
			v_Segment2_Blu := c_two;
		
		when 3 =>
			v_Segment2_Blu := c_three;
			
		when 4 =>
			v_Segment2_Blu := c_four;
			
		when 5 =>
			v_Segment2_Blu := c_five;
		
		when 6 =>
			v_Segment2_Blu := c_six;
		
		when 7 =>
			v_Segment2_Blu := c_seven;
			
		when others =>
			null;
	end case;
	
	case SelectColor is
		when 0 =>
			v_Segment1 := c_Aa;
			v_LEDS := "1000";
		when 1 =>
			v_Segment1 := c_Bee;
			v_LEDS := "0100";
		when 2 =>
			v_Segment1 := c_Cee;
			v_LEDS := "0010";
		when 3 =>
			v_Segment1 := c_Dee;
			v_LEDS := "0001";
		when 4 => 
			v_Segment1 := c_Ee;
			v_LEDS := "1100";
		when 5 =>
			v_Segment1 := c_aF;
			v_LEDS := "0011";
		when others =>
			null;
	end case;
		
	o_LED_1 <= v_LEDS(3);
	o_LED_2 <= v_LEDS(2);
	o_LED_3 <= v_LEDS(1);
	o_LED_4 <= v_LEDS(0);
	
	r_Segment1 <= v_Segment1;

	if (SelectColor = 0) then
		r_Segment2 <= v_Segment2_Red;
		
		elsif(SelectColor = 1) then
			r_Segment2 <= v_Segment2_Grn;
			
			elsif(SelectColor = 2) then
				r_Segment2 <= v_Segment2_Blu;	
				
				else
					r_Segment2 <= X"00";
				end if;
					
		end if;
	
end process p_UPDATE_SEGMENTS;
		
  

  Sync_To_Count_inst : Sync_To_Count
    generic map (
      g_TOTAL_COLS => g_TOTAL_COLS,
      g_TOTAL_ROWS => g_TOTAL_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      i_HSync     => i_HSync,
      i_VSync     => i_VSync,
      o_HSync     => w_HSync,
      o_VSync     => w_VSync,
      o_Col_Count => w_Col_Count,
      o_Row_Count => w_Row_Count
      );

  
  -- Register syncs to align with output data.
  p_Reg_Syncs : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      o_VSync <= w_VSync;
      o_HSync <= w_HSync;
    end if;
  end process p_Reg_Syncs; 


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

  
end architecture RTL;
