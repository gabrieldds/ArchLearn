/*******************************************************************
*Module name:  archlearn
*Date Created: 05/08/2019
*Last Modified: 05/08/2019
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
	
	localparam [7:0] CONV1_DIM_IMG = 32;
	localparam [7:0] CONV1_DIM_OUT = 32;
	localparam [7:0] CONV1_DIM_KERNEL = 5;
	localparam [7:0] CONV1_DIM_CH     = 3;

	input clk;
	input mosi;
	inout miso;
	input nss;
	input sclk;
	input reset;
	
	reg [7:0] mem_conv1   [0:CONV1_MEM_LENGTH];
	reg [7:0] mem_conv2   [0:CONV2_MEM_LENGTH];
	reg [7:0] mem_conv3   [0:CONV3_MEM_LENGTH];
	reg [7:0] mem_bias1   [0:BIAS1_LENGTH];
	reg [7:0] mem_bias2   [0:BIAS2_LENGTH];
	reg [7:0] mem_bias3   [0:BIAS3_LENGTH];
	reg [7:0] mem_convout [0:CONV1OUT_LENGTH];
	reg [7:0] mem_input   [0:3072];

	reg [7:0] source_data;
	reg [7:0] sink_data;
	reg sink_valid;
	reg source_ready;

	wire source_valid;
	wire sink_ready;
	wire clk_spi;
	wire clk_conv;
	wire nreset;
	
	assign nreset = reset;
	
	pll clk0(clk, clk_spi);
	pll clk1(clk, clk, clk_conv);

	spi_slave spi4(
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
	
	always@(posedge clk_spi)
	begin
		//sink_data <= source_data;
		led <= source_data;		
		source_ready <= sink_ready;
		sink_valid <= enable_sink;
		sink_data <= mem_convout[wTM];
		//sink_valid <= source_valid;
	end

	wire [10:0] en_ctrl;
	wire w_finished;
	wire r_finished;
	wire [15:0] counter_mem;
	wire [2:0] convin;

    controller control(
		.clk(clk_spi),
		.reset(reset),
		.convin(convin),
		.en_ctrl(en_ctrl),
		.address_written(counter_mem)
    );
	/**************************Convolution*************************************/

	reg [7:0] i //counter_convout;
	reg [7:0] j //counter_img_dimX;
	reg [7:0] k //counter_img_dimY;
	reg [7:0] l //counter_img_ch;
	reg [7:0] m //counter_kernel_dimX;
	reg [7:0] n //counter_kernel_dimY;

	signed [15:0] reg convout;
	signed [15:0] reg bias_r;
	signed [7:0]  reg in_row, in_col;

	reg enable_counter_imgJ;
	reg enable_counter_imgK;
	reg enable_counter_img_ch;
	reg enable_counter_kernel_dimN;
	reg enable_counter_kernel_dimY;
	reg enable_counter_convout;

	wire counterLis3;
	wire counterNis5;
	wire counterMis5;
	wire counterKis32;
	wire counterJis32;
	wire counterIis32;

	assign enable_counter_img_ch = in_row >= 8'd0 && in_col >= 8'd0 && in_rol < CONV1_DIM_IMG && in_col < CONV1_DIM_IMG;
	assign enable_counter_kernel_dimN = (~en_ctrl[8] & counterLis3) | (~enable_counter_img_ch & en_ctrl[8]);
	assign enable_counter_kernel_dimM = en_ctrl[8] & counterNis5;
	assign enable_counter_imgK = en_ctrl[8] & counterMis5;
	assign enable_counter_imgJ = en_ctrl[8] & counterKis32;
	assign enable_counter_convout = en_ctrl[8] & counterJis32;

	assign counterLis3  = (l == CONV1_DIM_CH) ? 1 : 0;
	assign counterNis5  = (n == CONV1_DIM_KERNEL) ? 1 : 0;
	assign counterMis5  = (m == CONV1_DIM_KERNEL) ? 1 : 0;
	assign counterKis32 = (k == CONV1_DIM_IMG) ? 1 : 0;
	assign counterJis32 = (j == CONV1_DIM_IMG) ? 1 : 0;
	assign counterIis32 = (i == CONV1_DIM_OUT) ? 1 : 0; 

	counter#(
		.COUNTER_WIDTH(8),
		.COUNTER_RESET_VALUE(CONV1_DIM_CH)
	) forL (
		.clk(clk_conv),
		.reset(reset),
		.enable(en_ctrl[8] && enable_counter_img_ch),
		.counter(l)
	);

	counter#(
		.COUNTER_WIDTH(8),
		.COUNTER_RESET_VALUE(CONV1_DIM_KERNEL)
	) forN (
		.clk(clk_conv),
		.reset(reset),
		.enable(enable_counter_kernel_dimN),
		.counter(n)
	);

	counter#(
		.COUNTER_WIDTH(8),
		.COUNTER_RESET_VALUE(CONV1_DIM_KERNEL)
	) forM (
		.clk(clk_conv),
		.reset(reset),
		.enable(enable_counter_kernel_dimM),
		.counter(m)
	);

	counter#(
		.COUNTER_WIDTH(8),
		.COUNTER_RESET_VALUE(CONV1_DIM_IMG)
	) forK (
		.clk(clk_conv),
		.reset(reset),
		.enable(enable_counter_imgK),
		.counter(k)
	);

	counter#(
		.COUNTER_WIDTH(8),
		.COUNTER_RESET_VALUE(CONV1_DIM_IMG)
	) forJ (
		.clk(clk_conv),
		.reset(reset),
		.enable(enable_counter_imgJ),
		.counter(j)
	);

	counter#(
		.COUNTER_WIDTH(8),
		.COUNTER_RESET_VALUE(CONV1_DIM_OUT)
	) forI (
		.clk(clk_conv),
		.reset(reset),
		.enable(enable_counter_convout),
		.counter(i)
	);


	always @(posedge clk_conv) begin
		if(en_ctrl[8] && enable_counter_img_ch) begin
			convout <= convout + mem_input[(in_row * CONV1_DIM_IMG + in_col) * CONV1_DIM_CH + l] * mem_conv1[i * 
			CONV1_DIM_CH * CONV1_DIM_KERNEL * CONV1_DIM_KERNEL + (m * CONV1_DIM_KERNEL + n) * CONV1_DIM_CH + l];
		end
	end

	always @(posedge clk_conv) begin
		if(k == 0 || enable_counter_imgK) begin
			bias_r <= mem_bias1[i] >> 6 + 9;
		end
	end

	always @(posedge clk_conv) begin
		if(n == 0 || enable_counter_kernel_dimN) begin
			in_row <= STRIDE * j + m - PADDING;
            in_col <= STRIDE * k + n - PADDING;
		end
	end

	always @(posedge clk_conv) begin
		if(counterMis5) begin
			mem_convout[i + (j * CONV1_DIM_IMG + k) * CONV1_DIM_OUT] <= convout;
		end
	end

	assign convin = (counterIis32) ? 3'b001 : 3'b000;

	wire [7:0] i_backup;
	assign i_backup  = (counterIis32) ? i : 0;
	wire enable_read = (i_backup == CONV1_DIM_OUT) ? 1 : 0;

	wire [11:0] wTM;

	counter#(
		.COUNTER_WIDTH(12),
		.COUNTER_RESET_VALUE(CONV1OUT_LENGTH)
	) writeToMicrocontroller (
		.clk(clk_conv),
		.reset(reset),
		.enable(enable_read),
		.counter(wTM)
	);

	wire enable_sink = (wTM == CONV1OUT_LENGTH) ? 0 : 1;
	assign i_backup (enable_sink) ? 0 : i_backup;

endmodule