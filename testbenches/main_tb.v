`define INPUT1_LENGTH     32 * 32 * 32
`define IMG1_DATA          "C:/Users/gabri/Documents/Projetos/addr_read.mem"
`define INTRUCTIONS        "C:/Users/gabri/Documents/Projetos/commands_read.mem"

`timescale 1 ps / 1 ps
module main_tb;

    reg clk, reset, clock, sclk, mosi, nss;
    wire miso;

    localparam CLK_PERIOD = 20;
    localparam period2 = 88;
    always #(CLK_PERIOD/2) clk=~clk;
    always #(88/2) sclk=~sclk;

    task run_clock;
    begin
        #(CLK_PERIOD/2) clock = ~clock;
        #(CLK_PERIOD/2) clock = ~clock; 
    end
    endtask
	 
	task run_clock2;
    begin
        #(period2/2) clock = ~clock;
        #(period2/2) clock = ~clock; 
    end
    endtask

	/*ram #(
        .MEM_LENGTH(`INPUT1_LENGTH),
        .MEM_INIT_FILE(`INTRUCTIONS)
	) input_instruction (
        .clk(clk),
        .read_address(),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(inst)
    );

	ram #(
        .MEM_LENGTH(`INPUT1_LENGTH),
        .MEM_INIT_FILE(`IMG1_DATA)
    ) input_mem (
        .clk(clk),
        .read_address(pc_addr),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(signal)
    );*/
	
    initial begin
		#1 clk <= 0; clock <= 0; reset <= 0; sclk <= 0;
		run_clock2;
		reset = 1;
		run_clock2;
		reset = 0;
		run_clock2;
		nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;

		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		run_clock2;
		
		nss = 0;
		#44 mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 0;
		run_clock2;
		mosi = 1;
		#44 nss = 1;
		run_clock2;
		
		nss = 0;
		#44 mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		run_clock2;
		mosi = 1;
		#44 nss = 1;

		//$stop;
    end

	wire convout;
	always @(posedge clk ) begin
		if(convout) begin
			$stop;
		end
	end

    archlearn main(clk, mosi, miso, nss, sclk, reset, convout);
    

endmodule