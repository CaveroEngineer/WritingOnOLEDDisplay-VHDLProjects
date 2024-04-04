library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity oled_controller is
  port ( CLK         : in  std_logic;
         RST         : in  std_logic;
         DATA_OK     : in  std_logic;
         DATA        : in  std_logic_vector (7 downto 0);
         DATA_SPI_OK : out std_logic;
         DATA_SPI    : out std_logic_vector (8 downto 0);
         END_SPI     : in  std_logic;
         BUSY        : out std_logic;
         RES         : out std_logic;
         VBAT        : out std_logic;
         VDD         : out std_logic);
end oled_controller;

--       
architecture rtl of oled_controller is
  --ini
  type arr_dat is array( 0 to 12) of std_logic_vector(7 downto 0);
  constant comds : arr_dat := (x"AE", x"8D", x"14", x"D9", x"F1", x"81",
                              x"0F", x"A1", x"C8", x"DA", x"20", x"AF", x"00");
  constant N_COMD                : integer := comds'length;
  signal   cnt_cmd_var, num_cmds : unsigned(2 downto 0);
  signal   cnt_cmd_glob          : integer range 0 to N_COMD;
  type fsm1 is (idle_1, wait_sd, act_ND_ini, wait_END_TX, inc_cnts, verif);
  signal   std_1                 : fsm1;
  type fsm2 is (start_ini, VDD_ON, send_AE, wait_1ms, send_4cmd, wait_100ms,
                send_rest_cmds, end_init);
  signal   std_2                 : fsm2;
  signal   s_dat                 : std_logic;
  signal   EN, END_TIME, END_INI : std_logic;
  signal   VAL_TIME              : std_logic_vector (6 downto 0);
  constant cte_1ms                     : integer := 100;     
  signal   cnt_1ms                     : integer range 0 to cte_1ms;  
  signal   cnt_msg                     : unsigned(6 downto 0);
  signal   ce, aux_end, Q              : std_logic;
  signal   EN_reg, start               : std_logic;
  --ini
  --config_view
  signal   ADDR_cfg                    : std_logic_vector(6 downto 0);
  signal   DOUT_cfg                    : std_logic_vector(8 downto 0);
  type fsm_cfg is (idle_cfg, RD_rom_cfg, actv_ND_cfg, inc_cnt_addr_cfg, fin_cfg);
  signal   state_cfg                   : fsm_cfg;
  signal   cnt_ADDR_cfg                : unsigned(6 downto 0);
  constant end_rom_cfg                 : integer := 74;
  --config_view
  --view_data
  type fsm_vd is (idle_vd, WAIT_DATA_vd, actv_ND_vd);
  signal   state_vd                    : fsm_vd;
  --view_data
  --decoder_dat
  signal   DATA_rom                    : std_logic_vector(8 downto 0);
  signal   DATA_cmd                    : std_logic_vector(8 downto 0);
  signal   DATA_TX_reg                 : std_logic_vector(8 downto 0);
  signal   ADDR_dec                    : std_logic_vector(9 downto 0);
  signal   DOUT_dec                    : std_logic_vector(7 downto 0);
  signal   cnt_pix                     : unsigned(9 downto 0);
  type fsm_dec is (idle_dec, LD_cnt_pix_dec, RD_rom_dec, actv_ND_dec,
                   actv_ND_dec_inter,inc_cnt_pix_dec, fin_dec);
  signal   state_dec                   : fsm_dec;
  --decoder_dat
  signal   NEW_DAT_ini, NEW_DAT_config : std_logic;
  signal   NEW_DAT_view                : std_logic;
  signal   DATA_ini, DATA_config       : std_logic_vector (8 downto 0);
  signal   DATA_view, DATA_TX          : std_logic_vector (8 downto 0);
  signal   END_CONFIG                  : std_logic;
  signal   END_TX, READY               : std_logic;
  signal   END_vector                  : std_logic_vector (1 downto 0);
  signal   DATA_TX_OK                  : std_logic;
 --clear rom
   type cell_clear is array (0 to 74) of std_logic_vector(8 downto 0);
  constant memoria_clear : cell_clear    := (
    --Page0
'0'&X"20",'0'&X"00",'0'&X"22",'0'&X"00",'0'&X"03",  --configuracion
'1'&X"4C",'1'&X"41",'1'&X"42",'1'&X"2E",
'1'&X"20",'1'&X"44",'1'&X"49",'1'&X"53",
'1'&X"45",'1'&X"4E",'1'&X"4F",'1'&X"20",
'1'&X"45",'1'&X"43",'1'&X"4F",'1'&X"2E",
--Page1
'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",
'1'&X"20",'1'&X"20",'1'&X"47",'1'&X"49",
'1'&X"45",'1'&X"43",'1'&X"20",'1'&X"20",
'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",
--Page2
'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",
'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",
'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",
'1'&X"20",'1'&X"20",'1'&X"20",'1'&X"20",
--Page3
'1'&X"00",'1'&X"00",'1'&X"00",'1'&X"00",
'1'&X"00",'1'&X"00",'1'&X"00",'1'&X"00",
'1'&X"00",'1'&X"00",'1'&X"00",'1'&X"00",
'1'&X"00",'1'&X"00",'1'&X"00",'1'&X"00",

--Page3 poner cursor origen
'0'&X"22",'0'&X"03",'0'&X"03",'0'&X"21",'0'&X"00",'0'&x"FF");

