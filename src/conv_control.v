
`include "parameters.v"

module conv_control(
	clk, 
	en_ctrl, 
	reset, 
	i, 
	j, 
	k, 
	m, 
	n,
	l,
	finish,
	in_row,
	in_col
);
	parameter [`BYTE-1:0] CONV_IM_DIM     = 32;
	parameter [`BYTE-1:0] CONV_DIM_KERNEL = 5;
	parameter [`BYTE-1:0] CONV_DIM_OUT    = 32;
	parameter [`BYTE-1:0] CONV_OUT_CH     = 32;
	parameter [`BYTE-1:0] STRIDE          = 1;
	parameter [`BYTE-1:0] PADDING         = 2;
	parameter [`BYTE-1:0] CONV_DIM_IMG    = 32;

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

	output reg finish;
	output reg [`BYTE-1:0] i; //counter_convout;
	output reg [`BYTE-1:0] j; //counter_img_dimX;
	output reg [`BYTE-1:0] k; //counter_img_dimY;
	output reg [`BYTE-1:0] m; //counter_kernel_dimX;
	output reg [`BYTE-1:0] n; //counter_kernel_dimY;
	output reg [1:0] l; //counter_kernel_dimY;
	output signed [`BYTE-1:0]  in_row, in_col;

	reg [3:0] state;
	
	wire cond;
	assign in_row = (STRIDE * j) + m - PADDING;
	assign in_col = (STRIDE * k) + n - PADDING;
	assign cond   = en_ctrl & ~finish;

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
						finish <= 0;
					end else begin
						state <= START;
					end
				end
				NINC: begin
					if (n < (CONV_DIM_KERNEL-1)) begin
						l <= 2'd0;
						n <= n + 8'd1;
						state <= LINC;
						/*if (in_row >= 8'd0 && in_col >= 8'd0 && in_row < CONV_DIM_IMG && in_col < CONV_DIM_IMG) begin
							state <= LINC;
						end*/
					end else begin
						state <= MINC;
					end
				end
				LINC: begin
					if ((l < 2'd2) && (in_row >= 8'd0 && in_col >= 8'd0 && in_row < CONV_DIM_IMG && in_col < CONV_DIM_IMG)) begin
						l <= l + 2'd1;
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
	end
	
	/*
	always @(posedge clk) begin
		if (reset) begin
			i <= 0;
			j <= 0;
			k <= 0;
			m <= 0;
			n <= 0;
			counterIis32 <= 0;
		end else begin
		    if (en_ctrl) begin
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
					          		counterIis32 <= 1;
				           		end
				   	    	end
			           	end
		           	end
			    end
			end
		end
	end
	*/

endmodule