library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity display_controller is
  port(
       RST        : in  std_logic;
       CLK        : in  std_logic;
       DATO_RX_OK : in  std_logic;
       DATO_RX    : in  std_logic_vector(7 downto 0);
       DP         : out std_logic;
       SEG_AG     : out std_logic_vector(6 downto 0);  -- gfedcba
       AND_70     : out std_logic_vector(7 downto 0));
end display_controller;

architecture rtl of display_controller is
constant CTE_DISP : integer := (410E+5)/1000; --para simulacion
--constant CTE_ANDS : integer := (12E+5)/4; --12e-3*100e+6 (frecuencia FPGA)
constant CTE_ANDS : integer := ((12E+5)/4)/1000; --para simulacion
--constant CTE_DISP : integer := (410E+5); --T1 = Media DNI*5

--Salida Registro desplazamiento
signal REG_EXIT : std_logic_vector(31 downto 0);
-- Entradas y salidas de los preescaler
signal counter_reg_DISP : integer range 0 to CTE_DISP-1;
signal counter_reg_ANDS : integer range 0 to CTE_ANDS-1;
signal pre_out_pre_DISP : std_logic;
signal pre_out_pre_ANDS : std_logic;
-- Salidas contadores
signal cont_out_DISP: unsigned(1 downto 0); --Contador de 2 bits para selección de dupla
signal cont_out_ANDS: unsigned(2 downto 0); --Contador de 3 bits para la selección de ánodo
-- Salida MUX
signal MUX_OUT : std_logic_vector (3 downto 0);
-- Salida DEC HEX-DISPLAY
signal DEC_HEX_OUT : std_logic_vector (6 downto 0);
-- Salida Circuito Combinacional
signal LOG_COM_OUT : std_logic_vector(2 downto 0); 
signal AND70_DISPLAY : std_logic_vector (7 downto 0);
begin

 process (CLK,RST)-- REGISTRO DE DESPLAZAMIENTO ENT.SERIE(8 BITS)/SAL.PARALELO
 begin
    if rst= '1' then 
    REG_EXIT <= (others=>'0');
    elsif CLK'event and CLK= '1' then 
        if DATO_RX_OK='1' then 
        REG_EXIT <= REG_EXIT(23 downto 0)&DATO_RX;
        end if;
      end if;
    end process;
   --Preescaler CTE_DISP
     process (clk,rst)-- Contador del Preescaler CTE_DISP
       begin  
        if rst = '1' then
          counter_reg_DISP   <= 0;
        elsif clk'event and clk = '1' then
          if counter_reg_DISP = CTE_DISP-1 then
            counter_reg_DISP <= 0;
          else
            counter_reg_DISP <= counter_reg_DISP+1;
          end if;
        end if;
      end process;
   
   process (clk, rst)-- Comparador del Preescaler CTE_DISP
   begin
     if rst = '1' then
       pre_out_pre_DISP   <= '0';
     elsif clk'event and clk = '1' then
       if counter_reg_DISP = CTE_DISP-1 then
         pre_out_pre_DISP <= '1';
       else
         pre_out_pre_DISP <= '0';
       end if;
     end if;
   end process;
    --Preescaler CTE_ANDS
     process (clk,rst)-- Contador del Preescaler CTE_ANDS
     begin  
      if rst = '1' then
        counter_reg_ANDS   <= 0;
      elsif clk'event and clk = '1' then
        if counter_reg_ANDS = CTE_ANDS-1 then
          counter_reg_ANDS <= 0;
        else
          counter_reg_ANDS <= counter_reg_ANDS+1;
        end if;
      end if;
    end process;
  
    process (clk, rst)-- Comparador del Preescaler CTE_DISP
    begin  
      if rst = '1' then
        pre_out_pre_ANDS   <= '0';
      elsif clk'event and clk = '1' then
        if counter_reg_ANDS = CTE_ANDS-1 then
          pre_out_pre_ANDS <= '1';
        else
          pre_out_pre_ANDS <= '0';
        end if;
      end if;
    end process;
    --Contador de CTE_DISP
    process(clk,rst)
    begin--
      if rst='1' then
        cont_out_DISP<= (others=>'0');
      elsif CLK'event and CLK= '1' then
        if pre_out_pre_DISP = '1' then
            cont_out_DISP<= cont_out_DISP+1;
        end if; 
      end if;
    end process;    
     --Contador de CTE_ANDS
     process(clk,rst)
     begin--
       if rst='1' then
         cont_out_ANDS<= (others=>'0');
       elsif CLK'event and CLK= '1' then
         if pre_out_pre_ANDS= '1' then
             cont_out_ANDS<= cont_out_ANDS+1;
         end if; 
       end if;
     end process;    
    --Decodificador HEX to SEG
    process(MUX_OUT)
    begin
    case MUX_OUT is
            when "0000" => DEC_HEX_OUT <= "1000000"; -- '0'
            when "0001" => DEC_HEX_OUT <= "1111001"; -- '1'
            when "0010" => DEC_HEX_OUT <= "0100100"; -- '2'
            when "0011" => DEC_HEX_OUT <= "0110000"; -- '3'
            when "0100" => DEC_HEX_OUT <= "0011001"; -- '4'
            when "0101" => DEC_HEX_OUT <= "0010010"; -- '5'
            when "0110" => DEC_HEX_OUT <= "0000010"; -- '6'
            when "0111" => DEC_HEX_OUT <= "1111000"; -- '7'
            when "1000" => DEC_HEX_OUT <= "0000000"; -- '8'
            when "1001" => DEC_HEX_OUT <= "0010000"; -- '9'
            when "1010" => DEC_HEX_OUT <= "0001000"; -- 'A'
            when "1011" => DEC_HEX_OUT <= "0000011"; -- 'B'
            when "1100" => DEC_HEX_OUT <= "1000110"; -- 'C'
            when "1101" => DEC_HEX_OUT <= "0100001"; -- 'D'
            when "1110" => DEC_HEX_OUT <= "0000110"; -- 'E'
            when "1111" => DEC_HEX_OUT <= "0001110"; -- 'F'
            when others => DEC_HEX_OUT <= (others => '-'); -- Error
        end case;
        end process;
         --MUX
        process(REG_EXIT,LOG_COM_OUT)
        begin
        case LOG_COM_OUT is
           when "000"=> MUX_OUT <= REG_EXIT(3 downto 0);
           when "001"=> MUX_OUT <= REG_EXIT(7 downto 4);
           when "010"=> MUX_OUT <= REG_EXIT(11 downto 8);
           when "011"=> MUX_OUT <= REG_EXIT(15 downto 12);
           when "100"=> MUX_OUT <= REG_EXIT(19 downto 16);
           when "101"=> MUX_OUT <= REG_EXIT(23 downto 20);
           when "110"=> MUX_OUT <= REG_EXIT(27 downto 24);
           when "111"=> MUX_OUT <= REG_EXIT(31 downto 28);
           when others => MUX_OUT <= (others=>'0');
           end case; 
       end process;
  --Logica combinacional
  
   --PUERTA AND DE AMBOS CONTADORES
    process(cont_out_ANDS,cont_out_DISP)
    begin
     LOG_COM_OUT <= std_logic_vector(cont_out_DISP) & cont_out_ANDS(0);
    end process;
    
    --DECODIFICADOR PARA ACTIVACIÓN SECUENCIAL DE LOS DISPLAYS 
    process(LOG_COM_OUT)
    begin
    case LOG_COM_OUT is
            when "000"=> AND70_DISPLAY <= "11111110";
            when "001"=> AND70_DISPLAY <= "11111101";
            when "010"=> AND70_DISPLAY <= "11111011";
            when "011"=> AND70_DISPLAY <= "11110111";
            when "100"=> AND70_DISPLAY <= "11101111";
            when "101"=> AND70_DISPLAY <= "11011111";
            when "110"=> AND70_DISPLAY <= "10111111";
            when "111"=> AND70_DISPLAY <= "01111111";
            when others => AND70_DISPLAY <= (others=>'0');
        end case;
        end process;
        
        --Registro de Display
        process(clk)
        begin 
        if clk'event and clk='1' then 
        SEG_AG<= DEC_HEX_OUT;
        end if;
        end process;
        
    --Registro de Activacion
        process(clk)
        begin 
        if clk'event and clk='1' then 
        AND_70<= AND70_DISPLAY;
        case AND70_DISPLAY is
                    when "11111110"=> DP <='0';
                    when "11111011"=> DP <='0';
                    when "11101111"=> DP <='0';
                    when "10111111"=> DP <='0';
                    when others => DP <= '1';
                end case;
        end if;
        end process;
end;
