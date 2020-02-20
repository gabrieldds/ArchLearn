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
    en_read,
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
    output reg en_read, en_write, en_mac, en_sat, s_convout, en_mult_r;

    wire [`BYTE-1:0] i, j, k, l, m, n;
    wire signed [`BYTE-1:0] in_row, in_col;
    reg en_save_r, en_ctrl_r;
    reg en_sum_r;
    reg [2:0] state;

    /*always @(posedge clk) begin
        if (reset) begin
            state <= 0;
        end else begin
            case(state)
                START: begin
                    if(en_ctrl) begin
                        en_ctrl_r <= 1;
                        state     <= ITERATING; 
                    end else begin
                        state <= START;
                    end
                end
                ITERATING: begin
                    if(en_save) begin
                        en_ctrl_r <= 0;
                        state     <= SAVE;
                    end else if (finish) begin
                        en_ctrl_r <= 0;
                        state <= END;
                    end else begin
                        state <= ITERATING;
                    end
                end
                SAVE: begin
                    if(en_write) begin
                        en_ctrl_r <= 1;
                        state <= ITERATING;
                    end else begin
                        state <= SAVE;
                    end
                end
                END: begin
                    state <= START;
                end
            endcase
        end
    end*/

    always @(posedge clk) begin
        if (reset) begin
            en_read   <= 0;
            en_write  <= 0;
            en_save_r <= 0;
            en_ctrl_r <= 0;
            en_sum_r  <= 0;
            s_convout <= 0;
            en_mac    <= 0; 
            en_sat    <= 0;
            en_mult_r <= 0;
        end else if (en_ctrl) begin
            en_read   <= en_sum;
            en_mac    <= en_read;
            s_convout <= en_save;
            en_sat    <= en_save;
            en_write  <= en_sat;
        end
    end

    always @(j, k, m, n, en_mult_r) begin
        if(j < 8'd2 && k < 8'd2) begin
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
    end

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
