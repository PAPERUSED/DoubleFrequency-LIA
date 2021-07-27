`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2021 02:08:19 AM
// Design Name: 
// Module Name: RemoveDCFun
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


module RemoveDCFun(
        input clk,                          // input wire clk
        input rst,
        input start,
        input signed [15:0] shift05sin,          // input wire shift05sin
        input signed [15:0] shift05cos, // input wire shift05cos
        input signed [15:0] shift6sin, // input wire shift6sin
        input signed [15:0] shift6cos, // input wire shift6cos
        output reg signed [15:0] shiftnew05sin, // output wire shift
        output reg signed [15:0] shiftnew05cos, // output wire shift
        output reg signed [15:0] shiftnew6sin, // output wire shift
        output reg signed [15:0] shiftnew6cos // output wire shift
    );

    reg [15:0] counters;
    reg [2:0] status;

    always @(posedge clk or posedge start or posedge rst) begin
        if (rst || start) begin
            shiftnew05sin <= 16'd0;
            shiftnew05cos <= 16'd0;
            shiftnew6sin <= 16'd0;
            shiftnew6cos <= 16'd0;
            status <= 3'd0;
            counters <= 16'd0;
        end
        else 
            case (status)
                3'd0: begin
                    if (counters < 16'd40960) counters <= counters + 1;
                    else status <= status + 3'd1;
                    end
                3'd1: begin
                    shiftnew05sin <= shift05sin;
                    shiftnew05cos <= shift05cos;
                    shiftnew6sin <= shift6sin;
                    shiftnew6cos <= shift6cos;
                    status <= status + 3'd1;
                end
                default: begin
                    status <= status;
                    shiftnew05sin <= shiftnew05sin;
                    shiftnew05cos <= shiftnew05cos;
                    shiftnew6sin <= shiftnew6sin;
                    shiftnew6cos <= shiftnew6cos;
                end           
            endcase
    end
endmodule
