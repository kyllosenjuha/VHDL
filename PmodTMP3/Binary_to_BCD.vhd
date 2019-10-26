-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Binary_to_BCD is
  generic (
    g_resolution     : INTEGER := 10;    
    g_INPUT_WIDTH    : positive := 7;
    g_DECIMAL_DIGITS : positive := 3
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
end entity Binary_to_BCD;
 
architecture rtl of Binary_to_BCD is
 
  type t_BCD_State is (s_IDLE, s_SHIFT, s_CHECK_SHIFT_INDEX, s_ADD,
                       s_CHECK_DIGIT_INDEX, s_BCD_DONE);
  signal r_SM_Main : t_BCD_State;
  signal r_reset_COUNTER : integer range 0 to 1000;
  signal r_reset_low_SM : std_logic;
  -- The vector that contains the output BCD
  signal r_BCD : std_logic_vector(g_DECIMAL_DIGITS*4-1 downto 0) := (others => '0');
 
  -- The vector that contains the input binary value being shifted.
  signal r_Binary : std_logic_vector(g_INPUT_WIDTH-1 downto 0) := (others => '0');
  signal r_sign : std_logic;
  signal r_decimal : std_logic_vector(1 downto 0);
   
  -- Keeps track of which Decimal Digit we are indexing
  signal r_Digit_Index : natural range 0 to g_DECIMAL_DIGITS-1 := 0;
 
  -- Keeps track of which loop iteration we are on.
  -- Number of loops performed = g_INPUT_WIDTH
  signal r_Loop_Count : natural range 0 to g_INPUT_WIDTH-1  := 0;
   
begin

p_Reset_SM : process(i_Clock) is

begin

	if rising_edge(i_Clock) then
		if(r_reset_COUNTER < 1000) then
			r_reset_low_SM <= '0';
			r_reset_COUNTER <= r_reset_COUNTER + 1;
		else
			r_reset_low_SM <= '1';
		end if;
	end if;
end process p_Reset_SM;
 
  Double_Dabble : process (i_Clock)
    variable v_Upper     : natural;
    variable v_Lower     : natural;
    variable v_BCD_Digit : unsigned(3 downto 0);
	
  begin
    if rising_edge(i_Clock) then
	
	  if(r_reset_low_SM = '0') then
		r_SM_Main <= s_IDLE;
	  else
 
      case r_SM_Main is
 
        -- Stay in this state until i_Start comes along
        when s_IDLE =>
          if i_Start = '1' then
            r_BCD     <= (others => '0');
            r_Binary  <= i_Binary;
			r_sign <= i_sign;
			r_decimal <= i_decimal_part;
            r_SM_Main <= s_SHIFT;
          else
            r_SM_Main <= s_IDLE;
          end if;
 
 
        -- Always shift the BCD Vector until we have shifted all bits through
        -- Shift the most significant bit of r_Binary into r_BCD lowest bit.
        when s_SHIFT =>
          r_BCD     <= r_BCD(r_BCD'left-1 downto 0) & r_Binary(r_Binary'left);
          r_Binary  <= r_Binary(r_Binary'left-1 downto 0) & '0';
          r_SM_Main <= s_CHECK_SHIFT_INDEX;
 
 
        -- Check if we are done with shifting in r_Binary vector
        when s_CHECK_SHIFT_INDEX => 
          if r_Loop_Count = g_INPUT_WIDTH-1 then
            r_Loop_Count <= 0;
            r_SM_Main    <= s_BCD_DONE;
          else
            r_Loop_Count <= r_Loop_Count + 1;
            r_SM_Main    <= s_ADD;
          end if;
 
 
        -- Break down each BCD Digit individually.  Check them one-by-one to
        -- see if they are greater than 4.  If they are, increment by 3.
        -- Put the result back into r_BCD Vector.  Note that v_BCD_Digit is
        -- unsigned.  Numeric_std does not perform math on std_logic_vector.
        when s_ADD =>
          v_Upper     := r_Digit_Index*4 + 3;
          v_Lower     := r_Digit_Index*4;
          v_BCD_Digit := unsigned(r_BCD(v_Upper downto v_Lower));
           
          if v_BCD_Digit > 4 then
            v_BCD_Digit := v_BCD_Digit + 3;
          end if;
 
          r_BCD(v_Upper downto v_Lower) <= std_logic_vector(v_BCD_Digit);
          r_SM_Main <= s_CHECK_DIGIT_INDEX;
 
 
        -- Check if we are done incrementing all of the BCD Digits
        when s_CHECK_DIGIT_INDEX =>
          if r_Digit_Index = g_DECIMAL_DIGITS-1 then
            r_Digit_Index <= 0;
            r_SM_Main     <= s_SHIFT;
          else
            r_Digit_Index <= r_Digit_Index + 1;
            r_SM_Main     <= s_ADD;
          end if;
 
 
        when s_BCD_DONE =>
          r_SM_Main <= s_IDLE;
 
           
        when others =>
          r_SM_Main <= s_IDLE;
           
      end case;
	  end if;
    end if;                             -- rising_edge(i_Clock)
  end process Double_Dabble;
 
  o_DV  <= '1' when r_SM_Main = s_BCD_DONE else '0';
  o_BCD <= r_BCD;
  o_sign_mark <= r_sign;
  o_dec_part <= r_decimal;
   
end architecture rtl;