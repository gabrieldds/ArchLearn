module iter_tb;

    localparam period = 20;
    reg clk, reset, en_ctrl;
    wire en_sum, save, finish;
    wire signed [7:0] in_row, in_col;

    always begin
        clk = 1'b1;
        #period;
        clk = 1'b0;
        #period;
    end

    initial begin
    reset = 1;
    #period
    reset = 0;
    #period
    en_ctrl = 1;
    end

    always @(posedge clk) begin
        if (finish) begin
            $stop;
        end
    end

    wire [7:0] i; //counter_convout;
	wire [7:0] j; //counter_img_dimX;
	wire [7:0] k; //counter_img_dimY;
	wire [7:0] m; //counter_kernel_dimX;
	wire [7:0] n; //counter_kernel_dimY;
    wire [1:0] l;

    iterator iter(clk, en_ctrl, reset, i, j, k, l, m, n, en_sum, save, finish, in_row, in_col);

endmodule