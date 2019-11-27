`include "parameters.v"

module addr_iter(
    clk,
    enable,
    i,
    j,
    k,
    m,
    n,
    l,
    s_addr,
    w_addr
);

    parameter [`BYTE-1:0] CONV_DIM_IMG = 32;
	parameter [`BYTE-1:0] CONV_DIM_OUT = 32;
	parameter [`BYTE-1:0] CONV_DIM_KERNEL = 5;
	parameter [`BYTE-1:0] CONV_DIM_CH     = 3;
    parameter [`BYTE-1:0] STRIDE          = 1;
    parameter [`BYTE-1:0] PADDING         = 2;

    input clk;
    input enable;
    input [`BYTE-1:0] i;
    input [`BYTE-1:0] j;
    input [`BYTE-1:0] k;
    input [`BYTE-1:0] m;
    input [`BYTE-1:0] n;
    input [`BYTE-1:0] l;
    output reg [`HALF_WORD-1:0] s_addr;
    output reg [`HALF_WORD-1:0] w_addr;

	//assign s_addr = (enable) ? (((((STRIDE * j) + m - PADDING) * CONV_DIM_IMG) + ((STRIDE * k) + n - PADDING)) * CONV_DIM_CH) + l : 0;
	//assign w_addr = (enable) ? (i * CONV_DIM_CH * CONV_DIM_KERNEL * CONV_DIM_KERNEL) + (((m * CONV_DIM_KERNEL) + (n)) * CONV_DIM_CH) + l : 0;

    always @(posedge clk) begin
        if(enable) begin
            s_addr <= (((((STRIDE * j) + m - PADDING) * CONV_DIM_IMG) + ((STRIDE * k) + n - PADDING)) * CONV_DIM_CH) + l;
            w_addr <= (i * CONV_DIM_CH * CONV_DIM_KERNEL * CONV_DIM_KERNEL) + (((m * CONV_DIM_KERNEL) + (n)) * CONV_DIM_CH) + l;
        end else begin
            s_addr <= 0;
            w_addr <= 0;
        end
    end
endmodule  