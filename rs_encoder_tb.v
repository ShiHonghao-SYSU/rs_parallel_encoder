// Verilog Test Bench for design : rs_encoder
// 

`timescale 100 ps/ 100 ps

module rs_encoder_tb();

reg clk;
reg [7:0] msg;
reg en;
reg frame_start_in;
reg [7:0] cnt;

// wires                                               
wire [7:0]  code_out;
wire [7:0]  r_code_out;
wire finish;

parameter clk_period = 100;
assign	code_out = r_code_out;
		
rs_encoder dut (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.msg(msg),
	.en(en),
	.encode_start(frame_start_in),
	.r_code_out(r_code_out),
	.finish(finish)
);

integer fp_r; // flie pointer
initial	fp_r = $fopen("rsdata.txt", "r");
integer r;


initial                                                
begin                                                  
	en = 1'b0;
	frame_start_in = 1'b1;
	#(5*clk_period) en = 1'b1;
	#(10*clk_period) en = 1'b0;
	#(5*clk_period) en = 1'b1;

$display("Running testbench");  
end    
 
initial  begin
	clk = 0;
	#(clk_period/2)
	forever #(clk_period/2) clk = ~clk;	//4ns,250MHz
end                                       

initial                                                 
begin                                                  
	#(clk_period/2)
		frame_start_in = 1'b0;
	forever
	begin
	#(clk_period)		
		frame_start_in = 1'b0;
	#(254*clk_period)
		frame_start_in = 1'b1;	
		if($feof(fp_r))
			fp_r = $fopen("rsdata.txt", "r");
	end
end 

initial begin
	#(2*clk_period) cnt = 'd0;	
end
always @(posedge clk ) begin
	if (cnt == 'd254)
		cnt <= 'd0;
	else
		cnt <= cnt + 1'b1;
end

always @(posedge clk ) begin
	case (cnt)
		'd239: $display("%d",code_out);
		'd240: $display("%d",code_out);
		'd241: $display("%d",code_out);
		'd242: $display("%d",code_out);
		'd243: $display("%d",code_out);
		'd244: $display("%d",code_out);
		'd245: $display("%d",code_out);
		'd246: $display("%d",code_out);
		'd247: $display("%d",code_out);
		'd248: $display("%d",code_out);
		'd249: $display("%d",code_out);
		'd250: $display("%d",code_out);
		'd251: $display("%d",code_out);
		'd252: $display("%d",code_out);
		'd253: $display("%d",code_out);
		'd254: $display("%d",code_out);
		default: ;
	endcase
end


reg [7:0] dt;
always@(posedge clk)
begin
	// if($feof(fp_r) && fp_in==1'b1)
		// fp_r = $fopen("rsdata.txt", "r");
	// else
	// #(clk_period)
	#(clk_period*0.01)
		if(!$feof(fp_r)) begin
		r = $fscanf(fp_r, "%d", dt);
		msg = dt;
		end
//		else if(finish==1'b1)	fp_r = $fopen("rsdata.txt", "r");
end


// initial
	// #(600*clk_period) $stop;

endmodule

