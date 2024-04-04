library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_oled is
  port ( CLK     : in  std_logic;
         RST     : in  std_logic;
         DATA_OK : in  std_logic;
         DATA    : in  std_logic_vector (7 downto 0);
         BUSY    : out std_logic;
         RES     : out std_logic;
         VBAT    : out std_logic;
         VDD     : out std_logic;
         D_C     : out std_logic;
         CS      : out std_logic;
         SDIN    : out std_logic;
         SCLK    : out std_logic);

end test_oled;

architecture rtl of test_oled is

  signal DATA_SPI    : std_logic_vector (8 downto 0);
  signal END_SPI     : std_logic;
  signal DATA_SPI_OK : std_logic;
  signal DATA_OK_reg : std_logic;
  signal load        : std_logic;
begin

  process (CLK, RST)
  begin
    if RST = '1' then
      load        <= '0';
      DATA_OK_reg <= '0';
    elsif CLK'event and CLK = '1' then
      DATA_OK_reg <= DATA_OK;
      load        <= (not DATA_OK_reg) and DATA_OK;
    end if;
  end process;

  U_OLED :entity work.oled_controller
    port map (
      CLK         => CLK,
      RST         => RST,
      DATA_OK     => LOAD,
      DATA        => DATA,
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

end rtl;

