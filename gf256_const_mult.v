// gf(256) constant multiplier for RS(255, 239) code.
// shi honghao Nov. 13, 2023.

`timescale 1ns/100ps
module gf256_const_mult 
#(parameter	[7:0] A = 8'd1) 
(
	input 			[7:0]	din,
	output	reg 	[7:0]	dout
	);

wire		[7:0]		ai[7:0];

//A*(alpha^0 ~ alpha^9)
// GF(2^8) array. Primitive polynomial = D^8+D^4+D^3+D^2+1 (285 decimal)
// so that r4 <= r3 xor r7. r3 <= r2 xor r7. r2 <= r1 xor r7.

assign ai[0] = A;	
genvar i;
generate
	for (i = 0; i < 7; i = i + 1)	
		begin	:	gx
			assign ai[i+1][7:5] 	= ai[i][6:4];
			assign ai[i+1][4] 	= ai[i][7] ^ ai[i][3];
			assign ai[i+1][3] 	= ai[i][7] ^ ai[i][2];
			assign ai[i+1][2] 	= ai[i][7] ^ ai[i][1];
			assign ai[i+1][1:0] 	= {ai[i][0], ai[i][7]};
		end
endgenerate

//
always@(*)//GF(256)field a*din
begin

	dout[7] = (ai[0][7]&din[0]) ^ (ai[1][7]&din[1]) ^ (ai[2][7]&din[2]) ^ (ai[3][7]&din[3]) ^ (ai[4][7]&din[4]) ^ (ai[5][7]&din[5]) ^ (ai[6][7]&din[6]) ^ (ai[7][7]&din[7]);
	dout[6] = (ai[0][6]&din[0]) ^ (ai[1][6]&din[1]) ^ (ai[2][6]&din[2]) ^ (ai[3][6]&din[3]) ^ (ai[4][6]&din[4]) ^ (ai[5][6]&din[5]) ^ (ai[6][6]&din[6]) ^ (ai[7][6]&din[7]);
	dout[5] = (ai[0][5]&din[0]) ^ (ai[1][5]&din[1]) ^ (ai[2][5]&din[2]) ^ (ai[3][5]&din[3]) ^ (ai[4][5]&din[4]) ^ (ai[5][5]&din[5]) ^ (ai[6][5]&din[6]) ^ (ai[7][5]&din[7]);
	dout[4] = (ai[0][4]&din[0]) ^ (ai[1][4]&din[1]) ^ (ai[2][4]&din[2]) ^ (ai[3][4]&din[3]) ^ (ai[4][4]&din[4]) ^ (ai[5][4]&din[5]) ^ (ai[6][4]&din[6]) ^ (ai[7][4]&din[7]);
	dout[3] = (ai[0][3]&din[0]) ^ (ai[1][3]&din[1]) ^ (ai[2][3]&din[2]) ^ (ai[3][3]&din[3]) ^ (ai[4][3]&din[4]) ^ (ai[5][3]&din[5]) ^ (ai[6][3]&din[6]) ^ (ai[7][3]&din[7]);
	dout[2] = (ai[0][2]&din[0]) ^ (ai[1][2]&din[1]) ^ (ai[2][2]&din[2]) ^ (ai[3][2]&din[3]) ^ (ai[4][2]&din[4]) ^ (ai[5][2]&din[5]) ^ (ai[6][2]&din[6]) ^ (ai[7][2]&din[7]);
	dout[1] = (ai[0][1]&din[0]) ^ (ai[1][1]&din[1]) ^ (ai[2][1]&din[2]) ^ (ai[3][1]&din[3]) ^ (ai[4][1]&din[4]) ^ (ai[5][1]&din[5]) ^ (ai[6][1]&din[6]) ^ (ai[7][1]&din[7]);
	dout[0] = (ai[0][0]&din[0]) ^ (ai[1][0]&din[1]) ^ (ai[2][0]&din[2]) ^ (ai[3][0]&din[3]) ^ (ai[4][0]&din[4]) ^ (ai[5][0]&din[5]) ^ (ai[6][0]&din[6]) ^ (ai[7][0]&din[7]);
	
end	
endmodule

