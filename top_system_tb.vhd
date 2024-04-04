-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity top_system_tb is

end top_system_tb;

-------------------------------------------------------------------------------

architecture SIM of top_system_tb is


  signal RST_i    : std_logic := '1';
  signal CLK_i    : std_logic := '0';
  signal RX_i     : std_logic;
  signal LED_i    : std_logic;
  signal DP_i     : std_logic;
  signal SEG_AG_i : std_logic_vector(6 downto 0);
  signal AND_70_i : std_logic_vector(7 downto 0);
  signal BUSY_i   : std_logic;
  signal RES_i    : std_logic;
  signal VBAT_i   : std_logic;
  signal VDD_i    : std_logic;
  signal D_C_i    : std_logic;
  signal CS_i     : std_logic;
  signal SDIN_i   : std_logic;
  signal SCLK_i   : std_logic;

begin  -- SIM

  DUT : entity work.top_system
    port map (
      RST    => RST_i,
      CLK    => CLK_i,
      RX     => RX_i,
      LED    => LED_i,
      DP     => DP_i,
      SEG_AG => SEG_AG_i,
      AND_70 => AND_70_i,
      BUSY   => BUSY_i,
      RES    => RES_i,
      VBAT   => VBAT_i,
      VDD    => VDD_i,
      D_C    => D_C_i,
      CS     => CS_i,
      SDIN   => SDIN_i,
      SCLK   => SCLK_i);



  U_SPI_DEV : entity work.spi_device
    port map (
      D_C  => D_C_i,
      CS   => CS_i,
      SDIN => SDIN_i,
      SCLK => SCLK_i);

  u_PC_tx : entity work.pc_tx
    port map (
      rx => rx_i);
      

  U_Display : entity work.display
    port map (  
      SEG_AG => SEG_AG_i,
      AND_70 => AND_70_i);
  
  clk_i <= not clk_i after 5 ns;
  rst_i <= '0'       after 137 ns;


end SIM;

-------------------------------------------------------------------------------
