`include "parameters.v"
/*******************************************************************
*Module name:  archlearn
*Date Created: 05/08/2019
*Last Modified: 27/09/2019
*Description: Main module to cnn acceleration.
********************************************************************/
module archlearn(
    clk,
    mosi,
    miso,
    nss,
    sclk,
    reset
);

	localparam [`BYTE-1:0] STRIDE           = 1;
	localparam [`BYTE-1:0] PADDING          = 2;

	localparam [`BYTE-1:0] CONV1_DIM_IMG    = 32;
	localparam [`BYTE-1:0] CONV1_DIM_CH     = 3;
	localparam [`BYTE-1:0] CONV1_DIM_KERNEL = 5;
	localparam [`BYTE-1:0] CONV1_DIM_OUT    = 32;
	localparam [`BYTE-1:0] CONV1_OUT_CH     = 32;

	localparam [`BYTE-1:0] CONV2_DIM_IMG    = 16;
	localparam [`BYTE-1:0] CONV2_DIM_CH     = 32;
	localparam [`BYTE-1:0] CONV2_DIM_KERNEL = 5;
	localparam [`BYTE-1:0] CONV2_DIM_OUT    = 16;
	localparam [`BYTE-1:0] CONV2_OUT_CH     = 16;

	localparam [`BYTE-1:0] CONV3_DIM_IMG    = 8;
	localparam [`BYTE-1:0] CONV3_DIM_CH     = 16;
	localparam [`BYTE-1:0] CONV3_DIM_KERNEL = 5;
	localparam [`BYTE-1:0] CONV3_DIM_OUT    = 8;
	localparam [`BYTE-1:0] CONV3_OUT_CH     = 32;

	input clk;
	input mosi;
	inout miso;
	input nss;
	input sclk;
	input reset;
	
	reg [`BYTE-1:0] mem_conv1   [0:`CONV1_MEM_LENGTH-1];
	reg [`BYTE-1:0] mem_conv2   [0:`CONV2_MEM_LENGTH-1];
	reg [`BYTE-1:0] mem_conv3   [0:`CONV3_MEM_LENGTH-1];
	reg [`BYTE-1:0] mem_bias1   [0:`BIAS1_LENGTH-1];
	reg [`BYTE-1:0] mem_bias2   [0:`BIAS2_LENGTH-1];
	reg [`BYTE-1:0] mem_bias3   [0:`BIAS3_LENGTH-1];
	reg [`BYTE-1:0] mem_convout [0:`CONV1OUT_LENGTH-1];
	reg [`BYTE-1:0] mem_input   [0:`CONV2OUT_LENGTH-1];

	reg [`BYTE-1:0] source_data;
	reg [`BYTE-1:0] sink_data;
	reg sink_valid;
	reg source_ready;

	wire source_valid;
	wire sink_ready;
	wire clk_spi;
	wire clk_conv;
	wire nreset;
	
	assign nreset = reset;
	
	pll clk0(clk, clk_conv, clk_spi);

	spi spi4(
		.sysclk(clk_spi),
		.nreset(nreset),
		.mosi(mosi),
		.nss(nss),
		.miso(miso),
		.sclk(sclk),
		.stsourceready (source_ready), // avalon_streaming_source.ready
		.stsourcevalid (source_valid), //                        .valid
		.stsourcedata  (source_data),  //                        .data out
		.stsinkvalid   (sink_valid),   //   avalon_streaming_sink.valid out
		.stsinkdata    (sink_data),    //                        .data
		.stsinkready   (sink_ready)    //                        .ready out
	);

	reg signed [`WORD-1:0] temp, temp2, temp3;
	
	always@(posedge clk_spi)
	begin
		if(reset) begin
			temp <= 0;
			temp2 <= 0;
			temp3 <= 0;
		end
		//sink_data <= source_data;	
		source_ready <= sink_ready;
		//sink_valid <= enable_sink;
		//sink_data <= mem_convout[wTM];
		//sink_valid <= source_valid;
	end

	wire [`CTRL_SIZE-1:0] en_ctrl;
	wire [15:0] w_addr;
	wire [2:0] convin;
	wire [`BYTE-1:0] data_out;

    controller control(
		.clk(clk_spi),
		.reset(reset),
		.valid(source_valid),
		.data_in(source_data),
		.data_out(data_out),
		.convin(convin),
		.en_ctrl(en_ctrl),
		.address_written(w_addr)
    );

	always @(posedge clk_spi) begin
		if(en_ctrl[0]) begin
			mem_conv1[w_addr] <= data_out;
		end else if(en_ctrl[1]) begin
			mem_bias1[w_addr] <= data_out;
		end else if(en_ctrl[2]) begin
			mem_conv2[w_addr] <= data_out;
		end else if(en_ctrl[3]) begin
			mem_bias2[w_addr] <= data_out;
		end else if(en_ctrl[4]) begin
			mem_conv3[w_addr] <= data_out;
		end else if(en_ctrl[5]) begin
			mem_bias3[w_addr] <= data_out;
		end else if(en_ctrl[6]) begin
			mem_input[w_addr] <= data_out;
		end
	end

	/**************************Convolution*************************************/

	wire [`BYTE-1:0] i, i2, i3; //counter_convout;
	wire [`BYTE-1:0] j, j2, j3; //counter_img_dimX;
	wire [`BYTE-1:0] k, k2, k3; //counter_img_dimY;
	wire [`BYTE-1:0] m, m2, m3; //counter_kernel_dimX;
	wire [`BYTE-1:0] n, n2, n3; //counter_kernel_dimY;

	wire signed [`WORD-1:0] convout, convout2, convout3;
	reg signed [`HALF_WORD-1:0] bias_r, bias_r2, bias_r3;
	wire signed [`BYTE-1:0] in_row, in_row2, in_row3;
	wire signed [`BYTE-1:0] in_col, in_col2, in_col3;

	reg [15:0] mem_conv1_addr[0:CONV1_DIM_CH-1];
	reg [15:0] mem_conv2_addr[0:CONV2_DIM_CH-1];
	reg [15:0] mem_conv3_addr[0:CONV3_DIM_CH-1];

	reg [15:0] mem_img1_addr [0:CONV1_DIM_CH-1];
	reg [15:0] mem_img2_addr [0:CONV2_DIM_CH-1];
	reg [15:0] mem_img3_addr [0:CONV3_DIM_CH-1];

	wire [15:0] save_addr;
	/********** CONV1 *********************/
	conv_control#(
		.CONV_IM_DIM(CONV1_DIM_IMG),
		.CONV_DIM_KERNEL(CONV1_DIM_KERNEL),
		.CONV_DIM_OUT(CONV1_DIM_OUT),
		.CONV_OUT_CH(CONV1_OUT_CH),
		.STRIDE(STRIDE),
		.PADDING(PADDING)	
	) ctrl_c1 (
		clk, 
		en_ctrl[7], 
		reset, 
		i, 
		j, 
		k, 
		m, 
		n, 
		convin[0], 
		in_row, 
		in_col
	);

	/*always @(en_ctrl[7],n,m,temp) begin
		if(en_ctrl[7] && n == 0 && m == 0) begin
			temp = 0;
		end
	end*/
	
	always @(en_ctrl[7], k, bias_r) begin
		if(en_ctrl[7] && k >= 0 && k < CONV1_DIM_IMG) begin
			bias_r = $signed(mem_bias1[i]) << 6;
		end
	end

	integer c, l;
	always @(i, j, k, m, n) begin
        for (l = 0; l < CONV1_DIM_CH; l=l+1) begin
			if(en_ctrl[7]) begin
				mem_img1_addr[l] = (((((STRIDE * j) + m - PADDING) * CONV1_DIM_IMG) + ((STRIDE * k) + n - PADDING)) * CONV1_DIM_CH) + l;
				mem_conv1_addr[l] = (i * CONV1_DIM_CH * CONV1_DIM_KERNEL * CONV1_DIM_KERNEL) + (((m * CONV1_DIM_KERNEL) + (n)) * CONV1_DIM_CH) + l;
			end
		end
    end

	always @(en_ctrl[7], in_row, in_col, temp) begin
		for(c = 0; c < CONV1_DIM_CH; c=c+1) begin
			if(en_ctrl[7] && in_row >= 8'd0 && in_col >= 8'd0 && in_row < CONV1_DIM_IMG && in_col < CONV1_DIM_IMG) begin
				temp = temp + ($signed(mem_conv1[mem_conv1_addr[c]]) * $signed({1'b0, mem_input[mem_img1_addr[c]]}));
			end
		end
	end

	assign convout = temp;

	always @(posedge clk) begin
		if(en_ctrl[7] && n == 4 && m == 4) begin
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