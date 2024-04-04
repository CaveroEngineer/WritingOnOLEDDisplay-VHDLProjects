library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity test_display is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           SW_OK : in STD_LOGIC;
           SW : in STD_LOGIC_VECTOR (7 downto 0);
           SEG_AG : out STD_LOGIC_VECTOR (6 downto 0);
           AND_70 : out STD_LOGIC_VECTOR (7 downto 0);
           DP : out STD_LOGIC);
end test_display;

architecture Behavioral of test_display is
signal SW_OK_REG,LOAD : std_logic;

begin
 process (CLK, RST)
  begin
    if RST = '1' then
      LOAD        <= '0';
      SW_OK_REG <= '0';
    elsif CLK'event and CLK = '1' then
      SW_OK_REG <= SW_OK;
      LOAD        <= (not SW_OK_REG) and SW_OK;
    end if;
 end process;

U_DISPLAY : entity work.display_controller
    port map (
        RST             => RST,
        CLK             => CLK,
        DATO_RX_OK      => LOAD,
        DATO_RX         => SW,
        DP              => DP,
        SEG_AG          => SEG_AG,
        AND_70          => AND_70);
        
end Behavioral;
