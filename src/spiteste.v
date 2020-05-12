`include "parameters.v"


//`define DATA               "C:/Users/gabri/Documents/Projetos/ArchLearn/simulation/result_conv1.txt"
`define DATA2              "C:/Users/gabri/Documents/Projetos/ArchLearn/simulation/result_conv2.txt"
`define DATA3              "C:/Users/gabri/Documents/Projetos/ArchLearn/simulation/result_conv3.txt"
`define IMG1_DATA          "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/debug_input1.mem"
`define CONV1_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv1_wt.mem"
`define BIAS1_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv1_bias.mem"

module spiteste(
    clk50,
    mosi,
    miso, 
    nss,
    sclk,
    reset,
	hex0,
	hex4,
	hex5,
	hex6,
	hex7,
	ledr,
	ledg,
	conv_end
);
	input clk50;
	input mosi;
	inout miso;
	input nss;
	input sclk;
	input reset;
	output [0:6] hex0, hex4, hex5, hex6, hex7;
	output [17:0] ledr;
	output [6:0] ledg;
	output conv_end;
	
	
	wire [3:0] state_debug;
	/*wire [7:0] stsourcedata;
	reg  [7:0] stsinkdata;
	reg  stsinkvalid;
	reg  stsourceready;
	wire stsourcevalid;
	wire stsinkready;*/
	
	wire [7:0] stsourcedata;
	wire [7:0] stsinkdata;
	wire stsinkvalid;
	wire stsourceready;
	wire stsourcevalid;
	wire stsinkready;
    
	spi spi4(
		.sysclk(clk50),
		.nreset(~reset),
		.mosi(mosi),
		.nss(nss),
		.miso(miso),
		.sclk(sclk),
		.stsourceready (stsourceready), // avalon_streaming_source.ready
		.stsourcevalid (stsourcevalid), //                        .valid
		.stsourcedata  (stsourcedata),  //                        .data out
		.stsinkvalid   (stsinkvalid),   //   avalon_streaming_sink.valid out
		.stsinkdata    (stsinkdata),    //                        .data
		.stsinkready   (stsinkready)    //                        .ready out
	);

	/*always @(posedge clk50) begin
		if (reset) begin
			stsinkdata    <= 8'b0;
			stsinkvalid   <= 1'b0;
			stsourceready <= 1'b0; 
		end else begin
			stsinkvalid  <= stsourcevalid;
			stsinkdata   <= stsourcedata;
			stsourceready <= stsinkready;
		end
	end*/
	
	wire [7:0] data_out;
	wire [7:0] data_in, data_in1, data_in2, data_in3;
	wire [2:0] convin_r;
	wire [15:0] addr;
	wire [8:0] en_wmem;
	wire [2:0] en_conv;
	wire [2:0] en_rmem;
	wire [2:0] convin;
	
	assign data_in = (en_rmem == 3'b001) ? data_in1 : 
						  (en_rmem == 3'b010) ? data_in2 : 
						  (en_rmem == 3'b100) ? data_in3 : 8'h4a;
	
	
	assign convin = convin_r & en_conv;
	assign conv_end = (convin > 3'b0) ? 1'b1 : 1'b0;
	assign ledr[8:0] = en_wmem;
	assign ledr[11:9] = convin_r;
	assign ledr[17:12] = 6'b0;
	assign ledg[2:0] = en_rmem;
	assign ledg[6:4] = en_conv;
	assign ledg[3] = 1'b0;
	
	convert h0(clk50, state_debug, hex0);
	convert h4(clk50, data_in[3:0], hex4);
	convert h5(clk50, data_in[7:4], hex5);
	convert h6(clk50, data_out[3:0], hex6);
	convert h7(clk50, data_out[7:4], hex7);
	

	controller arch_control(
		.clk(clk50),
		.reset(reset),
		.stsinkvalid(stsourcevalid),
        .stsinkready(stsourceready),
		.stsinkdata(stsourcedata),
        .stsourceready(stsinkready),
		.stsourcedata(stsinkdata),
        .stsourcevalid(stsinkvalid),
		.data_in(data_in),
		.data_out(data_out),
		.convin(conv_end),
		.addr(addr),
		.en_wmem(en_wmem),
		.en_rmem(en_rmem),
		.en_conv(en_conv),
        .state_out(state_debug)
	);
	
	wire [15:0] s_addr;
	wire [15:0] w_addr;
	wire [15:0] b_addr;
	wire [15:0] save_addr;
	wire  [7:0] bias;
	wire  [7:0] signal;
	wire  [7:0] weight;
	wire signed [7:0] convout;
	wire s_convout;
	wire en_save;
	wire sload;
	wire en_sum;
	wire en_write;
	wire en_mac;
	wire en_sat;
	wire en_mult_r;
	
	conv_ctrl groundctrl (
		.clk(clk50), 
		.reset(reset), 
		.en_ctrl(en_conv[0]), 
		.s_addr(s_addr), 
		.w_addr(w_addr), 
		.b_addr(b_addr), 
		.save_addr(save_addr), 
		.en_sum(en_sum), 
		.en_save(en_save),  
		.en_write(en_write), 
		.s_convout(s_convout), 
		.en_sat(en_sat), 
		.en_mac(en_mac), 
		.en_mult_r(en_mult_r), 
		.finish(convin_r[0])
	);

    convolve conv (
		.clk(clk50), 
		.reset(reset), 
		.clken(en_mac), 
		.s_convout(en_write), 
		.en_sat(en_sat), 
		.en_mult_r(en_mult_r), 
		.bias(bias), 
		.signal(signal), 
		.weight(weight), 
		.convout(convout)
	);
	
	ram #(
        .MEM_LENGTH(`INPUT1_LENGTH),
        .MEM_INIT_FILE(`IMG1_DATA)
    ) input_mem (
        .clk(clk50),
        .read_address(s_addr),
        .write_address(addr),
        .data_in(data_out),
        .write_enable(en_wmem[0]),
        .data_out(signal)
    );
	 
	 ram #(
        .MEM_LENGTH(`CONV1_MEM_LENGTH),
        .MEM_INIT_FILE(`CONV1_DATA)
    ) conv1_in_mem (
        .clk(clk50),
        .read_address(w_addr),
        .write_address(addr),
        .data_in(data_out),
        .write_enable(en_wmem[3]),
        .data_out(weight)
    );
	 
	 ram #(
        .MEM_LENGTH(`BIAS1_LENGTH),
        .MEM_INIT_FILE(`BIAS1_DATA)
    ) bias_in_mem (
        .clk(clk50),
        .read_address(b_addr),
        .write_address(addr),
        .data_in(data_out),
        .write_enable(en_wmem[6]),
        .data_out(bias)
    );
	
	ram #(
      .MEM_LENGTH(`CONV1OUT_LENGTH),
      .MEM_INIT_FILE()
    ) conv1_out_mem (
      .clk(clk50),
	  .read_address(addr),
      .write_address(save_addr),
      .data_in(convout),
      .write_enable(en_write),
      .data_out(data_in1)
    );
	 
	  ram #(
      .MEM_LENGTH(`CONV2OUT_LENGTH),
	  .MEM_INIT_FILE(`DATA2)
    ) conv1_out_mem2 (
      .clk(clk50),
	  .read_address(addr),
      .write_address(),
      .data_in(),
      .write_enable(),
      .data_out(data_in2)
    );

    ram #(
      .MEM_LENGTH(`CONV3OUT_LENGTH),
	  .MEM_INIT_FILE(`DATA3)
    ) conv1_out_mem3 (
      .clk(clk50),
	  .read_address(addr),
      .write_address(),
      .data_in(),
      .write_enable(),
      .data_out(data_in3)
    );

endmodule

	