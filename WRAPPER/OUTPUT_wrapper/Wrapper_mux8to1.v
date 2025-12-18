
`timescale 1ns/1ns

module wrapper_mux8to1 #(parameter size = 32) (
    input [size-1:0] i0,
    input [size-1:0] i1,
    input [size-1:0] i2,
    input [size-1:0] i3,
    input [size-1:0] i4,
    input [size-1:0] i5,
    input [size-1:0] i6,
    input [size-1:0] i7,
    input [2:0] sel,
    output [size-1:0] dataOut
);

    assign dataOut = (sel == 3'd7) ? i7 :
                     (sel == 3'd6) ? i6 :
                     (sel == 3'd5) ? i5 :
                     (sel == 3'd4) ? i4 :
                     (sel == 3'd3) ? i3 :
                     (sel == 3'd2) ? i2 :
                     (sel == 3'd1) ? i1 : i0;

endmodule