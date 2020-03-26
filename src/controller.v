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
    stsinkvalid,
    stsinkready,
    stsinkdata,
    stsourceready,
    stsourcevalid,
    stsourcedata,
    data_in,      /*byte input*/
    data_out,
    /*input signal to disable conv*/
    convin,
    addr,
    en_wmem,
    en_rmem,
    en_conv
);
    /*declare parameters*/
    localparam MSB_BYTE = 8;
    localparam MSB_HALF_WORD = 16;
    localparam FSM_TAM = 4;
    /*FSM parameters*/
    localparam IDLE           = 4'b0000;
    localparam WAITDEASSERT   = 4'b0001;
    localparam WAITDEASSERT2  = 4'b0100;
    localparam WAITDEASSERT3  = 4'b1001;
    localparam WRITE          = 4'b0010;
    localparam READ           = 4'b0011;
    localparam CONV           = 4'b0101;
    localparam WAIT2IDLE      = 4'b0110;
    localparam WAITC          = 4'b0111;
    localparam WAITREADY      = 4'b1000;
    /*declare input, output paremeters*/
    input clk;
    input reset;
    input [7:0] data_in, stsinkdata;
    input stsinkvalid, stsourceready;
    input [2:0] convin;
    output reg stsinkready;
    output reg stsourcevalid;
    output reg [7:0] data_out, stsourcedata;
    output reg [15:0] addr;
    output reg [8:0]  en_wmem;
    output reg [2:0]  en_rmem;
    output reg [2:0]  en_conv; 
    /***********************internal registers***********************/
    reg [15:0] waddr1, waddr2, waddr3, waddr4, waddr5, waddr6, waddr7, waddr8, waddr9;
    reg [15:0] raddr1, raddr2, raddr3;
    reg [FSM_TAM-1:0] state;
    reg [3:0] wen;
    reg [2:0] ren;
    reg [2:0] conven;
    reg read;

    always @(posedge clk) begin
        stsinkready <= stsourceready;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            data_out <= 8'b0;
			waddr1 <= 16'b0;
			waddr2 <= 16'b0;
			waddr3 <= 16'b0;
            waddr4 <= 16'b0;
            waddr5 <= 16'b0;
            waddr6 <= 16'b0;
            waddr7 <= 16'b0;
            waddr8 <= 16'b0;
            waddr9 <= 16'b0;
            raddr1 <= 16'b0;
            raddr2 <= 16'b0;
            raddr3 <= 16'b0;
            addr <= 16'b0;
            wen <= 4'b0;
            ren <= 3'b0;
            conven <= 3'b0;
            en_wmem <= 9'b0;
            en_rmem <= 3'b0;
            en_conv <= 3'b0;
            stsourcedata  <= 8'b0;
            stsourcevalid <= 1'b0;
			read <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
					en_rmem <= 3'b0;
                    en_wmem <= 9'b0;
                    addr <= 16'b0;
                    read <= 1'b0;
					stsourcevalid <= 1'b0;
                    /*if(read) begin
                        read <= 1'b0;
					    stsourcevalid <= 1'b1;
                    end */
                    if(stsinkvalid) begin
                        case(stsinkdata[7:4])
                            4'h1: begin
                                state <= WAITDEASSERT;
                                wen  <= stsinkdata[3:0];
                            end
                            4'h2: begin
                                state <= WAITDEASSERT2;
                                ren <= stsinkdata[2:0];
                            end
                            4'h3: begin
                                state  <= WAITDEASSERT3;
                                conven <= stsinkdata[2:0];
                            end
                        endcase
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                WAITDEASSERT: begin
                    if(!stsinkvalid) begin
                        state <= WRITE;
                    end else begin
                        state <= WAITDEASSERT;
                    end
                end
                WAITDEASSERT2: begin
                    if(!stsinkvalid) begin
                        state <= READ;
                    end else begin
                        state <= WAITDEASSERT2;
                    end
                end
                WAITDEASSERT3: begin
                    if(!stsinkvalid) begin
                        state <= CONV;
                    end else begin
                        state <= WAITDEASSERT3;
                    end
                end
                WRITE: begin
                    if (stsinkvalid) begin
                        state <= WAIT2IDLE;
                        data_out <= stsinkdata;
                        if(wen == 4'b0000) begin
                            en_wmem[0] <= 1'b1; 
                            waddr1 <= waddr1 + 16'b1;
                            addr <= waddr1;
                        end else if(wen == 4'b0001) begin
                            en_wmem[1] <= 1'b1;
                            waddr2 <= waddr2 + 16'b1;
                            addr <= waddr2;
                        end else if(wen == 4'b0010) begin
                            en_wmem[2] <= 1'b1;
                            waddr3 <= waddr3 + 1'b1;
                            addr <= waddr3;
                        end else if(wen == 4'b0011) begin
                            en_wmem[3] <= 1'b1;
                            waddr4 <= waddr4 + 1'b1;
                            addr   <= waddr4;
                        end else if(wen == 4'b0100) begin
                            en_wmem[4] <= 1'b1;
                            waddr5 <= waddr5 + 1'b1;
                            addr <= waddr5;
                        end else if(wen == 4'b0101) begin
                            en_wmem[5] <= 1'b1;
                            waddr6 <= waddr6 + 1'b1;
                            addr <= waddr6;
                        end else if(wen == 4'b0110) begin
                            en_wmem[6] <= 1'b1;
                            waddr7 <= waddr7 + 1'b1;
                            addr <= waddr7;
                        end else if(wen == 4'b0111) begin
                            en_wmem[7] <= 1'b1;
                            waddr8 <= waddr8 + 1'b1;
                            addr <= waddr8;
                        end else if(wen == 4'b1000) begin
                            en_wmem[8] <= 1'b1;
                            waddr9 <= waddr9 + 1'b1;
                            addr <= waddr9;
                        end else begin
                            en_wmem <= 9'b0;
                        end
                    end else begin
                        state <= WRITE;
                    end
                end
                READ: begin
                    if (stsinkvalid) begin
                        state <= WAIT2IDLE;
                        stsourcevalid <= 1'b1;
                        read <= 1'b1;
                        if(ren == 3'b001) begin
                            raddr1 <= raddr1 + 1'b1;
                            addr   <= raddr1;
                            en_rmem[0] <= 1'b1;
                        end else if(ren == 3'b010) begin
                            raddr2 <= raddr2 + 1'b1;
                            addr   <= raddr2;
                            en_rmem[1] <= 1'b1;
                        end else if(ren == 3'b100) begin
                            raddr3 <= raddr3 + 1'b1;
                            addr   <= raddr3;
                            en_rmem[2] <= 1'b1;
                        end
                    end else begin
                        state <= READ;
                    end
                end
                WAIT2IDLE: begin
                    if(read) begin
                        stsourcedata <= data_in;
                    end
                    if (!stsinkvalid) begin
                        state <= IDLE;
                    end else begin
                        state <= WAIT2IDLE;
                    end
                end
                CONV: begin
                    en_conv <= conven;
                    state   <= WAITC;
                end
                WAITC: begin
                    if ((convin[0] == 1'b1 && en_conv[0] == 1'b1) || (convin[1] == 1'b1 && en_conv[1] == 1'b1) || (convin[2] == 1'b1 && en_conv[2] == 1'b1)) begin
                        state    <= IDLE;
                        en_conv  <= 3'b0;
                        conven   <= 3'b0;
                        stsourcevalid <= 1'b1;
                        stsourcedata <= 8'hfe;
                    end else begin
                        state <= WAITC;
                    end
                end
                default: begin 
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
