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
//`DEFINE TESTING

module WriteROM(
                input [15:0]address, 
                inout [7:0]data, 
                input _ce,
                input _oe,
                output _ce_flash,
					 output _oe_flash,
                output _we_flash, 
                output [18:0]baddress, 
                inout [7:0]bdata,
					 input [1:0]size,
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
wire [18:13]bank;

assign clock = 					(!_ce & !_oe);


`ifdef TESTING
assign test[0] =              clock;
assign test[1] =              size[0];
assign test[2] =              size[1];
assign test[3] =              0;
assign test[4] =              0;
assign test[5] =              0;
assign test[6] =              0;
assign test[7] =    				_we_flash;
`endif

assign bank[13] = 				(size >  2 ? addr[13] : address[13]);
assign bank[14] = 				(size >  1 ? addr[14] : address[14]);
assign bank[15] = 				(size >  0 ? addr[15] : address[15]);
assign bank[16] = 				addr[16];
assign bank[17] = 				addr[17];
assign bank[18] = 				addr[18];

assign flag_config =          (state[2]);

assign ce_addr_lo =           !flag_config & flag_program & (address[11:8] == 0);
assign ce_addr_mid =          !flag_config & flag_program & (address[11:8] == 1);
assign ce_bank =              !flag_config & flag_program & (address[11:8] == 2);

// be careful using opcode 5, as it will be triggered during the "knock" sequence (555 portion)
assign oe_data =              !flag_config & flag_program & (address[11:8] == 6);
assign we_data =              !flag_config & flag_program & (address[11:8] == 7);
// be careful using opcode a, as it will be triggered during the "knock" sequence (aaa/aa2 portion)


assign bdata =                bdata_out;
assign data =                 data_out;
assign _ce_flash =            !(clock & (we_data | oe_data | !flag_program));
assign _oe_flash = 				!(clock & (oe_data | !flag_program));
assign _we_flash =            !(clock & we_data);
assign baddress[18:0] =       (flag_program ? addr[18:0] : {bank , address[12:0]});

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

/* 
	Many CPUs issue a read of FFFF during dead cycles, which	could mess up
	the sequence if the ROM is installed at top of the memory map.
	Simplest solution is to ignore FFF in sequence.  
	(h/t Mike Miller from CoCo Discord)
 */
 
assign clk_knock = (clock & address[11:0] != 12'hfff);

always @(posedge clk_knock)
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
		   /* It was 2aa, but then 2 can't be used as a command */
         if(address[11:0] == 12'haa2)
            state <= 4;
         else
            state <= 0;
      default:
         state <= 0;
   endcase
end
endmodule