-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity receiver_tb is

end receiver_tb;

-------------------------------------------------------------------------------

architecture sim of receiver_tb is


  signal clk_i        : std_logic := '0';
  signal rst_i        : std_logic := '1';
  signal rx_i         : std_logic;
  signal dato_rx_i    : std_logic_vector(7 downto 0);
  signal error_recep_i : std_logic;

  signal DATO_RX_OK_i   : std_logic;

begin  -- sim

  DUT : entity work.receiver
    port map (
      clk        => clk_i,
      rst        => rst_i,
      rx         => rx_i,
      dato_rx    => dato_rx_i,
      error_recep => error_recep_i,   
      DATO_RX_OK   => DATO_RX_OK_i);

  u_tx : entity work.pc_tx
    port map (
      rx => rx_i);

  -- estímulos para CLK y RST
    RST_i<='0' after 100ns;
    CLK_i<= not CLK_i after 5ns;
  --


end sim;

-------------------------------------------------------------------------------
