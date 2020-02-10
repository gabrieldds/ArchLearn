
`include "parameters.v"

module iterator(
	clk,
	reset,
	en_ctrl, 
	i, 
	j, 
	k,
	l,
	m, 
	n,
	en_sum,
	en_save,
	finish,
	in_row,
	in_col
);
	parameter [`BYTE-1:0] CONV_DIM_IMG    = 32; //dimension of input img
	parameter [`BYTE-1:0] CONV_DIM_OUT    = 32; //dimension of output img
	parameter [`BYTE-1:0] CONV_DIM_KERNEL = 5;  //dimension of kernel mask
	parameter [`BYTE-1:0] CONV_OUT_CH     = 32; //dimension of output channel
	parameter [`BYTE-1:0] STRIDE          = 1;
	parameter [`BYTE-1:0] PADDING         = 2;
	
	localparam [3:0] START = 0;
	localparam [3:0] IINC  = 6;
	localparam [3:0] JINC  = 5;
	localparam [3:0] KINC  = 4;
	localparam [3:0] LINC  = 3;
	localparam [3:0] MINC  = 2;
	localparam [3:0] NINC  = 1;
	
	input clk;
	input en_ctrl;
	input reset;

	output en_sum;
	output reg en_save;
	output reg finish;
	output reg [`BYTE-1:0] i; //counter_convout;
	output reg [`BYTE-1:0] j; //counter_img_dimX;
	output reg [`BYTE-1:0] k; //counter_img_dimY;
	output reg [`BYTE-1:0] m; //counter_kernel_dimX;
	output reg [`BYTE-1:0] n; //counter_kernel_dimY;
	output reg [`BYTE-1:0] l; //counter_kernel_dimY;
	output signed [`BYTE-1:0]  in_row, in_col;

	reg [3:0] state;
	
	wire cond;
	assign in_row = (STRIDE * j) + m - PADDING;
	assign in_col = (STRIDE * k) + n - PADDING;
	assign cond   = en_ctrl & ~finish;
	assign en_sum = (en_ctrl && (l < 2'd3) && (in_row >= 8'd0 && in_col >= 8'd0 && in_row < CONV_DIM_IMG && in_col < CONV_DIM_IMG)) ? 1 : 0;
	//assign en_save  = (j < 8'd2 && k < 8'd2) ? (n == 0 && m == 0) : (n == 0 && m == 0 && l == 0) ? 1 : 0;

	always @(j, k, l, m, n, en_save) begin
		if (j < 8'd2 && m == 0 && n == 0) begin
			en_save <= 1;
		end else if(j >= 8'd2 && m == 0 && n == 0 && l == 0) begin
			en_save <= 1;
		end else begin
			en_save <= 0;
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			i <= 0;
			j <= 0;
			k <= 0;
			m <= 0;
			n <= 0;
			finish <= 0;
		end else if(cond) begin
		    if(en_sum) begin
				l <= l + 8'd1;
			end else begin
				l <= 0;
				n <= n + 8'd1;
				if(n == (CONV_DIM_KERNEL-1)) begin
			    	n <= 8'b0;
			    	m <= m + 8'b1;
			    	if(m == (CONV_DIM_KERNEL-1)) begin
			    		m <= 0;
			       		k <= k + 8'b1;
			       		if(k == (CONV_DIM_OUT-1)) begin
			           		k <= 0;
			           		j <= j + 8'b1;
			           		if(j == (CONV_DIM_OUT-1)) begin
				           		j <= 0;
				           		i <= i + 8'b1;
				           		if(i == (CONV_OUT_CH-1)) begin
				            		i <= 0;
					          		finish <= 1;
				           		end
				   	    	end
			           	end
		           	end
			    end
			end
		end
	end

endmodule