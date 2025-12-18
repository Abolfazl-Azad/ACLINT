`timescale 1ns/1ns

`define IDLE      2'b00
`define Send_Data 2'b01

module Output_wrapper_controller #(
    parameter address     = 32,
    parameter CLINT_BASE = 32'h0200_0000
    )(
    input clk,
    input rst,
    input mem_Read,
    input co,
    input [address-1 : 0] address_CLINT,

    output reg iniCnt,
    output reg incCnt,
    output reg memReady
);
    localparam [31:0] MSIP_OFFSET     = 32'h0000;
    localparam [31:0] MTIMECMP_OFFSET = 32'h4000;
    localparam [31:0] MTIME_OFFSET    = 32'hBFF8;

    wire [31:0] offset = address_CLINT - CLINT_BASE;

    reg [1:0] p_state, n_state;
    reg correct_address;


    always @(*) 
        begin
            if (((offset == MTIMECMP_OFFSET) || (offset == MSIP_OFFSET))||(offset == MTIMECMP_OFFSET))
        begin
            correct_address = 1'b1;
        end
        else
            correct_address = 1'b0;
        end

    always @(posedge clk or posedge rst) begin
        if (rst)
            p_state <= `IDLE;
        else
            p_state <= n_state;
    end

    always @(*) begin
        n_state = `IDLE;
        case (p_state)
            `IDLE: begin
                if(mem_Read & correct_address)
                    n_state = `Send_Data;
                else 
                    n_state = `IDLE;          
            end 

            `Send_Data: begin
                if(co) 
                    n_state = `IDLE;          
                else 
                    n_state = `Send_Data;     
            end
            default: n_state = `IDLE;         
        endcase
    end

    always @(*) begin
        {iniCnt, incCnt, memReady} = 4'b0000;
        case (p_state)
            `IDLE: begin
                    iniCnt = 1'b1; 
            end 

            `Send_Data: begin
                if (co) begin
                    incCnt   = 1'b0;
                    memReady = 1'b0;
                end else begin
                    incCnt   = 1'b1;
                    memReady = 1'b1;
                end
            end
        endcase
    end

endmodule