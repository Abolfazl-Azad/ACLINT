`timescale 1ns/1ps

module tb_aclint;

    localparam CLINT_BASE = 32'h0200_0000;

    localparam MSIP_OFFSET     = 32'h0000;
    localparam MTIMECMP_OFFSET = 32'h4000;
    localparam MTIME_OFFSET    = 32'hBFF8;

    logic        clk;
    logic        rst;

    logic        mem_write;
    logic        mem_read;
    logic [31:0] mem_address;
    logic [63:0] data_in;
    logic [63:0] data_out;

    logic        mtip;
    logic        msip_to_core;

    aclint #(
        .CLINT_BASE(CLINT_BASE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_address(mem_address),
        .data_in(data_in),
        .data_out(data_out),
        .mtip(mtip),
        .msip_to_core(msip_to_core)
    );

    always #5 clk = ~clk;

    task reset_dut();
        begin
            rst = 1;
            mem_write = 0;
            mem_read  = 0;
            data_in   = 0;
            mem_address = 0;
            repeat (2) @(posedge clk);
            rst = 0;
            @(posedge clk);
            $display("[RESET] Done");
        end
    endtask

    task write_clint(input [31:0] offset, input [63:0] value);
        begin
            @(posedge clk);
            mem_write   = 1;
            mem_read    = 0;
            mem_address = CLINT_BASE + offset;
            data_in     = value;
            @(posedge clk);
            mem_write   = 0;
            $display("[WRITE] addr=%h data=%0d", offset, value);
        end
    endtask

    task read_clint(input [31:0] offset, output [63:0] value);
        begin
            @(posedge clk);
            mem_read    = 1;
            mem_write   = 0;
            mem_address = CLINT_BASE + offset;
            @(posedge clk);
            value = data_out;
            mem_read = 0;
            $display("[READ] addr=%h data=%0d", offset, value);
        end
    endtask

    // -----------------------
    // Scenario 1: MTIME increments
    // -----------------------
    task test_mtime_increment();
        reg [63:0] t1, t2;
        begin
            read_clint(MTIME_OFFSET, t1);
            repeat (5) @(posedge clk);
            read_clint(MTIME_OFFSET, t2);

            assert(t2 > t1)begin
                $display("[PASS] MTIME increments");
                $display("[READ] t1=%0d t2=%0d", t1, t2);
            end
            else begin
                $error("[FAIL] MTIME did not increment");
                $display("[READ] t1=%0d t2=%0d", t1, t2);
            end
        end
    endtask

    // -----------------------
    // Scenario 2: MTIME write
    // -----------------------
    task test_mtime_write();
        reg [63:0] val;
        begin
            write_clint(MTIME_OFFSET, 64'd100);
            read_clint(MTIME_OFFSET, val);

            assert(val == 101)                           // we should check 101 because we are reading after one clk so the write value is incremented.
                $display("[PASS] MTIME write works");
            else
                $error("[FAIL] MTIME write failed");
        end
    endtask

    // -----------------------
    // Scenario 3: MTIMECMP + MTIP
    // -----------------------
    task test_mtimecmp_interrupt();
        begin
            write_clint(MTIME_OFFSET, 64'd0);
            write_clint(MTIMECMP_OFFSET, 64'd10);

            wait (mtip == 1);
            $display("[PASS] MTIP asserted");

            write_clint(MTIMECMP_OFFSET, 64'd100);
            @(posedge clk);

            assert(mtip == 0)
                $display("[PASS] MTIP cleared");
            else
                $error("[FAIL] MTIP stuck high");
        end
    endtask

    // -----------------------
    // Scenario 4: MSIP
    // -----------------------
    task test_msip();
        reg [63:0] val;
        begin
            write_clint(MSIP_OFFSET, 64'd1);
            @(posedge clk);
            assert(msip_to_core == 1)
                $display("[PASS] MSIP set");

            read_clint(MSIP_OFFSET, val);

            assert(val[0] == 1)
                $display("[PASS] MSIP readback correct");

            write_clint(MSIP_OFFSET, 64'd0);
            @(posedge clk);
            assert(msip_to_core == 0)
                $display("[PASS] MSIP cleared");
        end
    endtask

    // -----------------------
    // Scenario 5: Invalid Address
    // -----------------------
    task test_invalid_access();
        reg [63:0] val;
        begin
            read_clint(32'h1234, val);
            assert(val == 0)
                $display("[PASS] Invalid read returns zero");
            else
                $error("[FAIL] Invalid address read error");
        end
    endtask

    initial begin
        clk = 0;

        reset_dut();

        test_mtime_increment();
        test_mtime_write();
        test_mtimecmp_interrupt();
        test_msip();
        test_invalid_access();

        $finish;
    end

endmodule
