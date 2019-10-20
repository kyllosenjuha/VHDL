library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.converters_pkg.all;
 

entity username_and_password_top_tb is
end username_and_password_top_tb;

architecture behave of username_and_password_top_tb is

    -- 25MHz clock = period 40 ns.
	constant c_CLK_PERIOD : time := 40 ns;
	
    -- Want to interface to 115200 baud UART
    -- 25000000 / 115200 = 217 Clocks Per Bit.
    constant c_CLKS_PER_BIT : integer := 217;

    -- 1/115200:
    constant c_BIT_PERIOD : time := 8680 ns;
	-------------
	
	--------------
  
    signal r_Clock     : std_logic := '0';
    signal r_RX_Serial : std_logic := '1';
	signal w_TX_Serial : std_logic;
  
	signal w_Switch_1 : std_logic := '0';
	signal w_Switch_3 : std_logic := '0';

	signal w_LED_1 : std_logic; 
	signal w_LED_4 : std_logic;
	signal w_Segment1 : std_logic_vector(7 downto 0) := (others => '0');
	signal w_Segment2 : std_logic_vector(7 downto 0) := (others => '0');

    -- Low-level byte-write
	procedure UART_WRITE_BYTE (
    i_Data_In       : in  std_logic_vector(7 downto 0);
    signal o_Serial : out std_logic) is
    begin

		-- Send Start Bit
		o_Serial <= '0';
		wait for c_BIT_PERIOD;

		-- Send Data Byte
		for ii in 0 to 7 loop
		  o_Serial <= i_Data_In(ii);
		  wait for c_BIT_PERIOD;
		end loop;  -- ii

		-- Send Stop Bit
		o_Serial <= '1';
		wait for c_BIT_PERIOD;
		
  end UART_WRITE_BYTE;

	

	component username_and_password_top is
				
		port(i_CLK 		     : in std_logic;
			 i_UART_RX       : in std_logic;
			 o_UART_TX		 : out std_logic;
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
			
	end component username_and_password_top;

	begin
	
	r_Clock <= not r_Clock after c_CLK_PERIOD/2;	
				
	Inst_top : username_and_password_top
		port map (i_CLK        => r_Clock,
				  i_UART_RX    => r_RX_Serial,
				  o_UART_TX    => w_TX_Serial,
				  i_Switch_1   => w_Switch_1,
			      i_Switch_3   => w_Switch_3,
			 
			      o_LED_1 => w_LED_1,
			      o_LED_4 => w_LED_4,
			
			      o_Segment1_A => w_Segment1(6),
			      o_Segment1_B => w_Segment1(5),
			      o_Segment1_C => w_Segment1(4),
			      o_Segment1_D => w_Segment1(3),
			      o_Segment1_E => w_Segment1(2),
			      o_Segment1_F => w_Segment1(1),
			      o_Segment1_G => w_Segment1(0),
			
			      o_Segment2_A => w_Segment2(6),
			      o_Segment2_B => w_Segment2(5),
			      o_Segment2_C => w_Segment2(4),
			      o_Segment2_D => w_Segment2(3),
			      o_Segment2_E => w_Segment2(2),
			      o_Segment2_F => w_Segment2(1),
			      o_Segment2_G => w_Segment2(0)
			);
	
	p_Send_Command : process
	begin
		wait until rising_edge(r_Clock);
		wait for 1000000 ns;
		
		UART_WRITE_BYTE(conv('K'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);		
		
		UART_WRITE_BYTE(conv('y'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);	
	
		UART_WRITE_BYTE(conv('l'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);
		
		UART_WRITE_BYTE(conv('l'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);

		UART_WRITE_BYTE(conv('o'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);
		
		UART_WRITE_BYTE(conv('n'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);
	
		UART_WRITE_BYTE(conv('e'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);		
		
		UART_WRITE_BYTE(conv('n'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);		
		
		UART_WRITE_BYTE(conv('2'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);
		
		UART_WRITE_BYTE(conv('9'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);		
	
		UART_WRITE_BYTE(conv('1'), r_RX_Serial);
		wait for 200000 ns;
		
		wait until rising_edge(r_Clock);		
		
		UART_WRITE_BYTE(conv('0'), r_RX_Serial);
		wait for 400000 ns;
		
		w_Switch_3 <= '1';
		
		wait for 200000 ns;
		
		w_Switch_3 <= '0';		
		
		wait;
	end process p_Send_Command;
	
end behave;
			
			