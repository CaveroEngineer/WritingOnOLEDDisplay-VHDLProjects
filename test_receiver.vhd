library ieee;
use ieee.std_logic_1164.all;


entity test_receiver is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    rx          : in  std_logic;
    led         : out std_logic_vector(7 downto 0);
    error_recep : out std_logic);

end test_receiver;

architecture rtl of test_receiver is
  signal dato_rx    : std_logic_vector(7 downto 0);
  signal DATO_RX_OK : std_logic;
begin

  DUT : entity work.receiver
    port map (
      clk         => clk,
      rst         => rst,
      rx          => rx,
      dato_rx     => dato_rx,
      error_recep => error_recep,
      DATO_RX_OK  => DATO_RX_OK);


  process (clk, rst)
  begin
    if rst = '1' then
      led   <= (others => '0');
    elsif clk'event and clk = '1' then
      if DATO_RX_OK = '1' then
        led <= dato_rx;
      end if;
    end if;
  end process;

end rtl;
