library IEEE; 
use IEEE.STD_LOGIC_1164.all; 

package CONVERTERS_pkg is 
  function CONV   (SLV8 :STD_LOGIC_VECTOR (7 downto 0)) return CHARACTER; 
  function CONV   (CHAR :CHARACTER)                     return 
STD_LOGIC_VECTOR; 
end CONVERTERS_pkg;
 
package body CONVERTERS_pkg is 
---------------------------------------------------------------------------- 
-- 
--   From STD_LOGIC_VECTOR to CHARACTER converter 
---------------------------------------------------------------------------- 
-- 
  function CONV (SLV8 :STD_LOGIC_VECTOR (7 downto 0)) return CHARACTER is 
    constant XMAP :INTEGER :=0; 
    variable TEMP :INTEGER :=0; 
  begin 
    for i in SLV8'range loop 
      TEMP:=TEMP*2; 
      case SLV8(i) is 
        when '0' | 'L'  => null; 
        when '1' | 'H'  => TEMP :=TEMP+1; 
        when others     => TEMP :=TEMP+XMAP; 
      end case; 
    end loop; 
    return CHARACTER'VAL(TEMP); 
  end CONV; 
---------------------------------------------------------------------------- 
-- 
--   From CHARACTER to STD_LOGIC_VECTOR (7 downto 0) converter 
---------------------------------------------------------------------------- 
-- 
  function CONV (CHAR :CHARACTER) return STD_LOGIC_VECTOR is 
    variable SLV8 :STD_LOGIC_VECTOR (7 downto 0); 
    variable TEMP :INTEGER :=CHARACTER'POS(CHAR); 
  begin 
    for i in SLV8'reverse_range loop 
      case TEMP mod 2 is 
        when 0 => SLV8(i):='0'; 
        when 1 => SLV8(i):='1'; 
        when others => null; 
      end case; 
      TEMP:=TEMP/2; 
    end loop; 
    return SLV8; 
  end CONV; 
end CONVERTERS_pkg; 
