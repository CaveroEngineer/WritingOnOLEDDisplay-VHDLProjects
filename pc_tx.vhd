library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_tx is
  port (
    Rx : out std_logic);
end pc_tx;

architecture rtl of pc_tx is
  constant Velocidad_tx : integer := 130200; --Valor modificado. Los baudios son diferentes a los que teniamos en el apartado 3
  signal   trama_tx     : std_logic_vector(10 downto 0);
  signal   dato_tx      : std_logic_vector(7 downto 0);
  signal   bit_tx       : integer := 0;
begin  -- rtl



  process (dato_tx)
    variable aux_par : std_logic;
  begin

    trama_tx             <= (0 => '0', others => '1');
    trama_tx(8 downto 1) <= dato_tx;
    aux_par     := '0';
    for i in dato_tx'range loop
      if dato_tx(i) = '1' then
        aux_par := not aux_par;
      end if;
    end loop;  -- i           
    trama_tx(9)          <= not aux_par;
  end process;

  process
    procedure tx_data is
      constant T_tx_aux : time:= 1 sec/ Velocidad_tx;
    begin      
      wait for 1 us;
      for j in 0 to 10 loop
        Rx     <= trama_tx(j);
        bit_tx <= j;
        wait for T_tx_aux;
      end loop;  -- j     
      wait for 10 us;
    end tx_data;

  begin

    dato_tx <= x"31";
    Rx      <= '1';
    --wait for 1.5 ms; -- sólo para simular el top_system
    wait for 1 us;   --sólo para simular el  receiver
    tx_data;

    dato_tx <= x"40";-- completar
    wait for 10 ns;
    tx_data;
    dato_tx <= x"57";-- completar
    wait for 10 ns;
    tx_data;
    dato_tx <= x"AC";-- completar
    wait for 10 ns;
    tx_data;
    ------------------------------------------------
--repetir varias veces las tres últimas líneas

------------------------------------------------

    report "FIN CONTROLADO DE LA SIMULACION" severity failure;
  end process;

end rtl;
