// Verilog Test Bench for design : rs_encoder_x8
// 

`timescale 100 ps/ 100 ps
module rs_encoder_x4_tb();
// constants                                           
// general purpose registers
// test vector input registers
reg clk;
reg [31:0] din;
reg en;
reg frame_start_in;
reg [7:0] cnt;
// wires                                               
wire [7:0]  code_out[3:0];
wire frame_start_out;
wire [31:0] dout;


//clk
parameter clk_period = 100;

integer fp_r; // flie pointer
initial	fp_r = $fopen("rsdata.txt", "r");
integer r;



// assign statements (if any)
assign	{
		code_out[03],code_out[02],code_out[01],code_out[00]
		}	= dout[31:0];
		
rs_encoder_x4 dut (
	.clk(clk),
	.din(din),
	.en(en),
	.frame_start_in(frame_start_in),
	.dout(dout),
	.frame_start_out(frame_start_out)
);

initial                                                
begin                                                  
	en = 1'b0;
	cnt = 8'd0;
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
	#(65*clk_period)
		frame_start_in = 1'b1;	
		if($feof(fp_r))
			fp_r = $fopen("rsdata.txt", "r");
	end
end 

always @(posedge clk ) begin
	if (cnt == 'd65)
		cnt <= 'd0;
	else
		cnt <= cnt + 1'b1;
end

always @(posedge clk ) begin
	case (cnt)
		'd62: $display("%d %d %d %d",code_out[03],code_out[02],code_out[01],code_out[00]);
		'd63: $display("%d %d %d %d",code_out[03],code_out[02],code_out[01],code_out[00]);
		'd64: $display("%d %d %d %d",code_out[03],code_out[02],code_out[01],code_out[00]);
		'd65: $display("%d %d %d %d",code_out[03],code_out[02],code_out[01],code_out[00]);
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
		din[31:24] = dt;
		r = $fscanf(fp_r, "%d", dt);
		din[23:16] = dt;
		r = $fscanf(fp_r, "%d", dt);
		din[15:8] = dt;
		r = $fscanf(fp_r, "%d", dt);
		din[7:0] = dt;
		end
//		else if(finish==1'b1)	fp_r = $fopen("rsdata.txt", "r");
end

initial
begin
	#(500*clk_period) $stop;
end
	endmodule

