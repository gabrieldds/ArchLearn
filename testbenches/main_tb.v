`define INPUT1_LENGTH     32 * 32 * 32
`define IMG1_DATA          "C:/Users/gabri/Documents/Projetos/addr_read.mem"
`define INTRUCTIONS        "C:/Users/gabri/Documents/Projetos/commands_read.mem"

`timescale 1 ns / 1 ns
module main_tb;

    reg clk, reset, clock, sclk, mosi, nss;
    wire miso;

    localparam CLK_PERIOD = 20;
    localparam period2 = 100;
    always #(CLK_PERIOD/2) clk=~clk;
    always #(period2/2) sclk=~sclk;

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
	
    initial begin
		#1 clk <= 0; clock <= 0; reset <= 0; sclk <= 0; nss <= 1;
		run_clock2;
		reset <= 1;
		run_clock2;
		run_clock2;
		reset <= 0;
		run_clock2;
		run_clock2;
		nss = 0;
		#50 mosi = 0;
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
		mosi = 0;
		#50 nss = 1;
		run_clock2;
		
		nss = 0;
		#50 mosi = 1;
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
		#50 nss = 1;
    end

	wire convout;
	always @(posedge clk ) begin
		if(convout == 1'b1) begin
			$stop;
		end
	end

	wire [0:6] hex0, hex4, hex5, hex6, hex7;
	wire [17:0] ledr;
	wire [6:0] ledg;

    archlearn main(clk, mosi, miso, nss, sclk, reset, hex0, hex4, hex5, hex6, hex7, ledr, ledg, convout);
    

endmodule