library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity display is
  port(
    SEG_AG : in std_logic_vector(6 downto 0);  -- gfedcba
    AND_70 : in std_logic_vector(7 downto 0));
end display;

architecture rtl of display is

  signal Data     : character;
  signal Displays : string(8 downto 1) := "  ----  ";

begin  -- 

  process (SEG_AG) is
  begin
    case SEG_AG is
      when "1000000" => Data <= '0';
      when "1111001" => Data <= '1';
      when "0100100" => Data <= '2';
      when "0110000" => Data <= '3';
      when "0011001" => Data <= '4';
      when "0010010" => Data <= '5';
      when "0000010" => Data <= '6';
      when "1111000" => Data <= '7';
      when "0000000" => Data <= '8';
      when "0011000" => Data <= '9';    
      when "0001000" => Data <= 'A';
      when "0000011" => Data <= 'B';
      when "1000110" => Data <= 'C';
      when "0100001" => Data <= 'D';
      when "0000110" => Data <= 'E';
      when "0001110" => Data <= 'F';
      when others    => Data <= 'x';
    end case;
  end process;

  process (AND_70, Data) is
  begin
 Displays<= "--------";
    case AND_70 is   
      when "11111110" =>
        Displays(1) <= Data;
      when "11111101" =>
        Displays(2) <= Data;
      when "11111011" =>
        Displays(3) <= Data;
      when "11110111" =>
        Displays(4) <= Data;
      when "11101111" =>
        Displays(5) <= Data;
      when "11011111" =>
        Displays(6) <= Data;
      when "10111111" =>
        Displays(7) <= Data;
      when "01111111" =>
        Displays(8) <= Data;
      when others     => null;
    end case;
  end process;

end;
