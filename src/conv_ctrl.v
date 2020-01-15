`include "parameters.v"
`include "parameters.v"

module conv_ctrl(
    clk,
    reset,
    en_ctrl,
    s_addr,
    w_addr,
    en_sum,
    finish
);
    parameter [`BYTE-1:0] CONV_DIM_IMG    = 32;
    parameter [`BYTE-1:0] CONV_DIM_OUT    = 32;   //dimension of output img
    parameter [`BYTE-1:0] CONV_DIM_KERNEL = 5; //dimension of kernel mask
    parameter [`BYTE-1:0] CONV_DIM_CH     = 3; //dimension of input channel
    parameter [`BYTE-1:0] CONV_OUT_CH     = 32; //dimension of output channel
    parameter [`BYTE-1:0] STRIDE          = 1;  //stride len
    parameter [`BYTE-1:0] PADDING         = 2;  // padding len

    input clk;
    input reset;
    input en_ctrl;
    output [`HALF_WORD-1:0] s_addr;
    output [`HALF_WORD-1:0] w_addr;
    output finish;
    output en_sum;

    wire [`BYTE-1:0] i, j, k, l, m, n;
    wire [`HALF_WORD-1:0] s_addr, w_addr;
    wire signed [`BYTE-1:0] in_row, in_col;
    wire en_sum;

    iterator #(
        .CONV_DIM_IMG(CONV_DIM_IMG),
        .CONV_DIM_OUT(CONV_DIM_OUT),
        .CONV_DIM_KERNEL(CONV_DIM_KERNEL),
        .CONV_OUT_CH(CONV_OUT_CH),
        .STRIDE(STRIDE),
        .PADDING(PADDING)
    ) iter (
        .clk(clk),
        .reset(reset),
        .en_ctrl(en_ctrl),
        .i(i),
        .j(j),
        .k(k),
        .l(l),
        .m(m),
        .n(n),
        .en_sum(en_sum),        
        .finish(finish),
        .in_row(in_row),
        .in_col(in_col)
    );

    addr_generator #(
        .CONV_DIM_IMG(CONV_DIM_IMG),
        .CONV_DIM_KERNEL(CONV_DIM_KERNEL),
        .CONV_DIM_CH(CONV_DIM_CH),
        .STRIDE(STRIDE),
        .PADDING(PADDING)
    ) address_generator (
        .clk(clk),
        .reset(reset),
        .enable(en_sum),
        .i(i),
        .j(j),
        .k(k),
        .l(l),
        .m(m),
        .n(n),
        .s_addr(s_addr),
        .w_addr(w_addr)
    );

endmodule
