library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_device is
  port (
    D_C  : in std_logic;
    CS   : in std_logic;
    SDIN : in std_logic;
    SCLK : in std_logic);

end spi_device;

architecture sim of spi_device is
  signal reg_aux          : std_logic_vector(7 downto 0) := (others => '0');
  signal data_register    : std_logic_vector(7 downto 0) := (others => '0');
  signal command_register : std_logic_vector(7 downto 0) := (others => '0');
  signal couter_bit       : integer                      := 0;
  signal aux              : std_logic                    := '0';
  signal start            : std_logic                    := '0';
begin
  start <= '1' after 30 ns;

  process (CS, SCLK)
  begin  -- process
    if CS = '1' then
      couter_bit            <= 7;
      reg_aux               <= (others => '0');
      aux                   <= '0';
    elsif SCLK'event and SCLK = '1' then
      if couter_bit >= 0 then
        aux                 <= '1';
        reg_aux(couter_bit) <= SDIN;
        couter_bit          <= couter_bit-1;
      end if;
    end if;
  end process;

  process (couter_bit, d_c,start)
  begin  -- process
    if start = '1' then
      if couter_bit = -1 then
        if d_c = '0' then
          command_register <= reg_aux;
        else
          data_register    <= reg_aux;
        end if;
      end if;
    end if;
  end process;

end sim;

