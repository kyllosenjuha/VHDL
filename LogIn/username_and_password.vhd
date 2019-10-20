library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types_pkg.all;
use work.converters_pkg.all;

entity username_and_password is
	generic( g_username : username_array_of_8_characters;
			 g_password : password_array_of_4_characters;
			 g_LED_1_clk_count : integer
			);
	port(  	i_CLK 		 : in std_logic;
			i_ASCII_code : in std_logic_vector(7 downto 0);
			i_ASCII_DV   : in std_logic;
			i_Switch_1   : in std_logic;
			i_Switch_3   : in std_logic;
			o_LED_1      : out std_logic;
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

end username_and_password;

architecture RTL of username_and_password is

	type t_SM_Main is ( 	   s_initial,
							   s_username_1, s_username_2, s_username_3, s_username_4,
							   s_username_5, s_username_6, s_username_7, s_username_8,
							   s_password_1, s_password_2, s_password_3, s_password_4,
							   s_check, s_okay, s_fault);
							   
	type t_username_received is array (1 to 8) of std_logic_vector(7 downto 0);
	type t_password_received is array (1 to 4) of std_logic_vector(7 downto 0);						   
	type t_username_hard_coded is array (1 to 8) of std_logic_vector(7 downto 0);
	type t_password_hard_coded is array (1 to 4) of std_logic_vector(7 downto 0);
	
	signal r_SM_Main : t_SM_Main;
	signal r_Segment1 : std_logic_vector(7 downto 0) := (others => '0');
	signal r_Segment2 : std_logic_vector(7 downto 0) := (others => '0');
	signal r_username_received : t_username_received := (others => (others => '0'));
	signal r_password_received : t_password_received := (others => (others => '0'));
	signal r_username_hard_coded : t_username_hard_coded := (others => (others => '0'));
	signal r_password_hard_coded : t_password_hard_coded := (others => (others => '0'));		
	signal r_clk_LED_1_count : integer range 0 to g_LED_1_clk_count-1 := 0;
	signal r_clk_LED_1 : std_logic := '0';
	signal r_LED_1_enable : std_logic := '0';
	signal r_LED_4 : std_logic := '0';
	signal r_reset_OK : std_logic := '0';
	signal r_reset_FAULT : std_logic := '0';
	signal r_Count_SM : integer range 0 to 10000 := 0;
	signal r_RESET_LOW_SM : std_logic := '0';
begin

	g_USERNAME_FOR: for ii in 1 to 8 generate
		r_username_hard_coded(ii) <= conv(g_username(ii));
	end generate g_USERNAME_FOR;
		
	g_PASSWORD_FOR: for ii in 1 to 4 generate
		r_password_hard_coded(ii) <= conv(g_password(ii));
	end generate g_PASSWORD_FOR;
			
	p_LED_1_toggle : process (i_CLK) is
	begin
		if rising_edge(i_CLK) then
			if(r_LED_1_enable = '1') then
				if(r_clk_LED_1_count < g_LED_1_clk_count-1) then
					r_clk_LED_1_count <= r_clk_LED_1_count + 1;
					
				else
					r_clk_LED_1 <= not r_clk_LED_1; 
					r_clk_LED_1_count <= 0;
				end if;
			else
				r_clk_LED_1 <= '0';
			end if;
		end if;
	end process p_LED_1_toggle;	

	Initialize_SM : process (i_CLK) is
	
	begin
		if rising_edge(i_CLK) then
		
			if (r_Count_SM < 10000) then
				r_Count_SM <= r_count_SM + 1;
				r_RESET_LOW_SM <= '0';
			else
				r_RESET_LOW_SM <= '1';
			end if;
			
		end if;
	end process Initialize_SM;
	
	
	p_READ_username_and_password : process (i_CLK) is

	variable v_check_username : std_logic := '0';
	variable v_check_password : std_logic := '0';
	variable v_everything_OK : std_logic := '0';
	variable v_username_received : t_username_received := (others => (others => '0'));
	variable v_password_received : t_password_received := (others => (others => '0'));
	
	begin
	
	if rising_edge(i_CLK) then

	if (r_RESET_LOW_SM = '0') then
			r_SM_Main <= s_initial;
	else
		
			case r_SM_Main is
			
				when s_initial =>
				
					r_SM_Main <= s_username_1;
					
				when s_username_1 =>
						
					if (i_ASCII_DV = '1') then 
					
							v_username_received(1) := i_ASCII_code;
						
							if v_username_received(1) = X"08" then
								r_SM_Main <= s_username_1;
								r_Segment1 <= X"7E";
							else
								r_username_received(1) <= v_username_received(1);
								r_SM_Main <= s_username_2;
								r_Segment1 <= X"30";
							end if;
						else
							r_SM_Main <= s_username_1;
							r_Segment1 <= X"7E";
							r_Segment2 <= X"00";
						end if;
					
					
					
					
				when s_username_2 =>	
				
					if (i_ASCII_DV = '1') then 
					
						v_username_received(2) := i_ASCII_code;
						
							if v_username_received(2) = X"08" then
								r_SM_Main <= s_username_1;
								r_Segment1 <= X"7E";
							else
								r_username_received(2) <= v_username_received(2);
								r_SM_Main <= s_username_3;
								r_Segment1 <= X"6D";
							end if;
					else
						r_SM_Main <= s_username_2;
						r_Segment1 <= X"30";
					end if;
					
					
					
				when s_username_3 =>
				
				
					if (i_ASCII_DV = '1') then 
						
						v_username_received(3) := i_ASCII_code;
							
							if v_username_received(3) = X"08" then
								r_SM_Main <= s_username_2;
								r_Segment1 <= X"30";
							else
								r_username_received(3) <= v_username_received(3);	
								r_SM_Main <= s_username_4;
								r_Segment1 <= X"79";
							end if;
					else
						r_SM_Main <= s_username_3;
						r_Segment1 <= X"6D";
					end if;	
					
					
					
				when s_username_4 =>	
				
					if (i_ASCII_DV = '1') then 
						
						v_username_received(4) := i_ASCII_code;
							
							if v_username_received(4) = X"08" then
								r_SM_Main <= s_username_3;
								r_Segment1 <= X"6D";
							else
								r_username_received(4) <= v_username_received(4);	
								r_SM_Main <= s_username_5;
								r_Segment1 <= X"33";
							end if;
							
					else
						r_SM_Main <= s_username_4;
						r_Segment1 <= X"79";
					end if;	

					
					
				when s_username_5 =>
				
					if (i_ASCII_DV = '1') then 
						
						v_username_received(5) := i_ASCII_code;
							
							if v_username_received(5) = X"08" then
								r_SM_Main <= s_username_4;
								r_Segment1 <= X"79";
							else
								r_username_received(5) <= v_username_received(5);		
								r_SM_Main <= s_username_6;
								r_Segment1 <= X"5B";
							end if;
					else
						r_SM_Main <= s_username_5;
						r_Segment1 <= X"33";
					end if;		

					
					
				when s_username_6 =>
				
					if (i_ASCII_DV = '1') then 
						
						v_username_received(6) := i_ASCII_code;
							
							if v_username_received(6) = X"08" then
								r_SM_Main <= s_username_5;
								r_Segment1 <= X"33";
							else
								r_username_received(6) <= v_username_received(6);		
								r_SM_Main <= s_username_7;
								r_Segment1 <= X"5F";
							end if;
					else
						r_SM_Main <= s_username_6;
						r_Segment1 <= X"5B";
					end if;	
					
					
					
				when s_username_7 =>
				
					if (i_ASCII_DV = '1') then 
						
						v_username_received(7) := i_ASCII_code;
							
							if v_username_received(7) = X"08" then
								r_SM_Main <= s_username_6;
								r_Segment1 <= X"5B";
							else
								r_username_received(7) <= v_username_received(7);		
								r_SM_Main <= s_username_8;
								r_Segment1 <= X"70";
							end if;
					else
						r_SM_Main <= s_username_7;
						r_Segment1 <= X"5F";
					end if;

					
				when s_username_8 =>
				
					if (i_ASCII_DV = '1') then 
						
						v_username_received(8) := i_ASCII_code;
							
							if v_username_received(8) = X"08" then
								r_SM_Main <= s_username_7;
								r_Segment1 <= X"5F";
							else
								r_username_received(8) <= v_username_received(8);		
								r_SM_Main <= s_password_1;
								r_Segment1 <= X"7F";
								r_Segment2 <= X"7E";
							end if;
					else
						r_SM_Main <= s_username_8;
						r_Segment1 <= X"70";
					end if;
					
			

				when s_password_1 =>
					
					if (i_ASCII_DV = '1') then 
						
						v_password_received(1) := i_ASCII_code;
							
							if v_password_received(1) = X"08" then
								r_SM_Main <= s_password_1;
								r_Segment2 <= X"7E";
							else
								r_password_received(1) <= v_password_received(1);		
								r_SM_Main <= s_password_2;
								r_Segment2 <= X"30";
							end if;
					else
						r_SM_Main <= s_password_1;
						r_Segment2 <= X"7E";
					end if;			
					
				when s_password_2 =>
				
					if (i_ASCII_DV = '1') then 
						
						v_password_received(2) := i_ASCII_code;
							
							if v_password_received(2) = X"08" then
								r_SM_Main <= s_password_1;
								r_Segment2 <= X"7E";
							else
								r_password_received(2) <= v_password_received(2);		
								r_SM_Main <= s_password_3;
								r_Segment2 <= X"6D";
							end if;
					else
						r_SM_Main <= s_password_2;
						r_Segment2 <= X"30";
					end if;

				when s_password_3 =>
				
					if (i_ASCII_DV = '1') then 
						
						v_password_received(3) := i_ASCII_code;
							
							if v_password_received(3) = X"08" then
								r_SM_Main <= s_password_2;
								r_Segment2 <= X"30";
							else
								r_password_received(3) <= v_password_received(3);		
								r_SM_Main <= s_password_4;
								r_Segment2 <= X"79";
							end if;
					else
						r_SM_Main <= s_password_3;
						r_Segment2 <= X"6D";
					end if;		
					
				when s_password_4 =>
				
					if (i_ASCII_DV = '1') then 
						
						v_password_received(4) := i_ASCII_code;
							
							if v_password_received(4) = X"08" then
								r_SM_Main <= s_password_3;
								r_Segment2 <= X"6D";
							else
								r_password_received(4) <= v_password_received(4);		
								r_SM_Main <= s_check;
								r_Segment2 <= X"33";
							end if;
					else
						r_SM_Main <= s_password_4;
						r_Segment2 <= X"79";
					end if;	
				
				when s_check =>
					
					v_check_username := '1';
					
					username_for_loop : for ii in 1 to 8 loop
						if(r_username_hard_coded(ii) = r_username_received(ii)) then
							v_check_username := v_check_username and '1';
						else
							v_check_username := v_check_username and '0';
						end if;
					end loop username_for_loop;
					
					v_check_password := '1';
					
					password_for_loop : for ii in 1 to 4 loop
						if(r_password_hard_coded(ii) = r_password_received(ii)) then
							v_check_password := v_check_password and '1';
						else
							v_check_password := v_check_password and '0';
						end if;
					end loop password_for_loop;	
					
					v_everything_OK := v_check_username and v_check_password;
					
					if(v_everything_OK = '1') then
						r_SM_Main <= s_okay;
						r_LED_4 <= '1';
					else
						r_SM_Main <= s_fault;
						r_LED_1_enable <= '1';
					end if;
					
				when s_okay =>
				
					r_reset_OK <= i_Switch_3;
					
					if(r_reset_OK = '0' and i_Switch_3 = '1') then
						r_LED_4 <= '0';
						r_SM_Main <= s_username_1;
						r_Segment1 <= X"7E";
						r_Segment2 <= X"00";
						r_username_received <= (others => (others => '0'));
						r_password_received <= (others => (others => '0'));
					else
						r_SM_Main <= s_okay;
					end if;
					
				when s_fault =>
				
					r_reset_FAULT <= i_Switch_1;
				
					if(r_reset_FAULT = '0' and i_Switch_1 = '1') then
						r_LED_1_enable <= '0';
						r_SM_Main <= s_username_1;
						r_Segment1 <= X"7E";
						r_Segment2 <= X"00";
						r_username_received <= (others => (others => '0'));
						r_password_received <= (others => (others => '0'));
					else
						r_SM_Main <= s_fault;
					end if;
					
				when others =>
				
					r_SM_Main <= s_username_1;
					r_Segment1 <= X"7E";
					r_Segment2 <= X"00";
					
			end case;
			
		end if;
	
	end if;
		
	end process p_READ_username_and_password;
	
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
	
	o_LED_1 <= r_clk_LED_1;
	o_LED_4 <= r_LED_4;
	
end RTL;
