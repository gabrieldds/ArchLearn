/*******************************************************************
*Module name:  controller
*Date Created: 03/08/2019
*Last Modified: 03/08/2019
*Description: This is memory and operation controller of convolution.
********************************************************************/
module controller(
    /*input clk signal*/
    clk,            /*clock signal*/
    /*input reset signal*/ 
    reset,         /*reset signal*/
    /*input data*/
    stvalid,
    stsinkdata,
    stsourcedata,
    data_in,      /*byte input*/
    data_out,
    /*input signal to disable conv*/
    convin, 
    addr,
    //raddr,
    en_wmem,
    en_rmem,
    en_conv,
);
    /*declare parameters*/
    localparam MSB_BYTE = 8;
    localparam MSB_HALF_WORD = 16;
    localparam FSM_TAM = 3;
    /*FSM parameters*/
    localparam IDLE           = 3'b000;
	 localparam WAITDEASSERT   = 3'b001;
    localparam WRITE          = 3'b010;
    localparam READ           = 3'b011;
    localparam CONV           = 3'b100;
    localparam WAIT2IDLE      = 3'b101;
	 localparam WAITC          = 3'b110;
    /*declare input, output paremeters*/
    input clk;
    input reset;
    input [7:0] data_in, stsinkdata;
    input stvalid;
    input convin;
    output reg [7:0] data_out, stsourcedata;
    //output reg [15:0] raddr;
    output reg [15:0] addr;
    output reg [2:0]  en_wmem;
    output reg  en_rmem;
    output reg [2:0]  en_conv; 
    /***********************internal registers***********************/
	 reg [15:0] waddr1, waddr2, waddr3;
    reg [FSM_TAM-1:0] state, nextstate;
    reg [2:0] wen;
    reg ren;
    reg [2:0] conven;
	 reg read;
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
				nextstate <= IDLE;
                data_out <= 8'b0;
            //raddr <= 16'b0;
				waddr1 <= 16'b0;
				waddr2 <= 16'b0;
				waddr3 <= 16'b0;
                addr <= 16'b0;
                wen <= 4'b0;
                ren <= 4'b0;
                en_wmem <= 4'b0;
                en_rmem <= 4'b0;
                en_conv <= 3'b0;
                stsourcedata <= 8'b0;
				read <= 1'b0;
        end else begin
            case (state)
                IDLE: begin 
                    if(stvalid) begin
                        case(stsinkdata[7:4])
                            4'h1: begin
                                state <= WAITDEASSERT;
										  nextstate <= WRITE;
                                wen  <= stsinkdata[3:0];
										  en_rmem <= 1'b0;
                            end
                            4'h2: begin
                                state <= WAITDEASSERT;
										  nextstate <= READ;
                                ren     <= stsinkdata[3:0];
										  en_wmem <= 3'b0;
										  read  <= 1'b0; 
                            end
                            4'h3: begin
                                state  <= CONV;
                                conven <= stsinkdata[2:0];
                            end
                        endcase
                    end
                    else begin
                        state <= IDLE;
                    end
                end
					 WAITDEASSERT: begin
						if(!stvalid) begin
							state <= nextstate;
						end else begin
							state <= WAITDEASSERT;
						end
					 end
                WRITE: begin
                    if (stvalid) begin
                        state <= WAIT2IDLE;
								nextstate <= IDLE;
                        data_out <= stsinkdata;
                        en_wmem <= wen;
								if(wen == 3'b0001) begin
									waddr1 <= waddr1 + 1;
									addr <= waddr1;
								end else if(wen == 3'b0010) begin
									waddr2 <= waddr2 + 1;
									addr <= waddr2;
								end else if(wen == 3'b0100) begin
									waddr3 <= waddr3 + 1;
									addr <= waddr3;
								end
                    end else begin
                        state <= WRITE;
                    end
                end
                READ: begin
                    if (stvalid) begin
                        state <= WAIT2IDLE;
								nextstate <= IDLE;
                        addr <= stsinkdata;
                        en_rmem <= ren;
								read <= 1'b1;
                    end else begin
                        state <= READ;
                    end
                end
					 WAIT2IDLE: begin
					     if (!stvalid) begin
                        state <= nextstate;
								if(read) begin
								    stsourcedata <= data_in;
								end
						  end else begin
						      state <= WAIT2IDLE;
						  end
					 end
                CONV: begin
                    en_conv <= conven;
                    state   <= WAITC;
                end
                WAITC: begin
                    if (convin) begin
                        state    <= IDLE;
                        stsourcedata <= 8'hfe;
                    end else begin
                        state <= WAITC;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule