
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
	save,
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

	output en_sum, save;
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
	assign save   = (n == 4 && m == 4) ? 1 : 0; 
	/*
	always @(posedge clk) begin
		if (reset) begin
			i <= 0;
			j <= 0;
			k <= 0;
			m <= 0;
			n <= 0;
			finish <= 0;
			state <= NINC;
		end else begin
			case(state)
				START: begin
					if(cond) begin
						state <= LINC;
					end else begin
						state <= START;
					end
				end
				NINC: begin
					if (n < (CONV_DIM_KERNEL-1) && !en_sum) begin
						l <= 8'd0;
						n <= n + 8'd1;
						state <= LINC;
					end else begin
						state <= MINC;
					end
				end
				LINC: begin
					if ((l < 2'd3) && (in_row >= 8'd0 && in_col >= 8'd0 && in_row < CONV_DIM_IMG && in_col < CONV_DIM_IMG)) begin
						l <= l + 8'd1;
						state <= LINC;
					end else begin
						state <= NINC;
					end
				end
				MINC: begin
					if (m < (CONV_DIM_KERNEL-1)) begin
						n <= 8'd0;
						m <= m + 8'd1;
						state <= NINC;
					end else begin
						state <= KINC;
					end
				end
				KINC: begin
					if (k < (CONV_DIM_OUT-1)) begin
						m <= 8'd0;
						k <= k + 8'd1;
						state <= MINC;
					end else begin
						state <= JINC;
					end
				end
				JINC: begin
					if (j < (CONV_DIM_OUT-1)) begin
						k <= 8'd0;
						j <= j + 8'd1;
						state <= KINC;
					end else begin
						state <= IINC;
					end
				end
				IINC: begin
					if (i < (CONV_OUT_CH-1)) begin
						j <= 8'd0;
						i <= i + 8'd1;
						state <= NINC;
					end else begin
						state <= START;
						finish <= 1;
					end
				end
			endcase
		end	
	end*/
	
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
			    	if (m == (CONV_DIM_KERNEL-1)) begin
			    		m <= 0;
			       		k <= k + 8'b1;
			       		if(k == (CONV_DIM_OUT-1)) begin
			           		k <= 0;
			           		j <= j + 8'b1;
			           		if (j == (CONV_DIM_OUT-1)) begin
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