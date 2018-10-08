/* ACM Class System (I) 2018 Fall Assignment 1 
 *
 * Part I: Write an adder in Verilog
 *
 * Implement your Carry Look Ahead Adder here
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

module adder(
	// TODO: Write the ports of this module here
	//
	// Hint: 
	//   The module needs 4 ports, 
	//     the first 2 ports input two 16-bit unsigned numbers as the addends
	//     the third port outputs a 16-bit unsigned number as the sum
	//	   the forth port outputs a 1-bit carry flag as the overflow
	// 
	input wire [15:0] A,
	input wire [15:0] B, 
	output wire [15:0] rslt, 
	output wire cout
);
	// TODO: Implement this module here
	wire [3:0] c; 
	wire [3:0] PG; 
	wire [3:0] GG; 
	wire cin_ext, PG_ext, GG_ext; // unused
	assign cin_ext = 1'b0; // stupid style

	four_bit_CL_adder A0(.A(A[3:0]), .B(B[3:0]), .c0(c[0]), .PG(PG[0]), .GG(GG[0]), .rslt(rslt[3:0])); 
	four_bit_CL_adder A1(.A(A[7:4]), .B(B[7:4]), .c0(c[1]), .PG(PG[1]), .GG(GG[1]), .rslt(rslt[7:4])); 
	four_bit_CL_adder A2(.A(A[11:8]), .B(B[11:8]), .c0(c[2]), .PG(PG[2]), .GG(GG[2]), .rslt(rslt[11:8])); 
	four_bit_CL_adder A3(.A(A[15:12]), .B(B[15:12]), .c0(c[3]), .PG(PG[3]), .GG(GG[3]), .rslt(rslt[15:12])); 

	CLU logic(.P(PG), .G(GG), .cin(cin_ext), .PG(PG_ext), .GG(GG_ext));
endmodule

/**
An adder used to add two 4-bit numbers with look-ahead logic. 
*/
module four_bit_CL_adder(
	input wire [3:0] A,
	input wire [3:0] B, 
	input wire c0, // carry input into CLU
	output wire PG, 
	output wire GG, 
	output wire [3:0] rslt
	//output wire cout
);
wire cout; // temp
wire [3:0] c; // full-adder's carry produced by CLU. 
wire [3:0] P; 
wire [3:0] G; 
CL_full_adder FA0(.A(A[0]), .B(B[0]), .cin(c[0]), .P(P[0]), .G(G[0]), .rslt(rslt[0]));
CL_full_adder FA1(.A(A[1]), .B(B[1]), .cin(c[1]), .P(P[1]), .G(G[1]), .rslt(rslt[1]));
CL_full_adder FA2(.A(A[2]), .B(B[2]), .cin(c[2]), .P(P[2]), .G(G[2]), .rslt(rslt[2]));
CL_full_adder FA3(.A(A[3]), .B(B[3]), .cin(c[3]), .P(P[3]), .G(G[3]), .rslt(rslt[3]));
// we haven't calculated [3:0] c, so far. 
CLU logic(.P(P), .G(G), .cin(c0), .PG(PG), .GG(GG), .cout(c), .c_ext(cout));
endmodule

// carry look-ahead full adder.  
module CL_full_adder(
    input wire A, 
	input wire B, 
	input wire cin, 
	output wire P,
	output wire G, 
	output wire rslt
); 
assign P = A ^ B; // xor in verilog 
assign G = A & B; 
assign rslt = A ^ B ^ cin; 
endmodule

// carry look-ahead unit. 
module CLU(
	input wire [3:0] P,
	input wire [3:0] G, 
	input wire cin,
	output wire PG, 
	output wire GG,
	output wire [3:0] cout, 
	output wire c_ext
); 
assign cout[0] = cin; 
assign cout[1] = G[0] | P[0] & cin; 
assign cout[2] = G[1] | G[0] & P[1] | P[0] & cin & P[1];
assign cout[3] = G[2] | G[1] & P[2] | G[0] & P[1] & P[2] | P[0] & cin & P[1] & P[2];
assign c_ext = G[3] | G[2] & P[3] | G[1] & P[2] & P[3] | G[0] & P[1] & P[2] & P[3] | P[0] & cin & P[1] & P[2] & P[3];

assign PG = P[0] & P[1] & P[2] & P[3]; 
assign GG = G[3] | G[2] & P[3] | G[1] & P[3] & P[2] | G[0] & P[3] & P[2] & P[1]; 
endmodule