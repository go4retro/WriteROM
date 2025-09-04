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
reg [18:0]addr;


wire clock;
wire flag_config;
wire ce_addr_lo;
wire ce_addr_mid;
wire ce_bank;
wire oe_data;
wire we_data;

assign clock = 					(!_ce & !_oe);


assign test[0] =              clock;
assign test[1] =              0;
assign test[2] =              0;
assign test[3] =              0;
assign test[4] =              0;
assign test[5] =              0;
assign test[6] =              0;
assign test[7] =    				_we_flash;          

assign flag_config =           (state[2]);

assign ce_addr_lo =           !flag_config & flag_program & (address[11:8] == 0);
assign ce_addr_mid =          !flag_config & flag_program & (address[11:8] == 1);
assign ce_bank =              !flag_config & flag_program & (address[11:8] == 2);

// be careful using opcode 5, as it will be triggered during the "knock" sequence (555 portion)
assign oe_data =              !flag_config & flag_program & (address[11:8] == 6);
assign we_data =              !flag_config & flag_program & (address[11:8] == 7);
// be careful using opcode a, as it will be triggered during the "knock" sequence (aaa/aa2 portion)


assign bdata =                bdata_out;
assign data =                 data_out;
assign _ce_flash =            !(clock & (we_data | oe_data | !flag_program));   //(clock & (flag_program ? (oe_data | we_data) : 1));
assign _oe_flash = 				!(clock & (oe_data | !flag_program));
assign _we_flash =            !(clock & we_data);
assign baddress[18:15] =      addr[18:15];
assign baddress[14:0] =       (flag_program ? addr : address);

always @(posedge clock)
begin
	if(flag_config)
		flag_program <= address[0];
	else if(ce_addr_lo)
		addr[7:0] <= address[7:0]; 
	else if(ce_addr_mid)
		addr[15:8] <= address[7:0]; 
	else if(ce_bank)
		addr[18:16] <= address[2:0]; 
end

always @(*)
begin
   if(we_data)
      bdata_out = address[7:0];
   else
      bdata_out = 8'bz;
end

always @(*)
begin
   if(clock & ce_addr_lo)
      data_out = addr[7:0];
   else if(clock & ce_addr_mid)
      data_out = addr[15:8];
   else if(clock & ce_bank)
      data_out = {5'b0, addr[18:16]};
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
         if(address[11:0] == 12'h555)
            state <= 1;
      1:
         if(address[11:0] == 12'haaa)
            state <= 2;
         else
            state <= 0;
      2:
         if(address[11:0] == 12'h555)
            state <= 3;
         else
            state <= 0;
      3:
         if(address[11:0] == 12'haa2)
            state <= 4;
         else
            state <= 0;
      default:
         state <= 0;
   endcase
end
endmodule