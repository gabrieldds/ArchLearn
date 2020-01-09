
module conv_testb;

    localparam CONV1_MEM_LENGTH = 2400;
    localparam CONV2_MEM_LENGTH = 12800;
    localparam CONV3_MEM_LENGTH = 12800;
    localparam BIAS1_LENGTH     = 32;
    localparam BIAS2_LENGTH     = 16;
    localparam BIAS3_LENGTH     = 32;
    localparam CONV1OUT_LENGTH  = 32 * 32 * 32;
    localparam CONV2OUT_LENGTH  = 16 * 16 * 32;
    localparam CONV3OUT_LENGTH  = 8  * 8  * 32;
	localparam STRIDE           = 1;
	localparam PADDING          = 2;
	
	localparam [7:0] CONV_DIM_IMG = 32;
	localparam [7:0] CONV_DIM_OUT = 32;
	localparam [7:0] CONV_DIM_KERNEL = 5;
	localparam [7:0] CONV_DIM_CH     = 3;

    localparam period = 20;
    reg clk, reset;

    wire [7:0] i; //counter_convout;
	wire [7:0] j; //counter_img_dimX;
	wire [7:0] k; //counter_img_dimY;
	wire [7:0] m; //counter_kernel_dimX;
	wire [7:0] n; //counter_kernel_dimY;

    reg [7:0] mem_conv1   [0:CONV1_MEM_LENGTH];
	reg [7:0] mem_bias1   [0:BIAS1_LENGTH];
	reg [7:0] mem_convout [0:CONV1OUT_LENGTH];
	reg [7:0] mem_input   [0:3072];

	wire signed [16:0] convout;
	reg signed [16:0] bias_r;
	wire signed [7:0]  in_row, in_col;

    wire counterIis32;
	integer write_data;

    initial begin
        reset = 1'b1;
        #period;
        reset = 1'b0;
    end
    
	initial begin
		$readmemh("mem_files/conv_data.mem", mem_conv1);
		$readmemh("mem_files/img_data.mem", mem_input);
		$readmemh("mem_files/bias_data.mem", mem_bias1);
	end

	reg signed [19:0] temp;

    always begin
        clk = 1'b1;
        #period;
        clk = 1'b0;
        #period;
    end
	wire en_ctrl = (reset == 0) ? 1 : 0;
	wire save;
	wire [15:0] save_addr;
	wire [15:0] mem_conv_addr[0:CONV_DIM_CH-1];
	wire [15:0] mem_img_addr [0:CONV_DIM_CH-1];
	wire signed [18:0] buff  [0:CONV_DIM_CH-1];
	
	wire [7:0] ll [0:2];
	assign ll[0] = 0;
	assign ll[1] = 1;
	assign ll[2] = 2;

	reg enable_mult_add;
	//wire ex = !(en_ctrl && in_row >= 8'd0 && in_col >= 8'd0 && in_row < CONV_DIM_IMG && in_col < CONV_DIM_IMG);
	always @(posedge clk) begin
		if(en_ctrl && in_row >= 8'd0 && in_col >= 8'd0 && in_row < CONV_DIM_IMG && in_col < CONV_DIM_IMG) begin
			enable_mult_add <= 1;
		end else begin
			enable_mult_add <= 0;
		end
	end

	conv_control ctrl(clk, en_ctrl, reset, i, j, k, m, n, counterIis32, in_row, in_col);

	genvar l;
	generate
	for (l = 0; l < CONV_DIM_CH; l=l+1) begin
		addr_iter additer(clk, en_ctrl, i, j, k, m, n, ll[l], mem_img_addr[l], mem_conv_addr[l]);
	end
	endgenerate
	
	wire aclr;
	assign aclr = reset || (n == 4 && m == 0);
	genvar c;
	generate
		for(c = 0; c < CONV_DIM_CH; c=c+1) begin
				sig_altmult_accum mac(
					{mem_conv1[mem_conv_addr[c]][7], mem_conv1[mem_conv_addr[c]]}, 
					{1'b0, mem_input[mem_img_addr[c]]},
					clk,
					aclr,
					enable_mult_add,
					1'b0,
					buff[c]
				);
		end
	endgenerate

	always @(posedge clk) begin
		if(n == 3 && m == 0) begin
			temp <= buff[0] + buff[1] + buff[2];
		end else begin
			temp <= 0;
		end
	end

	assign convout = temp;

	always @(posedge clk) begin
		bias_r <= $signed(mem_bias1[i]) << 6;
	end

	assign save_addr = i + (((j * CONV_DIM_OUT) + k) * 32);

	always @(posedge clk) begin
		if(n == 4 && m == 0) begin
			if (((convout + bias_r) >>> 9) > 127) begin
				mem_convout[save_addr] <= 127;
			end else if(((convout + bias_r) >>> 9) < -128) begin
				mem_convout[save_addr] <= -128;
			end else begin
				mem_convout[save_addr] <= (convout + bias_r) >>> 9;
			end
		end
	end

endmodule