library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types_pkg.all; 

entity username_and_password_top is
  port (
    i_Clk        : in  std_logic;
	i_UART_RX    : in std_logic;
	o_UART_TX    : out std_logic;
    i_Switch_1   : in std_logic;
	i_Switch_3   : in std_logic;
	
	o_LED_1      : out std_logic;
	o_LED_2      : out std_logic;
	o_LED_3      : out std_logic;
	o_LED_4      : out std_logic;
	
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
	o_Segment2_G : out std_logic);

end username_and_password_top;

architecture behave of username_and_password_top is

	constant c_CLKS_PER_BIT : integer := 217;
	constant c_username : username_array_of_8_characters := ('K', 'y', 'l', 'l', 'o', 'n', 'e', 'n');
	constant c_password : password_array_of_4_characters := ('2', '9', '1', '0');
	constant c_LED_1_clk_count : integer := 6250000; -- for synthesis 6250000, for simulation 500;

    signal w_RXTX_Byte : std_logic_vector(7 downto 0);
    signal r_RX_Serial : std_logic := '1';

	signal w_RXTX_DV : std_logic := '0';
	signal w_Switch_1_debounce : std_logic;
	signal w_Switch_3_debounce : std_logic;
	
	signal w_TX_Active : std_logic;
	signal w_TX_Serial : std_logic;

	component debounce_switch is
	  port (
		i_Clk    : in  std_logic;
		i_Switch : in  std_logic;
		o_Switch : out std_logic
		);
	end component debounce_switch;

	component UART_TX is
		generic (
			g_CLKS_PER_BIT : integer     -- Needs to be set correctly
		);
		port (
			i_Clk       : in  std_logic;
			i_TX_DV     : in  std_logic;
			i_TX_Byte   : in  std_logic_vector(7 downto 0);
			o_TX_Active : out std_logic;
			o_TX_Serial : out std_logic;
			o_TX_Done   : out std_logic
		);
	end component UART_TX;

	component UART_RX is
		generic (
			g_CLKS_PER_BIT : integer     -- Needs to be set correctly
				);
		port (
			i_Clk       : in  std_logic;
			i_RX_Serial : in  std_logic;
			o_RX_DV     : out std_logic;
			o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
	end component UART_RX;

	component username_and_password is
		generic(g_username   : username_array_of_8_characters;
			    g_password   : password_array_of_4_characters;
				g_LED_1_clk_count : integer
				);	
		port(i_CLK 		     : in std_logic;
		     i_ASCII_code    : in std_logic_vector(7 downto 0);
			 i_ASCII_DV      : in std_logic;
			 i_Switch_1      : in std_logic;
			 i_Switch_3      : in std_logic;
			 
			 o_LED_1         : out std_logic;
			 o_LED_4         : out std_logic;
			
			 o_Segment1_A    : out std_logic;
			 o_Segment1_B    : out std_logic;
			 o_Segment1_C    : out std_logic;
			 o_Segment1_D    : out std_logic;
			 o_Segment1_E    : out std_logic;
			 o_Segment1_F    : out std_logic;
			 o_Segment1_G    : out std_logic;
			
			 o_Segment2_A    : out std_logic;
			 o_Segment2_B    : out std_logic;
			 o_Segment2_C    : out std_logic;
			 o_Segment2_D    : out std_logic;
			 o_Segment2_E    : out std_logic;
			 o_Segment2_F    : out std_logic;
			 o_Segment2_G    : out std_logic);
			
	end component username_and_password;

	begin
	
	o_LED_2 <= '0';
	o_LED_3 <= '0';
	
	r_RX_Serial <= i_UART_RX;
	o_UART_TX <= w_TX_Serial when w_TX_Active = '1' else '1';
	
	Inst_UART_TX : UART_TX
		generic map (
			g_CLKS_PER_BIT => c_CLKS_PER_BIT
			)
		port map (
			i_Clk       => i_Clk,
			i_TX_DV     => w_RXTX_DV,
			i_TX_Byte   => w_RXTX_Byte,
			o_TX_Active => w_TX_Active,
			o_TX_Serial => w_TX_Serial,
			o_TX_Done   => open 
		);
		
	Inst_UART_RX : uart_rx
		generic map (g_CLKS_PER_BIT => c_CLKS_PER_BIT
				)
		port map(i_Clk => i_Clk,
				 i_RX_Serial => r_RX_Serial,
				 o_RX_DV => w_RXTX_DV,
				 o_RX_Byte => w_RXTX_Byte
				 );

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
				
	Inst_userpw : username_and_password
		generic map (g_username => c_username,
					 g_password => c_password,
					 g_LED_1_clk_count => c_LED_1_clk_count
			)
		port map (i_CLK        => i_Clk,
		          i_ASCII_code => w_RXTX_Byte,
				  i_ASCII_DV   => w_RXTX_DV,
				  i_Switch_1   => w_Switch_1_debounce,
			      i_Switch_3   => w_Switch_3_debounce,
			 
			      o_LED_1 => o_LED_1,
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
			
			