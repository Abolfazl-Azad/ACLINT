`timescale 1ns/1ns

module Output_wrapper #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_IN_WIDTH = 64,
    parameter DATA_OUT_WIDTH = 8
) (
    input clk,
    input rst,
    input memRead,
    input [ADDR_WIDTH-1:0] address_CLINT,
    input [DATA_IN_WIDTH-1:0] intrupt_ID,

    output [DATA_OUT_WIDTH-1 : 0] dataout_Output_wrapper,
    output memReady
);

wire iniCnt;
wire incCnt;
wire co;


Output_wrapper_datapth datapath (
    .clk(clk),
    .rst(rst),
    .intrupt_ID(intrupt_ID),
    .iniCnt(iniCnt),
    .incCnt(incCnt),
    .initValue(3'b0),
    .co(co),
    .dataout_Output_wrapper(dataout_Output_wrapper)
);

Output_wrapper_controller controller (
    .clk(clk),
    .rst(rst),
    .mem_Read(memRead),
    .address_CLINT(address_CLINT),
    .co(co),
    .iniCnt(iniCnt),
    .incCnt(incCnt),
    .memReady(memReady)
);
    
endmodule