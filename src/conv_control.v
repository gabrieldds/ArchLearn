
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
	counterIis32,
	in_row,
	in_col
);
	parameter [`BYTE-1:0] CONV_IM_DIM     = 32;
	parameter [`BYTE-1:0] CONV_DIM_KERNEL = 5;
	parameter [`BYTE-1:0] CONV_DIM_OUT    = 32;
	parameter [`BYTE-1:0] CONV_OUT_CH     = 32;
	parameter [`BYTE-1:0] STRIDE          = 1;
	parameter [`BYTE-1:0] PADDING         = 2;

	input clk;
	input en_ctrl;
	input reset;

	output reg counterIis32;
	output reg [`BYTE-1:0] i; //counter_convout;
	output reg [`BYTE-1:0] j; //counter_img_dimX;
	output reg [`BYTE-1:0] k; //counter_img_dimY;
	output reg [`BYTE-1:0] m; //counter_kernel_dimX;
	output reg [`BYTE-1:0] n; //counter_kernel_dimY;
	output signed [`BYTE-1:0]  in_row, in_col;

	always @(posedge clk) begin
		if (reset) begin
			n <= 0;
			i <= 0;
			j <= 0;
			k <= 0;
			m <= 0;
			m <= 0;
			counterIis32 <= 0;
		end 
		else begin
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

	assign in_row = (STRIDE * j) + m - PADDING;
	assign in_col = (STRIDE * k) + n - PADDING;


endmodule