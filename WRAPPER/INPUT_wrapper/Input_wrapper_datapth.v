`timescale 1ns/1ns

module Input_wrapper_datapath #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_IN_WIDTH = 8,
    parameter DATA_OUT_WIDTH = 64,
    parameter CLINT_BASE = 32'h0200_0000
)(
    input clk,
    input rst,
    input memWrite,

    input [ADDR_WIDTH-1:0]          address_CLINT,
    input [DATA_IN_WIDTH-1:0]       dataIn,

    input                           iniCnt,
    input                           incCnt,
    input [2:0]                     initValue,
    input                           En,
    input                           zero,

    output                          co,
    output wire[DATA_OUT_WIDTH-1:0] dataout_Input_wrapper,
    output reg                      correct_address
);

    localparam [31:0] MSIP_OFFSET     = 32'h0000;
    localparam [31:0] MTIMECMP_OFFSET = 32'h4000;
    localparam [31:0] MTIME_OFFSET    = 32'hBFF8;

    wire [31:0] offset = address_CLINT - CLINT_BASE;

    wire [2:0] out_cnt;
    wire En_datapath;
    assign En_datapath = (correct_address && memWrite)  || En;
 

    Wrapper_shift_register #(.IN_WIDTH(8),.OUT_WIDTH(64)) shift_reg
    (
        .clk(clk),
        .rst(rst),
        .load(En_datapath),
        .data_in(dataIn),
        .data_out(dataout_Input_wrapper)
    );

    wrapper_counter #(3) counter (
        .clk(clk),
        .rst(rst),
        .incCnt(incCnt),
        .iniCnt(iniCnt),
        .initValue(3'b0),
        .dataOut(out_cnt),
        .co(co),
        .zero(zero)
    );

    always @(*) begin
        if (((offset == MTIMECMP_OFFSET) || (offset == MSIP_OFFSET))||(offset == MTIMECMP_OFFSET))
        begin
            correct_address = 1'b1;
        end
        else
            correct_address = 1'b0;
    end

endmodule

