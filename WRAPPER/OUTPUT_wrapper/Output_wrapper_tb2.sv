`timescale 1ns/1ns

module tb_Output_wrapper;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_IN_WIDTH = 64;
    parameter DATA_OUT_WIDTH = 8;

    // Inputs
    reg clk;
    reg rst;
    reg memRead, memReady;
    reg [ADDR_WIDTH-1:0] address_CLINT;
    reg [DATA_IN_WIDTH-1:0] dataIn;

    // Output
    wire [DATA_OUT_WIDTH-1:0] dataout_Output_wrapper;

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Instantiate the wrapper
    Output_wrapper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .memRead(memRead),
        .address_CLINT(address_CLINT),
        .dataIn(dataIn),
        .dataout_Output_wrapper(dataout_Output_wrapper),
        .memReady (memReady)
    );

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        memRead = 0;
        address_CLINT = 32'h02000000;
        dataIn = 64'h00000000; // start with 0

        // Release reset
        #12;
        rst = 0;

        // Wait a few cycles
        #13;

        // Assert memRead for 1 cycle
        memRead = 1;
        #10; 
        dataIn = 64'h11223344556678;

        // Keep simulation running to observe all bytes
        #100;

        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | memRead=%b | dataIn=%h | dataout=%h", 
                 $time, memRead, dataIn, dataout_Output_wrapper);
    end

endmodule
