`include "parameters.v"

module conv_ctrl(
    clk,
    reset,
    en_ctrl,
    s_addr,
    w_addr,
    b_addr,
    save_addr,
    en_sum,
    en_save,
    en_write,
    s_convout,
    en_sat,
    en_mac,
    en_mult_r,
    finish
);
    parameter [`BYTE-1:0] CONV_DIM_IMG    = 32;
    parameter [`BYTE-1:0] CONV_DIM_OUT    = 32;   //dimension of output img
    parameter [`BYTE-1:0] CONV_DIM_KERNEL = 5;    //dimension of kernel mask
    parameter [`BYTE-1:0] CONV_DIM_CH     = 3;   //dimension of input channel
    parameter [`BYTE-1:0] CONV_OUT_CH     = 32;  //dimension of output channel
    parameter [`BYTE-1:0] STRIDE          = 1;   //stride len
    parameter [`BYTE-1:0] PADDING         = 2;   // padding len
    parameter [`BYTE-1:0] KSIZE           = 4;

    localparam [2:0] START     = 0;
    localparam [2:0] ITERATING = 1;
    localparam [2:0] SAVE      = 2;
    localparam [2:0] END       = 3;

    input clk;
    input reset;
    input en_ctrl;
    output [`HALF_WORD-1:0] s_addr;
    output [`HALF_WORD-1:0] w_addr;
    output [`HALF_WORD-1:0] save_addr;
    output [`HALF_WORD-1:0] b_addr;
    output finish;
    output en_sum, en_save;
    output en_mult_r;
    output reg en_write, en_mac, en_sat, s_convout;

    wire [`BYTE-1:0] i, j, k, l, m, n;
    wire signed [`BYTE-1:0] in_row, in_col;
    reg en_read;

    assign en_mult_r = (k >= 8'd2 || j == 8'd2) ? 1'b1 
                     : (k == 8'd1 || j == 8'd1) ? 1'b0 
                     : (m > 8'd0  || n > 8'd0) ? 1'b0 : 1'b1; 

    always @(posedge clk) begin
        if (reset) begin
            en_read   <= 1'b0;
            en_write  <= 1'b0;
            s_convout <= 1'b0;
            en_mac    <= 1'b0; 
            en_sat    <= 1'b0;
        end else if (en_ctrl) begin
            en_read   <= en_sum;
            en_mac    <= en_read;
            s_convout <= en_save;
            en_sat    <= en_save;
            en_write  <= en_sat;
        end
    end

    /*always @(reset, j, k, m, n, en_mult_r) begin
        if(reset) begin
            en_mult_r <= 0;
        end else if(j < 8'd2 && k < 8'd2) begin
            if(j == 0 && k == 0 && m == 0 && n == 0) begin
                en_mult_r <= 1;
            end else begin
                en_mult_r <= 0;
            end
        end else if(j > 8'd2 && k < 8'd2) begin
            if(k == 0 && m == 0 && n == 0) begin
                en_mult_r <= 1;
            end else begin
                en_mult_r <= 0;
            end
        end else begin
            en_mult_r <= 1;
        end
    end*/

    iterator #(
        .CONV_DIM_IMG(CONV_DIM_IMG),
        .CONV_DIM_OUT(CONV_DIM_OUT),
        .CONV_DIM_KERNEL(CONV_DIM_KERNEL),
        .CONV_OUT_CH(CONV_OUT_CH),
        .CONV_DIM_CH(CONV_DIM_CH),
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
        .en_save(en_save),    
        .fin_r(finish),
        .in_row(in_row),
        .in_col(in_col)
    );

    addr_generator #(
        .CONV_DIM_IMG(CONV_DIM_IMG),
        .CONV_DIM_KERNEL(CONV_DIM_KERNEL),
        .CONV_DIM_CH(CONV_DIM_CH),
        .CONV_DIM_OUT(CONV_DIM_OUT),
        .CONV_OUT_CH(CONV_OUT_CH),
        .STRIDE(STRIDE),
        .PADDING(PADDING),
        .KSIZE(KSIZE)
    ) address_generator (
        .clk(clk),
        .reset(reset),
        .enable(en_sum),
        .en_save(s_convout),
        .i(i),
        .j(j),
        .k(k),
        .l(l),
        .m(m),
        .n(n),
        .s_addr(s_addr),
        .w_addr(w_addr),
        .b_addr(b_addr),
        .save_addr(save_addr)
    );

endmodule
