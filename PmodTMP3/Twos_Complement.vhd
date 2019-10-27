library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Twos_Complement is
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
end Twos_Complement;

architecture behave of Twos_Complement is



begin

p_check_number : process(i_clk) is

variable v_total_number : std_logic_vector(resolution-1 downto 0);
variable v_sign_mark : std_logic;
variable v_int_number : std_logic_vector(6 downto 0);
variable v_dec_number : std_logic_vector(resolution-9 downto 0);

begin

	if rising_edge(i_clk) then
		v_total_number := i_data_in;
		
		if v_total_number(resolution-1) = '1' then
			v_sign_mark := '1';
			v_total_number := std_logic_vector(not(signed(v_total_number)) + 1);
			v_int_number := v_total_number(resolution-2 downto resolution-8);
			v_dec_number := v_total_number(resolution-9 downto 0);
		else
			v_sign_mark := '0';
			v_int_number := v_total_number(resolution-2 downto resolution-8);
			v_dec_number := v_total_number(resolution-9 downto 0);
		end if;
		
		o_sign <= v_sign_mark;
		o_integer_number <= v_int_number;
		o_decimal_number <= v_dec_number;
	end if;
	
end process p_check_number;
	
end behave;	
	
		
