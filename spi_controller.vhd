library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity spi_controller is
  port ( CLK         : in  std_logic;
         RST         : in  std_logic;
         DATA_SPI_OK : in  std_logic;
         DATA_SPI    : in  std_logic_vector (8 downto 0);
         D_C         : out std_logic;
         CS          : out std_logic;
         SDIN        : out std_logic;
         SCLK        : out std_logic;
         END_SPI     : out std_logic);
end spi_controller;

architecture rtl of spi_controller is
constant N1 : integer := 10; --Codigo Modificado
type FSM_state is (S0, S1);
signal state, next_state : FSM_state;
signal counter_reg : integer range 0 to N1-1;
signal FC: std_logic;
signal REGISTRO_EXIT : std_logic_vector(7 downto 0);
signal K: unsigned(3 downto 0);
signal MUX_EXIT: std_logic;
signal CE: std_logic;
signal BUSY: std_logic;
signal Din_ext: std_logic;
signal SCLK_in: std_logic;
signal END_SPI_in:std_logic;
signal cont_out: unsigned(3 downto 0);
begin
--Registro
    process(CLK,RST)
    begin
    if RST='1' then
        REGISTRO_EXIT <= (others=>'0');
        D_C<='0';
    elsif CLK'event and CLK='1' then
        if DATA_SPI_OK='1' then
            for i in 0 to 7 loop
                REGISTRO_EXIT(i)<=DATA_SPI(i);
            end loop;
            D_C<=DATA_SPI(8);
        end if;
    end if;
    end process; 
--Contador MEX (contador Ascendente)
process(CLK, BUSY, RST)
begin
if RST='1' then
    K<=(others=>'0');
elsif CLK'event and CLK='1' then
    if BUSY='0' then 
        K<=(others=>'0');
    elsif CE='1' then
        if K="1000" then
            K<="0000";
        else 
            K<=K+1;
        end if;
    end if;
 end if;
end process;
--MUX
process(REGISTRO_EXIT, K)
begin
case K(2 downto 0) is 
    when "000"=> MUX_EXIT <= REGISTRO_EXIT(7);
    when "001"=> MUX_EXIT <= REGISTRO_EXIT(6);
    when "010"=> MUX_EXIT <= REGISTRO_EXIT(5);
    when "011"=> MUX_EXIT <= REGISTRO_EXIT(4);
    when "100"=> MUX_EXIT <= REGISTRO_EXIT(3);
    when "101"=> MUX_EXIT <= REGISTRO_EXIT(2);
    when "110"=> MUX_EXIT <= REGISTRO_EXIT(1);
    when "111"=> MUX_EXIT <= REGISTRO_EXIT(0);
    when others => MUX_EXIT <= '0';
end case; 
end process; 
--Biestable tipo D
process(CLK, RST)
begin
if RST='1' then 
    SDIN <= '0';
elsif CLK'event and CLK='1' then
    if CE='1' then
        if(K(3)='1')then
        SDIN<=REGISTRO_EXIT(0);
        else
        SDIN<=MUX_EXIT;
        end if;   
    end if;
end if;
end process;
--Preescaler
process (CLK,RST,BUSY)-- Contador del Preescaler N1
begin  
    if RST = '1' then
      counter_reg   <= 0;
    elsif CLK'event and CLK = '1' then
        if BUSY='0' then
            counter_reg <= 0;
        elsif counter_reg = N1-1 then
            counter_reg <= 0;
        else
            counter_reg <= counter_reg+1;
        end if;
    end if;
end process;
  
process (CLK, RST)-- Comparador del Preescaler N1
begin  -- process
    if RST = '1' then
        FC <= '0';
    elsif CLK'event and CLK = '1' then
      if counter_reg = N1-1 then
        FC <= '1';
      else
        FC <= '0';
      end if;
    end if;
end process;
--Biestable tipo T para la generacion de SCLK
process(CLK, RST, BUSY)
begin 
if RST='1' then 
    SCLK_in<='0';
elsif CLK'event and CLK='1' then
    if BUSY='0' then 
        SCLK_in<='1'; 
    else
        if FC='1' then
            if (std_logic(K(3)) and CE)='1' then
            SCLK_in<='1';
            else 
            SCLK_in<= not SCLK_in;
            end if;
        end if;
    end if;
    end if;
end process;
SCLK<=SCLK_in;
--Puerta AND para generar CE
CE<= SCLK_in and FC;
--Puerta NOT 
CS<= not BUSY;
--Generacion de END_SPI, parte biestable
process(CLK,RST)
begin
if RST='1' then 
    Din_ext<='0';
elsif CLK'event and CLK='1' then
    Din_ext<=K(3);
end if;
end process;
--Parte Combinacional del detector de flancos descendentes
END_SPI_IN<= not K(3) and Din_ext;
END_SPI<=END_SPI_IN;
--Generacion de Busy 
process(DATA_SPI_OK,K(3),CE, state)
begin
    case state is
        when S0 =>
        if ((DATA_SPI_OK)='1') then
            next_state <= S1;
        else
            next_state <= S0;
        end if;
        when S1 =>
        if ((K(3)and CE)='1') then
            next_state <= S0;
        else
            next_state <= S1;
        end if;
    end case;
end process;

process(clk, rst)
 begin
 if (rst = '1') then
    state <= S0;
 elsif (clk'event and clk = '1') then
    state <= next_state;
 end if;
end process;
BUSY<= '1' when (state=S1) else '0';
end rtl;