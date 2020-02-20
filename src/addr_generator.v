`include "parameters.v"

module addr_generator(
    clk,
    reset,
    enable,
    en_save,
    i,
    j,
    k,
    l,
    m,
    n,
    s_addr,
    w_addr,
    b_addr,
    save_addr
);

    parameter [`BYTE-1:0] CONV_DIM_IMG    = 32;
	parameter [`BYTE-1:0] CONV_DIM_KERNEL = 5;
	parameter [`BYTE-1:0] CONV_DIM_CH     = 3;
    parameter [`BYTE-1:0] CONV_OUT_CH     = 32;
    parameter [`BYTE-1:0] CONV_DIM_OUT    = 32;
    parameter [`BYTE-1:0] STRIDE          = 1;
    parameter [`BYTE-1:0] PADDING         = 2;
    parameter [`BYTE-1:0] KSIZE           = 4;

    input clk;
    input reset;
    input enable;
    input en_save;
    input [`BYTE-1:0] i;
    input [`BYTE-1:0] j;
    input [`BYTE-1:0] k;
    input [`BYTE-1:0] m;
    input [`BYTE-1:0] n;
    input [`BYTE-1:0] l;
    output reg [`HALF_WORD-1:0] s_addr;
    output reg [`HALF_WORD-1:0] w_addr;
    output reg [`HALF_WORD-1:0] save_addr;
    output reg [`HALF_WORD-1:0] b_addr;

    always @(posedge clk) begin
        if(reset) begin
            s_addr <= 0;
            w_addr <= 0;
            b_addr <= 0;
        end else if(enable) begin
            s_addr <= (((((STRIDE * j) + m - PADDING) * CONV_DIM_IMG) + ((STRIDE * k) + n - PADDING)) * CONV_DIM_CH) + l;
            w_addr <= (i * CONV_DIM_CH * CONV_DIM_KERNEL * CONV_DIM_KERNEL) + (((m * CONV_DIM_KERNEL) + (n)) * CONV_DIM_CH) + l;
            b_addr <= i;
        end
    end

    reg [7:0] i_r, j_r, k_r;
    reg [7:0] i_r1, j_r1, k_r1;

    always @(posedge clk) begin
        if (reset) begin
            i_r <= 0;
            j_r <= 0;
            k_r <= 0;
            i_r1 <= 0;
            j_r1 <= 0;
            k_r1 <= 0;
        end else begin
            i_r  <= i;
            i_r1 <= i_r;
            j_r <= j;
            j_r1 <= j_r;
            k_r <= k;
            k_r1 <= k_r;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            save_addr <= 0;
        end else if(en_save) begin
            if (j == 0 && k == 0) begin
                save_addr <= i_r1 + (((j_r1 * CONV_DIM_OUT) + (k_r1)) * CONV_OUT_CH);
            end else begin
                save_addr <= i + (((j * CONV_DIM_OUT) + (k[KSIZE:0]-1)) * CONV_OUT_CH);
            end
        end
    end
endmodule  