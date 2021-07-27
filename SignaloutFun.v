`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2021 01:37:04 PM
// Design Name: 
// Module Name: SignaloutFun
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SignaloutFun #(
    parameter bigger1 = 16'd0)(
    input clk_100,
    input clk_1,
    input reset,
    input clk_25,

    input signed [15:0] siginx,
    input signed [15:0] siginy,
    input signed [15:0] shift1,
    input signed [15:0] shift2,

    output LED,
    output [3:0] JB
    );

    reg  [15:0] sin_out, cos_out;
    reg  [15:0] sin_out1, cos_out1;
    reg  [11:0] sin_out2, cos_out2;


    ////////////////////////////////////////////////////////////////
    /// ila
    ////////////////////////////////////////////////////////////////
    ila_1 u_ila1 (
	.clk(clk_100), // input wire clk
	.probe0(sin_out), // input wire [7:0]  probe0  
	.probe1(cos_out),
    .probe2(sin_out2),
    .probe3(cos_out2)); // input wire [7:0]  probe1



    /////////////////////////////////
    //// DA2
    ////////////////////////////////

    always @(posedge clk_1) begin
        if (reset) begin
            sin_out <= 0;
            cos_out <= 0;
            sin_out1 <= 0;
            cos_out1 <= 0;
            sin_out2 <= 0;
            cos_out2 <= 0;
        end
        else begin
            sin_out <= siginx - shift1;
            cos_out <= siginy - shift2;
            sin_out1 <= sin_out <<< bigger1;
            cos_out1 <= cos_out <<< bigger1;
            sin_out2 <= sin_out1[11:0]+12'h800;
            cos_out2 <= cos_out1[11:0]+12'h800;
        end
    end
        
    DA2RefComp u_DA2( //instantiate vhd code
    //SIGNALS PROVIDED TO DA2RefComp
    .CLK(clk_25),  //output ports decalration
    .START(clk_1), 
    .DATA1(sin_out2), 
    .DATA2(cos_out2), 
    .RST(reset), 
        
    //DO NOT CHANGE THE FOLLOWING LINES
    .D1(JB[1]), 
    .D2(JB[2]), 
    .CLK_OUT(JB[3]), 
    .nSYNC(JB[0]), 
    .DONE(LED)
    );
endmodule
