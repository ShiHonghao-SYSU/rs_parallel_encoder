%   Coefficient calculation for parallel RS encoder.
%   Shi Honghao. Aug. 2, 2020.
%
close all;
clear
parallelism = 4;	% Parallelism
N = 255;
K = 239;
PARITY_NUM = 16;	% Parity amount
gf_bits = 8;    % 8 bits per gf(256) symbol
% g = [523 834 128 158 185 127 392 193 610 788 361 883 503 942 385 495 720 ...
% 94 132 593 249 282 565 108 1 552 230 187 552 575]; % rs(544,514)
g = [79    44    81   100    49   183    56    17   232   187   126   104    31   103    52   118]; % rs(255,239)
g = gf(g,gf_bits);
% g0, g1, ... g15.
p = zeros(PARITY_NUM,parallelism);	% p coef.
p = gf(p,gf_bits);

for d_idx = 1 : parallelism
    d = zeros(1,parallelism);			% input data.
    d = gf(d,gf_bits);
    d(d_idx) = 1;
    
    r = gf(zeros(PARITY_NUM, 1),gf_bits);			% regs.
    r_previous = gf(zeros(PARITY_NUM, 1),gf_bits);		% regs.
    for	i = 1 : parallelism             % clk cycles
	    m = d(i) +  r_previous(PARITY_NUM);
	    r(1) = m * g(1);
        for j = 2 : PARITY_NUM
		    r(j) = r_previous(j - 1) + m * g(j);
        end
        r_previous = r;
    end
	p(:, d_idx) = r;
end
disp('parallel encoding coefficients are')
p

%% validation
% serial encoder
data = 1:K;
% data = randi(255,1,K);
data = gf(data,gf_bits);
gen = rsgenpoly(255,239,[],1) % Generator polynomial
code = rsenc(data,N,K,gen);
check1 = code(end-PARITY_NUM+1:end);           % parity
check1

% parallel encoder
data0 = [0 data]; % insert a "0" before data for 4-parallel, mod(239,4) = 3.
rr = gf(zeros(1,PARITY_NUM),gf_bits);    % reset registers to zero
data0_para = reshape(data0,parallelism,60)';    % reshape data to (239+1)/4 = 60, for 4-parallel
for i = 1:60		% 60*4=240 data
    dd = data0_para(i,:);
    rr_last = rr;   
    for j = 1:PARITY_NUM	% calc regs with four (r + d) * p
        rr(PARITY_NUM+1 - j) = (rr_last(PARITY_NUM) + dd(1)) * p(PARITY_NUM+1 - j,1) + (rr_last(PARITY_NUM-1) + dd(2)) * p(PARITY_NUM+1 - j,2) +(rr_last(PARITY_NUM-2) + dd(3)) * p(PARITY_NUM+1 - j,3) +(rr_last(PARITY_NUM-3) + dd(4)) * p(PARITY_NUM+1 - j,4);
    	if(j <= PARITY_NUM-parallelism)	% r4 to r15
    		rr(PARITY_NUM+1 - j) = rr(PARITY_NUM+1 - j) + rr_last(PARITY_NUM+1 - j - parallelism);
    	end
    end
end
rr = flip(rr)   % output sequence of parity is r15 to r0, so flip here.

disp(['check1 is parity of serial encoder, and rr is parity of parallel encoder.' ...
    ' If they are the same then parallel encoder is functionally equivalent to serial encoder.'])

