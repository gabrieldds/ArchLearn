`define INPUT1_LENGTH     32 * 32 * 3
`define IMG1_DATA          "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/debug_input1.mem"

module controller_tb;

    reg clk, reset, clock, stvalid;
    reg signal, convin;
    wire [15:0] s_addr;
    reg [7:0] stsourcedata;

    localparam CLK_PERIOD = 20;
    always #(CLK_PERIOD/2) clk=~clk;

    task run_clock;
    begin
        #(CLK_PERIOD/2) clock = ~clock;
        #(CLK_PERIOD/2) clock = ~clock; 
    end
    endtask

    initial begin
        #1 clk <= 0; clock <= 0; reset <= 0;
        run_clock;
        run_clock;
        reset <= 1;
        run_clock;
        reset <= 0;
        run_clock;
        run_clock;
        stsourcedata <= 8'h11;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        stsourcedata <= 8'hff;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        stsourcedata <= 8'h21;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        stsourcedata <= 0;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        stsourcedata <= 8'h0;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        stsourcedata <= 8'h30;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        run_clock;
        run_clock;
        run_clock;
        convin <= 1;
        run_clock;
        run_clock;
        run_clock;
        run_clock;
        stsourcedata <= 8'h11;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        stsourcedata <= 8'h21;
        run_clock;
        stvalid <= 1;
        run_clock;
        run_clock;
        stvalid <= 0;
        run_clock;
        run_clock;
        run_clock;
    end

    wire [7:0] sink_data, q, data_out;
    wire [15:0] addr;
    wire [3:0] en_wmem;
    wire en_rmem;
    wire [2:0] en_conv;

    controller arch_control(
		.clk(clk),
		.reset(reset),
		.stvalid(stvalid),
		.stsinkdata(stsourcedata),
		.stsourcedata(sink_data),
		.data_in(q),
		.data_out(data_out),
		.convin(convin),
		.addr(addr),
		.en_wmem(en_wmem),
		.en_rmem(en_rmem),
		.en_conv(en_conv)
	);

    ram #(
        .MEM_LENGTH(`INPUT1_LENGTH),
        .MEM_INIT_FILE("")
    ) input_mem (
        .clk(clk),
        .address(addr),
        .data_in(data_out),
        .write_enable(en_wmem[0]),
        .read_enable(en_rmem),
        .data_out(q)
    );
endmodule
