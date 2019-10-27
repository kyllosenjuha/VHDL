library ieee;
use ieee.std_logic_1164.all;

entity PmodTMP3_top is
	generic(
		g_resolution : INTEGER := 10;
		g_DECIMAL_DIGITS : positive := 3
		);
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
		o_Segment2_G : out std_logic;
		
		io_PMOD_3 : inout std_logic;
		io_PMOD_4 : inout std_logic
	);
end PmodTMP3_top;
	
architecture behave of PmodTMP3_top is

signal w_Switch_1_debounce : std_logic;
signal w_Switch_3_debounce : std_logic;
signal w_reset_n : std_logic;
signal w_temperature : std_logic_vector(g_resolution-1 DOWNTO 0);
signal w_sign : std_logic;
signal w_integer_number : std_logic_vector(6 downto 0);
signal w_decimal_number : std_logic_vector(1 downto 0);
signal w_BCD : std_logic_vector(g_DECIMAL_DIGITS*4-1 downto 0);
signal w_sign_to_Seg : std_logic;
signal w_dec_to_Seg : std_logic_vector(g_resolution-9 downto 0);
signal w_DV : std_logic;
signal r_COUNT : integer range 0 to 2000;


component debounce_switch is
	  port (
		i_Clk    : in  std_logic;
		i_Switch : in  std_logic;
		o_Switch : out std_logic
		);
end component debounce_switch;
	
component Twos_Complement is
	generic(
		resolution       : INTEGER := 10
		);
	port(
		i_clk 			 : in std_logic;
		i_data_in 		 : in std_logic_vector(resolution-1 DOWNTO 0);
		o_sign 			 : out std_logic;
		o_integer_number : out std_logic_vector(6 downto 0);
		o_decimal_number : out std_logic_vector(resolution-9 downto 0)
		);
end component Twos_Complement;

component Seven_Segments is
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
end component Seven_Segments;

component Binary_to_BCD is
  generic (
    g_resolution       : INTEGER := 10;    
    g_INPUT_WIDTH    : in positive := 7;
    g_DECIMAL_DIGITS : in positive := 3
    );
  port (
    i_Clock  : in std_logic;
    i_Start  : in std_logic;
    i_Binary : in std_logic_vector(g_INPUT_WIDTH-1 downto 0);
    i_sign : in std_logic;
    i_decimal_part : in std_logic_vector(g_resolution-9 downto 0);
     
    o_BCD : out std_logic_vector(g_DECIMAL_DIGITS*4-1 downto 0);
    o_sign_mark : out std_logic;
    o_dec_part : out std_logic_vector(g_resolution-9 downto 0);
    o_DV  : out std_logic
    );
end component Binary_to_BCD;

component pmod_temp_sensor_tcn75a IS
  GENERIC(
    sys_clk_freq     : INTEGER := 25_000_000;                      --input clock speed from user logic in Hz
    resolution       : INTEGER := 10;                               --desired resolution of temperature data in bits
    temp_sensor_addr : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1001000"); --I2C address of the temp sensor pmod
  PORT(
    clk         : IN    STD_LOGIC;                                 --system clock
    reset_n     : IN    STD_LOGIC;                                 --asynchronous active-low reset
    scl         : INOUT STD_LOGIC;                                 --I2C serial clock
    sda         : INOUT STD_LOGIC;                                 --I2C serial data
    i2c_ack_err : OUT   STD_LOGIC;                                 --I2C slave acknowledge error flag
    temperature : OUT   STD_LOGIC_VECTOR(resolution-1 DOWNTO 0)    --temperature value obtained
    );  
end component pmod_temp_sensor_tcn75a;

begin

	p_RESET : process(i_Clk) is
	begin
		if rising_edge(i_Clk) then
			if r_COUNT < 2000 then
				r_COUNT <= r_COUNT + 1;
				w_reset_n <= '0';
			else
				w_reset_n <= not w_Switch_1_debounce;
			end if;
		end if;
	end process p_RESET;
	

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
				
	Inst_pmod_temp_sensor : pmod_temp_sensor_tcn75a
		port map(
				clk => i_Clk,
				reset_n => w_reset_n,
				scl => io_PMOD_3,
				sda => io_PMOD_4,
				i2c_ack_err => open,
				temperature => w_temperature
				);

	Inst_Twos_Complement : Twos_Complement
		port map(
				i_clk => i_Clk,
				i_data_in => w_temperature,
				o_sign => w_sign,
				o_integer_number => w_integer_number,
				o_decimal_number => w_decimal_number
				);
				
	Inst_binary_to_BCD : Binary_to_BCD
		port map(
				i_Clock => i_Clk,
				i_Start => '1',
				i_Binary => w_integer_number,
				i_sign => w_sign,
				i_decimal_part => w_decimal_number,
     
				o_BCD => w_BCD,
				o_sign_mark => w_sign_to_Seg,
				o_dec_part => w_dec_to_Seg,
				o_DV => w_DV
				);
	
	Inst_Seven_Segments : Seven_Segments
		port map(
				i_Clk => i_Clk,
				i_BCD => w_BCD,
				i_sign => w_sign_to_Seg,
				i_decimals => w_dec_to_Seg,
				i_DV => w_DV,
				
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
