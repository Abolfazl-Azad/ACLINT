module aclint #(
    parameter CLINT_BASE = 32'h0200_0000
)(
    input         clk,
    input         rst,

    input         mem_write,
    input         mem_read,
    input  [31:0] mem_address,
    input  [63:0] data_in,
    output reg [63:0] data_out,

    output        mtip,
    output        msip_to_core
);

    localparam [31:0] MSIP_OFFSET     = 32'h0000;
    localparam [31:0] MTIMECMP_OFFSET = 32'h4000;
    localparam [31:0] MTIME_OFFSET    = 32'hBFF8;

    wire [31:0] offset = mem_address - CLINT_BASE;

    // --------------//
    // MTIME counter-//
    // --------------//
    reg [63:0] mtime;

    always @(posedge clk or posedge rst) begin
        if (rst)
            mtime <= 64'd0;
        else if (mem_write && offset == MTIME_OFFSET)
            mtime <= data_in;
        else
            mtime <= mtime + 64'd1;
    end

    
    // ---------//
    // MTIMECMP-//
    // ---------//
    reg [63:0] mtimecmp0;

    always @(posedge clk) begin
        if (mem_write && offset == MTIMECMP_OFFSET)
            mtimecmp0 <= data_in;
    end
    // -----//
    // MSIP-//
    // -----//
    reg msip0;

    always @(posedge clk or posedge rst) begin
        if (rst)
            msip0 <= 1'b0;
        else if (mem_write && offset == MSIP_OFFSET)
            msip0 <= data_in[0];
    end

    // -----------------//
    // Output Interrupts//
    // ----------------//
    assign mtip         = (mtime >= mtimecmp0);
    assign msip_to_core = msip0;

    // ------------------//
    // Reading registers-//
    // ------------------//
    always @(*) begin
        data_out = 64'd0;
        if (mem_read) begin
            case (offset)
                MSIP_OFFSET:     data_out = {63'd0, msip0};
                MTIMECMP_OFFSET: data_out = mtimecmp0;
                MTIME_OFFSET:    data_out = mtime;
                default:         data_out = 64'd0;
            endcase
        end
    end

endmodule
