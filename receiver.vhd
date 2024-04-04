library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity receiver is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    rx          : in  std_logic;
    dato_rx     : out std_logic_vector(7 downto 0);
    error_recep : out std_logic;
    DATO_RX_OK  : out std_logic);
end receiver;

architecture rtl of receiver is
type FSM is (idle, receiving, verifying, outputing);
signal state : FSM;
constant T_SMP : integer := 109; --Valor Modificado
constant N_muestras : integer :=7; --Valor Modificado
signal REG_OUT_RX : std_logic_vector(6 downto 0); --Valor Modificado
signal REG_OUT_CEROUNO : std_logic_vector(10 downto 0);
signal cont_ceros_aux : integer range 0 to N_muestras-1;
signal cont_unos_aux : integer range 0 to N_muestras-1;
signal dato_rx_i : std_logic_vector(7 downto 0);
signal pre_out_pre_SMP : std_logic;
signal counter_reg_SMP : unsigned(6 downto 0); --Valor modificado
signal paridad_i : std_logic :='0';
signal paridad : std_logic :='0';
signal contador_tbit : unsigned(3 downto 0); --Valor modificado
signal RX_NO_NOISE : std_logic;
signal Tbit : std_logic;
signal Tbit_i : std_logic;
signal contador_final : unsigned (3 downto 0);
signal DATO_RX_OK_i : std_logic:= '0';
signal error_recep_i : std_logic:= '0';
signal estado_1 : std_logic;
signal estado_2 : std_logic;
signal estado_3 : std_logic;
signal estado_4 : std_logic;

