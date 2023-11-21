

`timescale 100ps/100ps

module rs_encoder_x4
(
	input					clk,
	input					en,
	input					frame_start_in,
	input		[31:0]		din,
	output	reg				frame_start_out,
	output	reg	[31:0]		dout
	);

reg		[7:0]		r[15:0];
reg		[31:0]		last4parities;
reg		[6:0]		msg_in_cnt;
reg					is_encoding;
reg					cnt_en;



reg		[7:0]		msg[3:0];

wire	[7:0]		data[3:0];

wire	[7:0]		mul0[15:0];
wire	[7:0]		mul1[15:0];
wire	[7:0]		mul2[15:0];
wire	[7:0]		mul3[15:0];

wire	[7:0]		dr[3:0];	//data xor reg


assign	dr[0] = r[15] ^ data[3];
assign	dr[1] = r[14] ^ data[2];
assign	dr[2] = r[13] ^ data[1];
assign	dr[3] = r[12] ^ data[0];

// padding zeros
assign	data[3] = (frame_start_in == 1'b1) ? 8'b0 : msg[0];
assign	data[2] = din[31:24];		// din[31] enter into encoder first
assign	data[1] = din[23:16];
assign	data[0] = din[15:8];


//dout
always@(posedge clk)
begin
	if(msg_in_cnt == 7'd60)
		dout <= {r[15], r[14], r[13], r[12]};
	else if(msg_in_cnt == 7'd61)
		dout <= {r[11], r[10], r[09], r[08]};
	else if(msg_in_cnt == 7'd62)
		dout <= {r[07], r[06], r[05], r[04]};
	else if(msg_in_cnt == 7'd63)
		dout <= {r[03], r[02], r[01], r[00]};
	else if(is_encoding == 1'b1)
		dout <= {data[3], data[2], data[1], data[0]};
	else
		dout <= 32'd0;
end

//frame_start_out
always@(posedge clk)
	if(msg_in_cnt == 7'd0)
		frame_start_out <= 1'b1;
	else
		frame_start_out <= 1'b0;

//last4parities
always@(posedge clk)
	last4parities <= {r[3], r[2], r[1], r[0]};

//msg
always@(posedge clk)
begin
	if(is_encoding == 1'b1)	begin
		msg[3] <= din[31:24];
		msg[2] <= din[23:16];
		msg[1] <= din[15:8];
		msg[0] <= din[7:0];
	end
	else if(msg_in_cnt == 7'd59)	begin
		msg[3] <= din[31:24];
		msg[2] <= din[23:16];
		msg[1] <= din[15:8];
		msg[0] <= 10'b0;	// fill with 0, don't care.
	end
	else	begin
		msg[3] <= 10'b0;
		msg[2] <= 10'b0;
		msg[1] <= 10'b0;
		msg[0] <= 10'b0;

	end
end

//frame_start_in, 1 clk high pulse
//cnt_en
always@(posedge clk)
begin
	if(en == 1'b1)
		if(frame_start_in == 1'b1)
			cnt_en <= 1'b1;
		else
			cnt_en <= cnt_en;
	else
		cnt_en <= 1'b0;
end

//is_encoding
always@(posedge clk)
begin
	if(en == 1'b1)
		if(frame_start_in == 1'b1)
			is_encoding <= 1'b1;
		else if(msg_in_cnt == 7'd59)
			is_encoding <= 1'b0;
		else
			is_encoding <= is_encoding;
	else
		is_encoding <= 1'b0;
end



// msg_in_cnt ++
always@(posedge clk)
begin
	if(cnt_en == 1'b1)
	begin
		if((msg_in_cnt == 7'd65))
		begin
			msg_in_cnt <= 10'd0;
		end
		else
			msg_in_cnt <= msg_in_cnt + 1'b1;
	end
	else
		msg_in_cnt <= 10'd0;
end

//reset
always@(posedge clk)
begin
	if((msg_in_cnt == 7'd65) || (en == 1'b0) || (cnt_en == 1'b0))
	begin
		r[00] <= {10{1'b0}};
		r[01] <= {10{1'b0}};
		r[02] <= {10{1'b0}};
		r[03] <= {10{1'b0}};
		r[04] <= {10{1'b0}};
		r[05] <= {10{1'b0}};
		r[06] <= {10{1'b0}};
		r[07] <= {10{1'b0}};
		r[08] <= {10{1'b0}};
		r[09] <= {10{1'b0}};
		r[10] <= {10{1'b0}};
		r[11] <= {10{1'b0}};
		r[12] <= {10{1'b0}};
		r[13] <= {10{1'b0}};
		r[14] <= {10{1'b0}};
		r[15] <= {10{1'b0}};
	end

	else if(is_encoding == 1'b0)
	begin
		r[00] <= r[00] ;
		r[01] <= r[01] ;
		r[02] <= r[02] ;
		r[03] <= r[03] ;
		r[04] <= r[04] ;
		r[05] <= r[05] ;
		r[06] <= r[06] ;
		r[07] <= r[07] ;
		r[08] <= r[08] ;
		r[09] <= r[09] ;
		r[10] <= r[10] ;
		r[11] <= r[11] ;
		r[12] <= r[12] ;
		r[13] <= r[13] ;
		r[14] <= r[14] ;
		r[15] <= r[15] ;
	end

	else	begin
		r[00] <= mul3[00] ^ mul2[00] ^ mul1[00] ^ mul0[00];
		r[01] <= mul3[01] ^ mul2[01] ^ mul1[01] ^ mul0[01];
		r[02] <= mul3[02] ^ mul2[02] ^ mul1[02] ^ mul0[02];
		r[03] <= mul3[03] ^ mul2[03] ^ mul1[03] ^ mul0[03];
		r[04] <= mul3[04] ^ mul2[04] ^ mul1[04] ^ mul0[04] ^ r[00];
		r[05] <= mul3[05] ^ mul2[05] ^ mul1[05] ^ mul0[05] ^ r[01];
		r[06] <= mul3[06] ^ mul2[06] ^ mul1[06] ^ mul0[06] ^ r[02];
		r[07] <= mul3[07] ^ mul2[07] ^ mul1[07] ^ mul0[07] ^ r[03];
		r[08] <= mul3[08] ^ mul2[08] ^ mul1[08] ^ mul0[08] ^ r[04];
		r[09] <= mul3[09] ^ mul2[09] ^ mul1[09] ^ mul0[09] ^ r[05];
		r[10] <= mul3[10] ^ mul2[10] ^ mul1[10] ^ mul0[10] ^ r[06];
		r[11] <= mul3[11] ^ mul2[11] ^ mul1[11] ^ mul0[11] ^ r[07];
		r[12] <= mul3[12] ^ mul2[12] ^ mul1[12] ^ mul0[12] ^ r[08];
		r[13] <= mul3[13] ^ mul2[13] ^ mul1[13] ^ mul0[13] ^ r[09];
		r[14] <= mul3[14] ^ mul2[14] ^ mul1[14] ^ mul0[14] ^ r[10];
		r[15] <= mul3[15] ^ mul2[15] ^ mul1[15] ^ mul0[15] ^ r[11];
	end
end

//m0*g0 ~ m0*g15
gf256_const_mult #(.A(170)) mul0_15_gf256_const_mult(.din(dr[0]),.dout(mul0[15]));
gf256_const_mult #(.A(197)) mul0_14_gf256_const_mult(.din(dr[0]),.dout(mul0[14]));
gf256_const_mult #(.A(131)) mul0_13_gf256_const_mult(.din(dr[0]),.dout(mul0[13]));
gf256_const_mult #(.A( 83)) mul0_12_gf256_const_mult(.din(dr[0]),.dout(mul0[12]));
gf256_const_mult #(.A( 85)) mul0_11_gf256_const_mult(.din(dr[0]),.dout(mul0[11]));
gf256_const_mult #(.A(254)) mul0_10_gf256_const_mult(.din(dr[0]),.dout(mul0[10]));
gf256_const_mult #(.A(143)) mul0_09_gf256_const_mult(.din(dr[0]),.dout(mul0[09]));
gf256_const_mult #(.A(188)) mul0_08_gf256_const_mult(.din(dr[0]),.dout(mul0[08]));
gf256_const_mult #(.A(  7)) mul0_07_gf256_const_mult(.din(dr[0]),.dout(mul0[07]));
gf256_const_mult #(.A( 61)) mul0_06_gf256_const_mult(.din(dr[0]),.dout(mul0[06]));
gf256_const_mult #(.A( 48)) mul0_05_gf256_const_mult(.din(dr[0]),.dout(mul0[05]));
gf256_const_mult #(.A( 51)) mul0_04_gf256_const_mult(.din(dr[0]),.dout(mul0[04]));
gf256_const_mult #(.A(142)) mul0_03_gf256_const_mult(.din(dr[0]),.dout(mul0[03]));
gf256_const_mult #(.A(249)) mul0_02_gf256_const_mult(.din(dr[0]),.dout(mul0[02]));
gf256_const_mult #(.A( 33)) mul0_01_gf256_const_mult(.din(dr[0]),.dout(mul0[01]));
gf256_const_mult #(.A( 53)) mul0_00_gf256_const_mult(.din(dr[0]),.dout(mul0[00]));
                       
//m1*g0 ~ m1*g15       
gf256_const_mult #(.A(183)) mul1_15_gf256_const_mult(.din(dr[1]),.dout(mul1[15]));
gf256_const_mult #(.A( 37)) mul1_14_gf256_const_mult(.din(dr[1]),.dout(mul1[14]));
gf256_const_mult #(.A(255)) mul1_13_gf256_const_mult(.din(dr[1]),.dout(mul1[13]));
gf256_const_mult #(.A(  4)) mul1_12_gf256_const_mult(.din(dr[1]),.dout(mul1[12]));
gf256_const_mult #(.A( 31)) mul1_11_gf256_const_mult(.din(dr[1]),.dout(mul1[11]));
gf256_const_mult #(.A( 33)) mul1_10_gf256_const_mult(.din(dr[1]),.dout(mul1[10]));
gf256_const_mult #(.A(160)) mul1_09_gf256_const_mult(.din(dr[1]),.dout(mul1[09]));
gf256_const_mult #(.A(215)) mul1_08_gf256_const_mult(.din(dr[1]),.dout(mul1[08]));
gf256_const_mult #(.A( 89)) mul1_07_gf256_const_mult(.din(dr[1]),.dout(mul1[07]));
gf256_const_mult #(.A( 15)) mul1_06_gf256_const_mult(.din(dr[1]),.dout(mul1[06]));
gf256_const_mult #(.A( 48)) mul1_05_gf256_const_mult(.din(dr[1]),.dout(mul1[05]));
gf256_const_mult #(.A( 95)) mul1_04_gf256_const_mult(.din(dr[1]),.dout(mul1[04]));
gf256_const_mult #(.A( 88)) mul1_03_gf256_const_mult(.din(dr[1]),.dout(mul1[03]));
gf256_const_mult #(.A(205)) mul1_02_gf256_const_mult(.din(dr[1]),.dout(mul1[02]));
gf256_const_mult #(.A( 55)) mul1_01_gf256_const_mult(.din(dr[1]),.dout(mul1[01]));
gf256_const_mult #(.A(117)) mul1_00_gf256_const_mult(.din(dr[1]),.dout(mul1[00]));
                       
//m2*g0 ~ m2*g15       
gf256_const_mult #(.A(132)) mul2_15_gf256_const_mult(.din(dr[2]),.dout(mul2[15]));
gf256_const_mult #(.A(247)) mul2_14_gf256_const_mult(.din(dr[2]),.dout(mul2[14]));
gf256_const_mult #(.A(234)) mul2_13_gf256_const_mult(.din(dr[2]),.dout(mul2[13]));
gf256_const_mult #(.A(147)) mul2_12_gf256_const_mult(.din(dr[2]),.dout(mul2[12]));
gf256_const_mult #(.A( 67)) mul2_11_gf256_const_mult(.din(dr[2]),.dout(mul2[11]));
gf256_const_mult #(.A(156)) mul2_10_gf256_const_mult(.din(dr[2]),.dout(mul2[10]));
gf256_const_mult #(.A( 53)) mul2_09_gf256_const_mult(.din(dr[2]),.dout(mul2[09]));
gf256_const_mult #(.A(169)) mul2_08_gf256_const_mult(.din(dr[2]),.dout(mul2[08]));
gf256_const_mult #(.A(125)) mul2_07_gf256_const_mult(.din(dr[2]),.dout(mul2[07]));
gf256_const_mult #(.A(117)) mul2_06_gf256_const_mult(.din(dr[2]),.dout(mul2[06]));
gf256_const_mult #(.A(190)) mul2_05_gf256_const_mult(.din(dr[2]),.dout(mul2[05]));
gf256_const_mult #(.A( 71)) mul2_04_gf256_const_mult(.din(dr[2]),.dout(mul2[04]));
gf256_const_mult #(.A( 62)) mul2_03_gf256_const_mult(.din(dr[2]),.dout(mul2[03]));
gf256_const_mult #(.A(165)) mul2_02_gf256_const_mult(.din(dr[2]),.dout(mul2[02]));
gf256_const_mult #(.A(123)) mul2_01_gf256_const_mult(.din(dr[2]),.dout(mul2[01]));
gf256_const_mult #(.A(  4)) mul2_00_gf256_const_mult(.din(dr[2]),.dout(mul2[00]));
                       
//m3*g0 ~ m3*g15       
gf256_const_mult #(.A(118)) mul3_15_gf256_const_mult(.din(dr[3]),.dout(mul3[15]));
gf256_const_mult #(.A( 52)) mul3_14_gf256_const_mult(.din(dr[3]),.dout(mul3[14]));
gf256_const_mult #(.A(103)) mul3_13_gf256_const_mult(.din(dr[3]),.dout(mul3[13]));
gf256_const_mult #(.A( 31)) mul3_12_gf256_const_mult(.din(dr[3]),.dout(mul3[12]));
gf256_const_mult #(.A(104)) mul3_11_gf256_const_mult(.din(dr[3]),.dout(mul3[11]));
gf256_const_mult #(.A(126)) mul3_10_gf256_const_mult(.din(dr[3]),.dout(mul3[10]));
gf256_const_mult #(.A(187)) mul3_09_gf256_const_mult(.din(dr[3]),.dout(mul3[09]));
gf256_const_mult #(.A(232)) mul3_08_gf256_const_mult(.din(dr[3]),.dout(mul3[08]));
gf256_const_mult #(.A( 17)) mul3_07_gf256_const_mult(.din(dr[3]),.dout(mul3[07]));
gf256_const_mult #(.A( 56)) mul3_06_gf256_const_mult(.din(dr[3]),.dout(mul3[06]));
gf256_const_mult #(.A(183)) mul3_05_gf256_const_mult(.din(dr[3]),.dout(mul3[05]));
gf256_const_mult #(.A( 49)) mul3_04_gf256_const_mult(.din(dr[3]),.dout(mul3[04]));
gf256_const_mult #(.A(100)) mul3_03_gf256_const_mult(.din(dr[3]),.dout(mul3[03]));
gf256_const_mult #(.A( 81)) mul3_02_gf256_const_mult(.din(dr[3]),.dout(mul3[02]));
gf256_const_mult #(.A( 44)) mul3_01_gf256_const_mult(.din(dr[3]),.dout(mul3[01]));
gf256_const_mult #(.A( 79)) mul3_00_gf256_const_mult(.din(dr[3]),.dout(mul3[00]));



endmodule

