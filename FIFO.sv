module fifo(clk, rst_n, wrt, rd, din, dout, empty, full);

parameter data_width = 8;
parameter adder_width = 4;
input clk, rst_n, wrt, rd;
input [data_width - 1: 0] din;
output full, empty;
output [data_width - 1: 0] dout;

// flop for metastability
logic flop_wrt_inter, flop_wrt, flop_rd_inter, flop_rd, data_wrt, data_rd;
// main data array for store all data
logic [data_width - 1: 0] data_array [2**adder_width - 1: 0];
// ptr for write
logic [adder_width - 1: 0] wr_ptr, wr_next, wr_succ;
// ptr for read
logic [adder_width - 1: 0] rd_ptr, rd_next, rd_succ;
logic [data_width - 1: 0] out;
logic full_reg, empty_reg, full_next, empty_next;

// flop for metastability
always @ (posedge clk) flop_wrt_inter <= wrt;
always @ (posedge clk) flop_wrt <= flop_wrt_inter;
assign data_wrt = ~flop_wrt_inter & flop_wrt;

// flop for metastability
always @ (posedge clk) flop_rd_inter <= rd;
always @ (posedge clk) flop_rd <= flop_rd_inter;
assign data_rd = ~flop_rd_inter & flop_rd;

// create signal for actual read and write
assign wrt_en = data_wrt & ~full;
assign rd_en = data_rd & ~empty;

always @(posedge clk, negedge rst_n) begin

	if(wrt_en)
		data_array[wr_ptr] <= din;
end

always @(posedge clk, negedge rst_n) begin

	if(data_rd)
		out <= data_array[rd_ptr];
end

// state transit
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		wr_ptr <= 0;
		rd_ptr <= 0;
		full_reg <= 1'b0;
		empty_reg <= 1'b1;
	end
	else begin
		wr_ptr <= wr_next;
		rd_ptr <= rd_next;
		full_reg <= full_next;
		empty_reg <= empty_next;
	end
end

always @(*)
 begin
  wr_succ = wr_ptr + 1; 
  rd_succ = rd_ptr + 1; 
  wr_next = wr_ptr;  
  rd_next = rd_ptr;  
  full_next = full_reg;  
  empty_next = empty_reg;  
   
   case({wrt_en,rd_en})

     
    2'b01: //read
     begin
      if(~empty) 
       begin
        rd_next = rd_succ;
        full_next = 1'b0;
       if(rd_succ == wr_ptr) 
         empty_next = 1'b1;  
       end
     end
     
    2'b10: //write
     begin
       
      if(~full) 
       begin
        wr_next = wr_succ;
        empty_next = 1'b0;
        if(wr_succ == (2**adder_width - 1)) 
         full_next = 1'b1;  
       end
     end
      
    2'b11: 
     begin
      wr_next = wr_succ;
      rd_next = rd_succ;
     end
    endcase
    
 
 end
 
assign full = full_reg;
assign empty = empty_reg;
assign dout = out;
endmodule