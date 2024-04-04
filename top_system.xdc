# CLK 
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK }]; 
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK}];

	
	
	
#RST
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { RST }];	

# leds
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { LED }];

#led BUSY
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { BUSY }];

	
##USB-RS232 Interface
set_property -dict { PACKAGE_PIN C4   IOSTANDARD LVCMOS33 } [get_ports { RX }]; 
		
	
# OLED (JA)

set_property -dict { PACKAGE_PIN C17    IOSTANDARD LVCMOS33 } [get_ports { CS }]; #JA1
set_property -dict { PACKAGE_PIN D18    IOSTANDARD LVCMOS33 } [get_ports { SDIN }]; #JA2
set_property -dict { PACKAGE_PIN G17    IOSTANDARD LVCMOS33 } [get_ports { SCLK }]; #JA4
set_property -dict { PACKAGE_PIN D17    IOSTANDARD LVCMOS33 } [get_ports { D_C }]; #JA7
set_property -dict { PACKAGE_PIN E17    IOSTANDARD LVCMOS33 } [get_ports { RES }]; #JA8
set_property -dict { PACKAGE_PIN F18    IOSTANDARD LVCMOS33 } [get_ports { VBAT }]; #JA9
set_property -dict { PACKAGE_PIN G18    IOSTANDARD LVCMOS33 } [get_ports { VDD }]; #JA10


##7 segment display
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { SEG_AG[0] }];	
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { SEG_AG[1] }];	
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { SEG_AG[2] }];	
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { SEG_AG[3] }];	
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { SEG_AG[4] }];	
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { SEG_AG[5] }];	
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { SEG_AG[6] }];	

set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { AND_70[0] }];	
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { AND_70[1] }];	
set_property -dict { PACKAGE_PIN T9   IOSTANDARD LVCMOS33 } [get_ports { AND_70[2] }];	
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { AND_70[3] }];	
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { AND_70[4] }];	
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { AND_70[5] }];	
set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports { AND_70[6] }];	
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { AND_70[7] }];	

set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { DP }];



 
	
        
      