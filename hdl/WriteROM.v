`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:19:39 12/09/2018 
// Design Name: 
// Module Name:    WriteROM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module WriteROM(
                input fast_clock,
                input [14:0]address, 
                inout [7:0]data, 
                input _ce,
                input _oe,
                output _ce_flash,
					 output _oe_flash,
                output _we_flash, 
                output [18:0]baddress, 
                inout [7:0]bdata,
                output [7:0]test
               );

reg flag_program;
reg [7:0]data_out;
reg [7:0]bdata_out;
reg [2:0]state;
reg [14:0]addr;
reg [18:15]bank;
reg [11:0]address_latched;
reg enable_latched;
reg [1:0]delay;


wire clock;
wire flag_config;
wire ce_addr_lo;
wire ce_addr_mid;
wire ce_bank;
wire oe_data;
wire we_data;

assign clock = 					(delay == 2'h3);


assign test[0] =              clock;
assign test[1] =              0;
assign test[2] =              0;
assign test[3] =              0;
assign test[4] =              0;
assign test[5] =              0;
assign test[6] =              0;
assign test[7] =    				_we_flash;          

assign flag_config =           (state[2]);

assign ce_addr_lo =           !flag_config & flag_program & (address_latched[10:8] == 0);
assign ce_addr_mid =          !flag_config & flag_program & (address_latched[10:8] == 1);
assign ce_bank =              !flag_config & flag_program & (address_latched[10:8] == 2);

assign oe_data =              !flag_config & flag_program & (address_latched[10:8] == 6);
assign we_data =              !flag_config & flag_program & (address_latched[10:8] == 7);


assign bdata =                bdata_out;
assign data =                 data_out;
assign _ce_flash =            !(clock & (we_data | oe_data | !flag_program));   //(clock & (flag_program ? (oe_data | we_data) : 1));
assign _oe_flash = 				!(clock & (oe_data | !flag_program));
assign _we_flash =            !(clock & we_data);
assign baddress[18:15] =      bank;
assign baddress[14:0] =       (flag_program ? addr : address);

always @(posedge fast_clock)
begin
	enable_latched <= !_ce & !_oe;
	address_latched <= address;
end

always @(posedge fast_clock)
begin
	if(!enable_latched)
		delay <= 0;
	else
   begin
		if(!clock)
			delay <= delay + 1;
	end
end

always @(posedge clock)
begin
	if(flag_config)
		flag_program <= address_latched[0];
	else if(ce_addr_lo)
		addr[7:0] <= address_latched[7:0]; 
	else if(ce_addr_mid)
		addr[14:8] <= address_latched[6:0]; 
	else if(ce_bank)
		bank[18:15] <= address_latched[3:0]; 
end

always @(*)
begin
   if(we_data)
      bdata_out = address_latched[7:0];
   else
      bdata_out = 8'bz;
end

always @(*)
begin
   if(clock & ce_addr_lo)
      data_out = addr[7:0];
   else if(clock & ce_addr_mid)
      data_out = {0, addr[14:8]};
   else if(clock & ce_bank)
      data_out = {5'b0, bank};
   else if(clock & (we_data | oe_data))
      data_out = bdata;
   else if(clock & flag_program)
      data_out = 0;
   else if(clock & !flag_program)
      data_out = bdata;
   else
      data_out = 8'bz;
end

always @(posedge clock)
begin
   case(state)
      0:
         if(address_latched[11:0] == 12'h555)
            state <= 1;
      1:
         if(address_latched[11:0] == 12'haaa)
            state <= 2;
         else
            state <= 0;
      2:
         if(address_latched[11:0] == 12'h555)
            state <= 3;
         else
            state <= 0;
      3:
         if(address_latched[11:0] == 12'h2aa)
            state <= 4;
         else
            state <= 0;
      default:
         state <= 0;
   endcase
end
endmodule