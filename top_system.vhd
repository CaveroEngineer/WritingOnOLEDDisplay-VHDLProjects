library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity top_system is
  port(RST : in std_logic;
       CLK : in std_logic;
       --SERIAL PORT
       RX        : in  std_logic;
        LED        : out  std_logic;
       --display
       DP          : out std_logic;
       SEG_AG      : out std_logic_vector(6 downto 0);  -- gfedcba
       AND_70      : out std_logic_vector(7 downto 0);
       --OLED     
       BUSY       : out std_logic; 
       RES       : out std_logic;
       VBAT      : out std_logic;
       VDD       : out std_logic;
       D_C       : out std_logic;
       CS        : out std_logic;
       SDIN      : out std_logic;
       SCLK      : out std_logic);
end top_system;

architecture rtl of top_system is

  
 signal DATO_RX_OK : std_logic;
  signal DATO_RX    : std_logic_vector(7 downto 0);
 

  signal DATA_SPI    : std_logic_vector (8 downto 0);
  signal END_SPI     : std_logic;
  signal DATA_SPI_OK : std_logic;
begin  --

  u_rx : entity work.receiver
    port map (
      clk        => CLK,
      rst        => RST,
      rx         => RX,
      dato_rx    => DATO_RX,
      error_recep => LED,
      DATO_RX_OK   => DATO_RX_OK);

 U_DISP: entity work.display_controller
    port map (
        RST        => RST,
        CLK        => CLK,
        DATO_RX_OK => DATO_RX_OK,
        DATO_RX    => DATO_RX,
        DP         => DP,
        SEG_AG     => SEG_AG,
        AND_70     => AND_70);
  
  U_OLED : entity work.oled_controller
    port map (
      CLK         => CLK,
      RST         => RST,
      DATA_OK     => DATO_RX_OK,
      DATA        => DATO_RX,
      DATA_SPI_OK => DATA_SPI_OK,
      DATA_SPI    => DATA_SPI,
      END_SPI     => END_SPI,
      BUSY        => BUSY,
      RES         => RES,
      VBAT        => VBAT,
      VDD         => VDD);


  U_SPI : entity work.spi_controller
    port map (
      CLK         => CLK,
      RST         => RST,
      DATA_SPI_OK => DATA_SPI_OK,
      DATA_SPI    => DATA_SPI,
      D_C         => D_C,
      CS          => CS,
      SDIN        => SDIN,
      SCLK        => SCLK,
      END_SPI     => END_SPI);

end;
