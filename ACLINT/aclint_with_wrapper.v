module aclint_with_wrapper (
    input clk,
    input rst,
    input mem_write,
    input mem_read,
    input [31:0] mem_address,
    input [7:0]  data_in,
    output [7:0] data_out,
    output mtip,
    output msip_to_core
);

wire [31:0] mem_addr;
wire [63:0] mem_data,data_out_aclint;
wire mem_write_aclint,mem_read_aclint;

Input_wrapper input_wrapper (
    .clk(clk),
    .rst(rst),
    .memWrite(mem_write),
    .address_CLINT(mem_address),
    .dataIn(data_in),
    .mem_addr(mem_addr),
    .mem_data(mem_data),
    .mem_write(mem_write_aclint)
);

aclint aclint (
    .clk(clk),
    .rst(rst),
    .mem_write(mem_write_aclint),
    .mem_read(mem_read),
    .mem_address(mem_addr),
    .data_in(mem_data),
    .data_out(data_out_aclint),
    .mtip(mtip),
    .msip_to_core(msip_to_core)
);

Output_wrapper output_wrapper (
    .clk(clk),
    .rst(rst),
    .memRead(mem_read),
    .address_CLINT(mem_address),
    .dataIn(data_out_aclint),
    .dataout_Output_wrapper(data_out),
    .memReady(mem_read_aclint)
);



endmodule