--char_rom
 type cell_char is array (0 to 1023) of std_logic_vector(7 downto 0);
  constant memoria_char  : cell_char := (
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",--
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",-- 
x"00",x"00",x"00",x"5f",x"00",x"00",x"00",x"00",--!
x"00",x"00",x"03",x"00",x"03",x"00",x"00",x"00",--"
x"64",x"3c",x"26",x"64",x"3c",x"26",x"24",x"00",--#
x"26",x"49",x"49",x"7f",x"49",x"49",x"32",x"00",--$
x"42",x"25",x"12",x"08",x"24",x"52",x"21",x"00",--%
x"20",x"50",x"4e",x"55",x"22",x"58",x"28",x"00",--&
x"00",x"00",x"00",x"03",x"00",x"00",x"00",x"00",--'
x"00",x"00",x"1c",x"22",x"41",x"00",x"00",x"00",--(
x"00",x"00",x"00",x"41",x"22",x"1c",x"00",x"00",--)
x"00",x"15",x"15",x"0e",x"0e",x"15",x"15",x"00",--*
x"00",x"08",x"08",x"3e",x"08",x"08",x"00",x"00",--+
x"00",x"00",x"00",x"50",x"30",x"00",x"00",x"00",--,
x"00",x"08",x"08",x"08",x"08",x"08",x"00",x"00",---
x"00",x"00",x"00",x"40",x"00",x"00",x"00",x"00",--.
x"40",x"20",x"10",x"08",x"04",x"02",x"01",x"00",--/
x"00",x"3e",x"41",x"41",x"41",x"3e",x"00",x"00",--0
x"00",x"00",x"41",x"7f",x"40",x"00",x"00",x"00",--1
x"00",x"42",x"61",x"51",x"49",x"6e",x"00",x"00",--2
x"00",x"22",x"41",x"49",x"49",x"36",x"00",x"00",--3
x"00",x"18",x"14",x"12",x"7f",x"10",x"00",x"00",--4
x"00",x"27",x"49",x"49",x"49",x"71",x"00",x"00",--5
x"00",x"3c",x"4a",x"49",x"48",x"70",x"00",x"00",--6
x"00",x"43",x"21",x"11",x"0d",x"03",x"00",x"00",--7
x"00",x"36",x"49",x"49",x"49",x"36",x"00",x"00",--8
x"00",x"06",x"09",x"49",x"29",x"1e",x"00",x"00",--9
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",--:
x"00",x"00",x"00",x"52",x"30",x"00",x"00",x"00",--;
x"00",x"00",x"08",x"14",x"14",x"22",x"00",x"00",--<
x"00",x"14",x"14",x"14",x"14",x"14",x"14",x"00",--=
x"00",x"00",x"22",x"14",x"14",x"08",x"00",x"00",-->
x"00",x"02",x"01",x"59",x"05",x"02",x"00",x"00",--?
x"3e",x"41",x"5d",x"55",x"4d",x"51",x"2e",x"00",--@
x"40",x"7c",x"4a",x"09",x"4a",x"7c",x"40",x"00",--A
x"41",x"7f",x"49",x"49",x"49",x"49",x"36",x"00",--B
x"1c",x"22",x"41",x"41",x"41",x"41",x"22",x"00",--C
x"41",x"7f",x"41",x"41",x"41",x"22",x"1c",x"00",--D
x"41",x"7f",x"49",x"49",x"5d",x"41",x"63",x"00",--E
x"41",x"7f",x"49",x"09",x"1d",x"01",x"03",x"00",--F
x"1c",x"22",x"41",x"49",x"49",x"3a",x"08",x"00",--G
x"41",x"7f",x"08",x"08",x"08",x"7f",x"41",x"00",--H
x"00",x"41",x"41",x"7F",x"41",x"41",x"00",x"00",--I
x"30",x"40",x"41",x"41",x"3F",x"01",x"01",x"00",--J
x"41",x"7f",x"08",x"0c",x"12",x"61",x"41",x"00",--K
x"41",x"7f",x"41",x"40",x"40",x"40",x"60",x"00",--L
x"41",x"7f",x"42",x"0c",x"42",x"7f",x"41",x"00",--M
x"41",x"7f",x"42",x"0c",x"11",x"7f",x"01",x"00",--N
x"1c",x"22",x"41",x"41",x"41",x"22",x"1c",x"00",--O
x"41",x"7f",x"49",x"09",x"09",x"09",x"06",x"00",--P
x"0c",x"12",x"21",x"21",x"61",x"52",x"4c",x"00",--Q
x"41",x"7f",x"09",x"09",x"19",x"69",x"46",x"00",--R
x"66",x"49",x"49",x"49",x"49",x"49",x"33",x"00",--S
x"03",x"01",x"41",x"7f",x"41",x"01",x"03",x"00",--T
x"01",x"3f",x"41",x"40",x"41",x"3f",x"01",x"00",--U
x"01",x"0f",x"31",x"40",x"31",x"0f",x"01",x"00",--V
x"01",x"1f",x"61",x"14",x"61",x"1f",x"01",x"00",--W
x"41",x"41",x"36",x"08",x"36",x"41",x"41",x"00",--X
x"01",x"03",x"44",x"78",x"44",x"03",x"01",x"00",--Y
x"43",x"61",x"51",x"49",x"45",x"43",x"61",x"00",--Z
x"00",x"00",x"7f",x"41",x"41",x"00",x"00",x"00",--[
x"01",x"02",x"04",x"08",x"10",x"20",x"40",x"00",--\
x"00",x"00",x"41",x"41",x"7f",x"00",x"00",x"00",--]
x"00",x"04",x"02",x"01",x"01",x"02",x"04",x"00",--^
x"00",x"40",x"40",x"40",x"40",x"40",x"40",x"00",--_
x"00",x"01",x"02",x"00",x"00",x"00",x"00",x"00",--`
x"00",x"34",x"4a",x"4a",x"4a",x"3c",x"40",x"00",--a
x"00",x"41",x"3f",x"48",x"48",x"48",x"30",x"00",--b
x"00",x"3c",x"42",x"42",x"42",x"24",x"00",x"00",--c
x"00",x"30",x"48",x"48",x"49",x"3f",x"40",x"00",--d
x"00",x"3c",x"4a",x"4a",x"4a",x"2c",x"00",x"00",--e
x"00",x"00",x"48",x"7e",x"49",x"09",x"00",x"00",--f
x"00",x"26",x"49",x"49",x"49",x"3f",x"01",x"00",--g
x"41",x"7f",x"48",x"04",x"44",x"78",x"40",x"00",--h
x"00",x"00",x"44",x"7d",x"40",x"00",x"00",x"00",--i
x"00",x"00",x"40",x"44",x"3d",x"00",x"00",x"00",--j
x"41",x"7f",x"10",x"18",x"24",x"42",x"42",x"00",--k
x"00",x"40",x"41",x"7f",x"40",x"40",x"00",x"00",--l
x"42",x"7e",x"02",x"7c",x"02",x"7e",x"40",x"00",--m
x"42",x"7e",x"44",x"02",x"42",x"7c",x"40",x"00",--n
x"00",x"3c",x"42",x"42",x"42",x"3c",x"00",x"00",--o
x"00",x"41",x"7f",x"49",x"09",x"09",x"06",x"00",--p
x"00",x"06",x"09",x"09",x"49",x"7f",x"41",x"00",--q
x"00",x"42",x"7e",x"44",x"02",x"02",x"04",x"00",--r
x"00",x"64",x"4a",x"4a",x"4a",x"36",x"00",x"00",--s
x"00",x"04",x"3f",x"44",x"44",x"20",x"00",x"00",--t
x"00",x"02",x"3e",x"40",x"40",x"22",x"7e",x"40",--u
x"02",x"0e",x"32",x"40",x"32",x"0e",x"02",x"00",--v
x"02",x"1e",x"62",x"18",x"62",x"1e",x"02",x"00",--w
x"42",x"62",x"14",x"08",x"14",x"62",x"42",x"00",--x
x"01",x"43",x"45",x"38",x"05",x"03",x"01",x"00",--y
x"00",x"46",x"62",x"52",x"4a",x"46",x"62",x"00",--z
x"00",x"00",x"08",x"36",x"41",x"00",x"00",x"00",--{
x"00",x"00",x"00",x"7f",x"00",x"00",x"00",x"00",--|
x"00",x"00",x"00",x"41",x"36",x"08",x"00",x"00",--}
x"00",x"18",x"08",x"08",x"10",x"10",x"18",x"00",--~
x"AA",x"55",x"AA",x"55",x"AA",x"55",x"AA",x"55");--
  --char ROM

begin

 
--ini

-------------------------------------------------------------------------------
-- gen_timimg
-------------------------------------------------------------------------------

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      EN_reg <= '1';
      start  <= '0';
    elsif clk'event and clk = '1' then
      EN_reg <= EN;
      start  <= EN and (not EN_reg);
    end if;
  end process;

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      cnt_1ms   <= 0;
    elsif clk'event and clk = '1' then
      if (cnt_1ms = cte_1ms-1) or (start = '1') then
        cnt_1ms <= 0;
      else
        cnt_1ms <= cnt_1ms+1;
      end if;
    end if;
  end process;

  ce <= '1' when (cnt_1ms = cte_1ms-1) else '0';

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      cnt_msg   <= (others => '0');
    elsif clk'event and clk = '1' then
      if (start = '1') then
        cnt_msg <= unsigned(VAL_TIME);
      elsif (ce = '1')and (cnt_msg > 0 ) then
        cnt_msg <= cnt_msg-1;
      end if;
    end if;
  end process;

  aux_end <= '1' when cnt_msg = 0 else '0';


  process (CLK, RST)
  begin
    if RST = '1' then
      Q        <= '1';
      END_TIME <= '0';
    elsif CLK'event and CLK = '1' then
      Q        <= aux_end;
      END_TIME <= (not Q) and aux_end;
    end if;
  end process;

-------------------------------------------------------------------------------
-- gen_timimg
-------------------------------------------------------------------------------

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      cnt_cmd_glob   <= 0;
    elsif clk'event and clk = '1' then
      if std_1 = inc_cnts then
        cnt_cmd_glob <= cnt_cmd_glob+1;
      end if;
    end if;
  end process;

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      cnt_cmd_var   <= (others => '0');
    elsif clk'event and clk = '1' then
      if std_1 = idle_1 then
        cnt_cmd_var <= (others => '0');
      elsif std_1 = inc_cnts then
        cnt_cmd_var <= cnt_cmd_var+1;
      end if;
    end if;
  end process;

  DATA_ini <= '0'&comds(cnt_cmd_glob);

  process(clk, rst)
  begin
    if (rst = '1') then
      std_1       <= idle_1;
    elsif (clk'event and clk = '1') then
      case std_1 is
        when idle_1      =>
          std_1   <= wait_sd;
        when wait_sd     =>
          if (s_dat = '1') then
            std_1 <= act_ND_ini;
          end if;
        when act_ND_ini  =>
          std_1   <= wait_END_TX;
        when wait_END_TX =>
          if (END_TX = '1') then
            std_1 <= inc_cnts;
          end if;
        when inc_cnts    =>
          std_1   <= verif;
        when verif       =>
          if (cnt_cmd_var = num_cmds) then
            std_1 <= idle_1;
          else
            std_1 <= act_ND_ini;
          end if;
      end case;
    end if;
  end process;

  NEW_DAT_ini <= '1' when std_1 = act_ND_ini else '0';


  process(clk, rst)
  begin
    if (rst = '1') then
      std_2       <= start_ini;
    elsif (clk'event and clk = '1') then
      case std_2 is
        when start_ini      =>
          std_2   <= VDD_ON;
        when VDD_ON         =>
          if (END_TIME = '1') then
            std_2 <= send_AE;
          end if;
        when send_AE        =>
          if END_TX = '1' then
            std_2 <= wait_1ms;
          end if;
        when wait_1ms       =>
          if (END_TIME = '1') then
            std_2 <= send_4cmd;
          end if;
        when send_4cmd      =>
          if (std_1 = idle_1) then
            std_2 <= wait_100ms;
          end if;
        when wait_100ms     =>
          if (END_TIME = '1') then
            std_2 <= send_rest_cmds;
          end if;
        when send_rest_cmds =>
          if (std_1 = idle_1) then
            std_2 <= end_init;
          end if;
        when end_init       =>
          null;
      end case;
    end if;
  end process;
  
  s_dat   <= '1' when (std_2 = send_AE)or(std_2 = send_4cmd)or(std_2 = send_rest_cmds)else'0';
  EN      <= '1' when (std_2 = VDD_ON)or(std_2 = wait_1ms)or(std_2 = wait_100ms)else'0';
  END_INI <= '1' when std_2 = end_init else '0';

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      num_cmds     <= (others => '0');
      VAL_TIME     <= "0000001";
    elsif clk'event and clk = '1' then
      case std_2 is
        when send_AE          =>
          num_cmds <= "001";
        when send_4cmd        =>
          num_cmds <= "100";
        when wait_100ms       =>
          VAL_TIME <= "1100100";
        when send_rest_cmds   =>
          num_cmds <= "111";
        when others           =>
          null;
      end case;
    end if;
  end process;

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      RES    <= '1';
      VBAT   <= '1';
      VDD    <= '1';
    elsif clk'event and clk = '1' then
      if std_2 = VDD_ON then
        VDD  <= '0';
      end if;
      if (std_2 = wait_1ms) then
        RES  <= '0';
      elsif (std_2 = send_4cmd) then
        RES  <= '1';
      end if;
      if std_2 = wait_100ms then
        VBAT <= '0';
      end if;
    end if;
  end process;
  --ini
--config_view
 -- clear_rom
process (clk)
  begin
    if clk'event and clk = '1' then
      DOUT_cfg <= memoria_clear(to_integer(unsigned(ADDR_cfg)));
    end if;
  end process;
--

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      cnt_ADDR_cfg   <= (others => '0');
    elsif clk'event and clk = '1' then
      if state_cfg = inc_cnt_addr_cfg then
        cnt_ADDR_cfg <= cnt_ADDR_cfg+1;
      end if;
    end if;
  end process;

  ADDR_cfg    <= std_logic_vector(cnt_ADDR_cfg);
  DATA_config <= DOUT_cfg;

  process(clk, rst)
  begin
    if (rst = '1') then
      state_cfg         <= idle_cfg;
    elsif (clk'event and clk = '1') then
      case state_cfg is
        when idle_cfg         =>
          if (END_INI = '1') then
            state_cfg   <= RD_rom_cfg;
          end if;
        when RD_rom_cfg       =>
          state_cfg     <= actv_ND_cfg;
        when actv_ND_cfg      =>
          if (END_TX = '1') then
            if (cnt_ADDR_cfg = end_rom_cfg) then
              state_cfg <= fin_cfg;
            else
              state_cfg <= inc_cnt_addr_cfg;
            end if;
          end if;
        when inc_cnt_addr_cfg =>
          state_cfg     <= RD_rom_cfg;
        when fin_cfg          =>
          null;
      end case;
    end if;
  end process;

  NEW_DAT_config <= '1' when state_cfg = actv_ND_cfg else '0';
  END_CONFIG     <= '1' when state_cfg = fin_cfg     else '0';
  --config_view

  END_vector <= END_INI&END_CONFIG;
  READY      <= END_CONFIG and END_INI;

  --view_data
  

  DATA_view <= '1'&data;

  
  process(clk, rst)
  begin
    if (rst = '1') then
      state_vd         <= idle_vd;
    elsif (clk'event and clk = '1') then
      case state_vd is
        when idle_vd         =>
          if (READY = '1') then
            state_vd   <= WAIT_DATA_vd;
          end if;
        when WAIT_DATA_vd    =>
          if (DATA_OK = '1') then
            state_vd   <= actv_ND_vd;
          end if;
        when actv_ND_vd      =>
          if (END_TX = '1') then            
              state_vd <= WAIT_DATA_vd;                        
          end if;
        
      end case;
    end if;
  end process;

  NEW_DAT_view <= '1' when state_vd = actv_ND_vd else '0';

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      BUSY   <= '1';
    elsif clk'event and clk = '1' then
      if (state_vd = WAIT_DATA_vd)and (DATA_OK = '1') then
        BUSY <= '1';
      elsif (state_vd = WAIT_DATA_vd) then
        BUSY <= '0';
      end if;
    end if;
  end process;
  --view_data


  END_vector <= END_INI&END_CONFIG;

  with END_vector select
    DATA_TX <=
    DATA_ini    when "00",
    DATA_config when "10",
    DATA_view   when others;

  with END_vector select
    DATA_TX_OK <=
    NEW_DAT_ini    when "00",
    NEW_DAT_config when "10",
    NEW_DAT_view   when others;

--decoder_dat
  process (clk, rst)
  begin  -- process
    if rst = '1' then
      DATA_TX_reg   <= (others => '0');
    elsif clk'event and clk = '1' then
      if DATA_TX_OK = '1' then
        DATA_TX_reg <= DATA_TX;
      end if;
    end if;
  end process;

  DATA_cmd <= DATA_TX_reg;

  --char rom
  process (clk)
  begin
    if clk'event and clk = '1' then
      DOUT_dec <= memoria_char(to_integer(unsigned(ADDR_dec)));
    end if;
  end process;
  ---

  DATA_rom <= '1'&DOUT_dec;
  ADDR_dec <= std_logic_vector(cnt_pix);

  DATA_SPI <= DATA_rom when DATA_TX_reg(8) = '1' else DATA_cmd;

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      cnt_pix   <= (others => '0');
    elsif clk'event and clk = '1' then
      if state_dec = LD_cnt_pix_dec then
        cnt_pix <= unsigned(DATA_TX_reg(6 downto 0))&"000";
      elsif state_dec = inc_cnt_pix_dec then
        cnt_pix <= cnt_pix+1;
      end if;
    end if;
  end process;

  process(clk, rst)
  begin
    if (rst = '1') then
      state_dec           <= idle_dec;
    elsif (clk'event and clk = '1') then
      case state_dec is
        when idle_dec        =>
          if (DATA_TX_OK = '1') then
            state_dec     <= LD_cnt_pix_dec;
          end if;
        when LD_cnt_pix_dec  =>
          state_dec       <= RD_rom_dec;
        when RD_rom_dec      =>
          state_dec       <= actv_ND_dec_inter;
		when actv_ND_dec_inter     => 
		  state_dec       <= actv_ND_dec;		
        when actv_ND_dec     =>
          if (END_SPI = '1') then
            if (DATA_TX_reg(8) = '0') then
              state_dec   <= fin_dec;
            else
              if cnt_pix(2 downto 0) = 7 then
                state_dec <= fin_dec;
              else
                state_dec <= inc_cnt_pix_dec;
              end if;
            end if;
          end if;
        when inc_cnt_pix_dec =>
          state_dec       <= RD_rom_dec;
        when fin_dec         =>
          state_dec       <= idle_dec;
      end case;
    end if;
  end process;

  DATA_SPI_OK <= '1' when state_dec = actv_ND_dec_inter else '0';
  END_TX      <= '1' when state_dec = fin_dec     else '0';


end rtl;