begin  -- rtl 
--Registro Desplazamiento RX a derechas
    process(CLK,RST)
    begin
        if(RST='1')then
            REG_OUT_RX<=(others=>'0');
        elsif(CLK'event and CLK='1')then
            if(pre_out_pre_SMP='1')then
                REG_OUT_RX<= RX&REG_OUT_RX(6 downto 1); --Aqui he modificado codigo
            end if;
        end if;
    end process;
--Contar Nº0`s y 1`s
    --Cuando se alcancen las 7 muestras se calcula el numero de 0 y 1 que tenemos y eliminamos ruido
    process (REG_OUT_RX)     
          variable cont_unos : integer := 0;
          variable cont_ceros : integer := 0;
   
    begin
    cont_unos := 0;  
    cont_ceros := 0;           
    for i in 0 to 6 loop --Codigo Modificado
        if(REG_OUT_RX(i)= '1') then  
            cont_unos := cont_unos + 1;
        else 
            cont_ceros := cont_ceros + 1;
        end if;
    end loop;
    if(cont_unos>cont_ceros) then
        RX_NO_NOISE<='1';
    else 
        RX_NO_NOISE<='0';
    end if;  
    cont_ceros_aux <=cont_ceros;
    cont_unos_aux <=cont_unos;
    end process;
--Registro Desplazamiento de RX sin ruido
   process(CLK,RST)
   begin
        if(RST='1')then
        REG_OUT_CEROUNO<=(others=>'0');
        elsif(CLK'event and CLK='1')then
            if (Tbit='1') then
                REG_OUT_CEROUNO<= RX_NO_NOISE&REG_OUT_CEROUNO(10 downto 1);
            end if;
        end if;
   end process;
 --Preescaler T_SMP
       process (clk,rst,estado_1)-- Contador del Preescaler T_SMP
         begin  
          if rst = '1' then
            counter_reg_SMP <= (others=>'0');
          elsif clk'event and clk = '1' then
            if estado_1='1' then
                counter_reg_SMP <= (others=>'0');
            elsif counter_reg_SMP = "1101101" then --Cambiado codigo, cuando el contador llegue a las 110 cuentas resetea el valor a 0
                counter_reg_SMP <=(others=>'0');
            else
                counter_reg_SMP<= counter_reg_SMP+1;
            end if;
          end if;
        end process;
     
     process (clk,rst)-- Comparador del Preescaler T_SMP
     begin
       if rst = '1' then
         pre_out_pre_SMP<= '0';
       elsif clk'event and clk = '1' then
         if counter_reg_SMP = "1101101" then --Cambiado codigo, cuando el contador haya llegado a las 110 cuentas PRE_SMP='1'
           pre_out_pre_SMP <= '1';
         else
           pre_out_pre_SMP <= '0';
         end if;
       end if;
     end process;
     --Contador para generar Tbit
     process(CLK,RST,estado_1)
     begin
     if RST='1' then 
        contador_tbit <=(others=>'0');
     elsif CLK'event and CLK='1' then
        if(estado_1='1') then
            contador_tbit <=(others=>'0');
        else
            if(pre_out_pre_SMP = '1')then
                if (contador_tbit = "0110") then -- Codigo Cambiado. Cuando llegue a 7 resetea a 0
                    contador_tbit <= "0000";
                else
                    contador_tbit <= contador_tbit+1;
                end if;
            end if;
        end if;
     end if;
     end process;
     
     process(CLK,RST)
     begin
     if RST='1' then
        Tbit_i<='0';
     elsif(CLK'event and CLK='1') then
        if (contador_tbit = "0110") then --Cambiado codigo, tiene que contar hasta 7 para generar TBit
            Tbit_i<='1';
        else 
            Tbit_i<='0';
        end if;
     end if;
     end process;
     --Detector de flanco ascendente (para que Tbit dure CLK)
     Tbit<= Tbit_i and (not (contador_tbit(2)and contador_tbit(1))); --Codigo Modificado
     --Contador final (Contador que cuenta de 0 a 10)
     process(CLK,RST, Tbit)
     begin 
     if(RST='1') then
        contador_final<="0000";
     elsif Tbit='1' then
        if CLK'event and CLK='1' then
            if(contador_final="1010")then
                contador_final<="0000"; 
            else
                contador_final<=contador_final+1;
            end if;
        end if;
     end if;
     end process;
     --Verificacion de paridad
     -- Bloque combinacional para cálculo de paridad:
     process(REG_OUT_CEROUNO, estado_3)
     variable aux : std_logic;
     begin
        aux := '0';  
     if estado_3='1' then
     for i in 1 to 8 loop
        aux := aux xor REG_OUT_CEROUNO(i);
     end loop;
     -- Codigo modificado. Paridad par, si el numero de 1 es par Paridad_i='0'
     end if;
     paridad_i <= aux; 
     end process;
     --Bloque comparador
     process(paridad_i, REG_OUT_CEROUNO)
     begin
     if(paridad_i=REG_OUT_CEROUNO(9)) then --Codigo cambiado
        paridad<='0';
     else 
        paridad<='1';
     end if;
     end process;
     --Registro
     process(CLK,RST,contador_final)
     begin
     if(RST='1') then
        dato_rx_i<=(others=>'0');
     elsif(contador_final="0000")then
        if CLK'event and CLK='1' then
            dato_rx_i<=REG_OUT_CEROUNO(8 downto 1);
        end if;
     end if;
     end process;
     dato_rx<=dato_rx_i;
     --Maquina de Estados
     --SEÑALES PARA SIMULACION
     process(state, rx, paridad, contador_final)
     begin 
     case state is
     when idle =>
        estado_1<='1';
        estado_2<='0';
        estado_3<='0';
        estado_4<='0';
     when receiving =>
        estado_1<='0';
        estado_2<='1';
        estado_3<='0';
        estado_4<='0';
     when verifying =>
        estado_1<='0';
        estado_2<='0';
        estado_3<='1';
        estado_4<='0';
     when outputing =>
        estado_1<='0';
        estado_2<='0';
        estado_3<='0';
        estado_4<='1';
     end case;
     end process;
     --Parte de Sincronismo de la FSM
     process(CLK, RST)
     begin
     if RST='1' then
        state<=idle;
     elsif CLK'event and CLK='1' then  
     case state is
        when idle =>
            if(RX='0')then
                state<=receiving;
            end if;
        when receiving =>
            if(contador_final="1010" and Tbit='1') then
                state<=verifying;
        end if;
        when verifying =>
            if(paridad='1' and REG_OUT_CEROUNO(0)='0' and REG_OUT_CEROUNO(10)='1')then 
                state<=outputing;
                error_recep_i<='0';
            else 
                state<=idle;
                error_recep_i<='1';
            end if;
        when outputing =>
            state<=idle;
        end case;
    end if;
    end process;
    DATO_RX_OK_i<='1' when (estado_4='1') else '0';
    DATO_RX_OK<=DATO_RX_OK_i;
    error_recep<=error_recep_i;
end rtl;
