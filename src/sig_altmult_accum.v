module sig_altmult_accum
(
	input [8:0] dataa,
	input [8:0] datab,
	input clk, aclr, clken, sload,
	output reg signed [18:0] adder_out
);

	// Declare registers and wires
	reg  signed [8:0] dataa_reg, datab_reg;
	reg  sload_reg;
	reg	 signed [18:0] old_result;
	wire signed [17:0] multa;
	
	// Store the results of the operations on the current data
	assign multa = dataa * datab;
	
	// Store the value of the accumulation (or clear it)
	always @ (adder_out, sload_reg)
	begin
		if (sload_reg)
			old_result <= 0;
		else
			old_result <= adder_out;
	end
	
	// Clear or update data, as appropriate
	always @ (posedge clk or posedge aclr)
	begin
		if (aclr)
		begin
			//dataa_reg <= 0;
			//datab_reg <= 0;
			sload_reg <= 0;
			adder_out <= 0;
		end
		
		else if (clken)
		begin
			//dataa_reg <= dataa;
			//datab_reg <= datab;
			sload_reg <= sload;
			adder_out <= old_result + multa;
		end
	end
endmodule
