# CLK 
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK }]; 
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK}];


#RST
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { RST }];	

#led BUSY					
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { BUSY }]; 
	
# OLED (JA)

set_property -dict { PACKAGE_PIN C17    IOSTANDARD LVCMOS33 } [get_ports { CS }]; #JA1
set_property -dict { PACKAGE_PIN D18    IOSTANDARD LVCMOS33 } [get_ports { SDIN }]; #JA2
set_property -dict { PACKAGE_PIN G17    IOSTANDARD LVCMOS33 } [get_ports { SCLK }]; #JA4
set_property -dict { PACKAGE_PIN D17    IOSTANDARD LVCMOS33 } [get_ports { D_C }]; #JA7
set_property -dict { PACKAGE_PIN E17    IOSTANDARD LVCMOS33 } [get_ports { RES }]; #JA8
set_property -dict { PACKAGE_PIN F18    IOSTANDARD LVCMOS33 } [get_ports { VBAT }]; #JA9
set_property -dict { PACKAGE_PIN G18    IOSTANDARD LVCMOS33 } [get_ports { VDD }]; #JA10

#pulsador DATA_OK
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { DATA_OK }];	
		
	
# switches DATA 
# switches sw 
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { DATA[0] }];	
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { DATA[1] }];	
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { DATA[2] }];	
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { DATA[3] }];	
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { DATA[4] }];	
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { DATA[5] }];	
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { DATA[6] }];	
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { DATA[7] }];	


	
        
      