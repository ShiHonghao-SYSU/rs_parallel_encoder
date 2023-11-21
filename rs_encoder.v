

`timescale 100ps/100ps 

module rs_encoder 
(
	input					clk,
	input					en,
	input					encode_start,
	input 		[7:0]		msg,
	output	reg				finish,
	output		[7:0]		r_code_out
	);

reg		[7:0]		fec_code[15:0];
reg 	[127:0]		parity;
reg		[7:0]		msg_in_cnt;
reg 	[7:0]		msg_d1;
reg 	[7:0]		msg_d2;
reg					data_out_en;
reg					fec_reg_en;

reg					finish_pre2;
reg					finish_pre1;

	
wire		[7:0]		mult_in;		
wire		[7:0]		mult_out[15:0];	
wire 	 	[127:0]		parity_pack;

assign	mult_in = fec_code[15] ^ msg;
assign	r_code_out = (data_out_en == 1'b1)? msg_d1 : parity[127:120];

genvar i;
generate
	for (i = 0; i < 16 ; i = i + 1) begin
		assign parity_pack[i*8+7:i*8] = fec_code[i][7:0];
	end
endgenerate

//finish
always @(posedge clk ) begin
	finish_pre1 <= encode_start;
	finish <= finish_pre1;
end

//msg_d1 msg_d2
always @(posedge clk ) begin
	msg_d1 <= msg;
	msg_d2 <= msg_d1;
end

//parity
always @(posedge clk ) begin
	if (en == 1'b0) begin
		parity <= 'd0;
	end else if (msg_in_cnt == 'd239) begin
		parity <= parity_pack;
	end	else begin
		parity <= {parity[119:0],8'd0};
	end
end

//encode_start
always@(posedge clk)
begin
	if(en == 1'b1)	begin
		if(msg_in_cnt == 'd0) begin
			data_out_en <= 1'b1;			
		end
		else if(msg_in_cnt == 'd239) begin
			data_out_en <= 1'b0;
		end
	end
	else	begin
		data_out_en <= 1'b0;
	end
end

//encode_start
always@(posedge clk)
begin
	if(en == 1'b1)	begin
		if(encode_start == 1'b1) begin
			fec_reg_en <= 1'b1;			
		end
		else if(msg_in_cnt == 'd238) begin
			fec_reg_en <= 1'b0;
		end
	end
	else	begin
		fec_reg_en <= 1'b0;
	end
end


//msg_in_cnt++
always@(posedge clk)
begin
	if((msg_in_cnt == 'd254) || (en == 1'b0) || (encode_start == 1'b1)) 
	begin
		msg_in_cnt <= 'd0;
	end
	else begin
		msg_in_cnt <= msg_in_cnt + 1'b1;
	end
end
	
always@(posedge clk)
begin
	if((msg_in_cnt == 'd254) || (en == 1'b0))	
	begin
		fec_code[00] <= {10{1'b0}};
		fec_code[01] <= {10{1'b0}};
		fec_code[02] <= {10{1'b0}};
		fec_code[03] <= {10{1'b0}};
		fec_code[04] <= {10{1'b0}};
		fec_code[05] <= {10{1'b0}};
		fec_code[06] <= {10{1'b0}};
		fec_code[07] <= {10{1'b0}};
		fec_code[08] <= {10{1'b0}};
		fec_code[09] <= {10{1'b0}};
		fec_code[10] <= {10{1'b0}};
		fec_code[11] <= {10{1'b0}};
		fec_code[12] <= {10{1'b0}};
		fec_code[13] <= {10{1'b0}};
		fec_code[14] <= {10{1'b0}};
		fec_code[15] <= {10{1'b0}};
	end
	
	else if(fec_reg_en == 1'b0)	
	begin
		fec_code[00] <= fec_code[00] ;
		fec_code[01] <= fec_code[01] ;
		fec_code[02] <= fec_code[02] ;
		fec_code[03] <= fec_code[03] ;
		fec_code[04] <= fec_code[04] ;
		fec_code[05] <= fec_code[05] ;
		fec_code[06] <= fec_code[06] ;
		fec_code[07] <= fec_code[07] ;
		fec_code[08] <= fec_code[08] ;
		fec_code[09] <= fec_code[09] ;
		fec_code[10] <= fec_code[10] ;
		fec_code[11] <= fec_code[11] ;
		fec_code[12] <= fec_code[12] ;
		fec_code[13] <= fec_code[13] ;
		fec_code[14] <= fec_code[14] ;
		fec_code[15] <= fec_code[15] ;
	end
	
	else	begin                    
		fec_code[00] <= mult_out[00];
		fec_code[01] <= mult_out[01] ^ fec_code[00];
		fec_code[02] <= mult_out[02] ^ fec_code[01];
		fec_code[03] <= mult_out[03] ^ fec_code[02];
		fec_code[04] <= mult_out[04] ^ fec_code[03];
		fec_code[05] <= mult_out[05] ^ fec_code[04];
		fec_code[06] <= mult_out[06] ^ fec_code[05];
		fec_code[07] <= mult_out[07] ^ fec_code[06];
		fec_code[08] <= mult_out[08] ^ fec_code[07];
		fec_code[09] <= mult_out[09] ^ fec_code[08];
		fec_code[10] <= mult_out[10] ^ fec_code[09];
		fec_code[11] <= mult_out[11] ^ fec_code[10];
		fec_code[12] <= mult_out[12] ^ fec_code[11];
		fec_code[13] <= mult_out[13] ^ fec_code[12];
		fec_code[14] <= mult_out[14] ^ fec_code[13];
		fec_code[15] <= mult_out[15] ^ fec_code[14];
	end
end	


gf256_const_mult #(.A(118)) U15_gf256_const_mult(.din(mult_in),.dout(mult_out[15]));
gf256_const_mult #(.A( 52)) U14_gf256_const_mult(.din(mult_in),.dout(mult_out[14]));
gf256_const_mult #(.A(103)) U13_gf256_const_mult(.din(mult_in),.dout(mult_out[13]));
gf256_const_mult #(.A( 31)) U12_gf256_const_mult(.din(mult_in),.dout(mult_out[12]));
gf256_const_mult #(.A(104)) U11_gf256_const_mult(.din(mult_in),.dout(mult_out[11]));
gf256_const_mult #(.A(126)) U10_gf256_const_mult(.din(mult_in),.dout(mult_out[10]));
gf256_const_mult #(.A(187)) U09_gf256_const_mult(.din(mult_in),.dout(mult_out[09]));
gf256_const_mult #(.A(232)) U08_gf256_const_mult(.din(mult_in),.dout(mult_out[08]));
gf256_const_mult #(.A( 17)) U07_gf256_const_mult(.din(mult_in),.dout(mult_out[07]));
gf256_const_mult #(.A( 56)) U06_gf256_const_mult(.din(mult_in),.dout(mult_out[06]));
gf256_const_mult #(.A(183)) U05_gf256_const_mult(.din(mult_in),.dout(mult_out[05]));
gf256_const_mult #(.A( 49)) U04_gf256_const_mult(.din(mult_in),.dout(mult_out[04]));
gf256_const_mult #(.A(100)) U03_gf256_const_mult(.din(mult_in),.dout(mult_out[03]));
gf256_const_mult #(.A( 81)) U02_gf256_const_mult(.din(mult_in),.dout(mult_out[02]));
gf256_const_mult #(.A( 44)) U01_gf256_const_mult(.din(mult_in),.dout(mult_out[01]));
gf256_const_mult #(.A( 79)) U00_gf256_const_mult(.din(mult_in),.dout(mult_out[00]));


endmodule   
            