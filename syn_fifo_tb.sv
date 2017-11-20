module syc_fifo_tb();

logic clk, rst_n; 
logic [7:0] data_in, data_out;

logic wr_en, rd_en, empty, full;

fifo #(8,4)idut(.clk(clk), .rst_n(rst_n), .wrt(wr_en), .rd(rd_en), .din(data_in), .dout(data_out), .empty(empty), .full(full));
initial clk = 0;
always #5 clk = ~clk;

initial begin
	rst_n = 0;
	
	@(posedge clk)
	rst_n = 1;
	data_in = 8'hff;
	rd_en = 0;
	wr_en = 1;
	
	
	#100;
	
	@(posedge clk)
	wr_en = 0;
	rd_en = 1;
	#100;
	if(data_out != 8'hff) begin 
		$display("concurrent not working, so sad.");
		$stop();
	end
	
	
	$display("read and write is correct, so happy.");
	$stop();
	
end
endmodule
