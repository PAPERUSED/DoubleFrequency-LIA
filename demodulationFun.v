`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2021 11:42:50 PM
// Design Name: 
// Module Name: demodulationFun
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


module demodulationFun #(
    parameter bigger1 = 16'd0)(
    input clk_100,
    input clk_1,
    input reset,
    input signed [15:0] sin,
    input signed [15:0] cos,
    input signed [15:0] sigin,
    input signed [15:0] shiftsin,
    input signed [15:0] shiftcos,

    output signed [15:0] sigoutx,
    output signed [15:0] sigouty
    );

    
    
    wire signed [31:0] omul_sin;
    wire signed [31:0] omul_cos;

    wire signed [16:0] sin_cic5M;
    wire signed [16:0] cos_cic5M;

    wire signed [16:0] sin_cic200k;
    wire signed [16:0] cos_cic200k;

    wire signed [16:0] sin_cic10k;
    wire signed [16:0] cos_cic10k;

    wire signed [40:0] ofir_all;

    reg signed [15:0] subchannels, osin, ocos;
    reg signed [31:0] out_mulsin_t,out_mulcos_t;
    reg signed [31:0] out_mulsin_t1,out_mulcos_t1;
    reg signed [15:0] out_mulsin,out_mulcos;

    ////////////////////////////////////////////////////////////////
    /// ila
    ////////////////////////////////////////////////////////////////
    ila_0 u_ila1 (
        .clk(clk_100), // input wire clk
        .probe0(out_mulsin), // input wire [15:0]  probe2 
        .probe1(out_mulcos),
        .probe2(sigoutx),
        .probe3(sigouty)); // input wire [15:0]  probe3

    /////////////////////////////////
    //////buffer
    ////////////////////////////////
    
    always @(posedge clk_100 or posedge reset) begin
        if(reset) begin
            subchannels <= 16'd0;
            osin <= 16'd0;
            ocos <= 16'd0;
        end
        else begin
            subchannels <= sigin;
            osin <= sin;
            ocos <= cos;
        end
    end

    /////////////////////////////////
    ////multplication/////////////////
    //////////////////////////////

    //wire signed [15:0] bug = 0;

    mult_gen_0 u_mult_sin (
    .CLK(clk_100),  // input wire CLK
    .A(subchannels),      // input wire [15 : 0] A
    .B(osin),      // input wire [15 : 0] B
    .P(omul_sin)      // output wire [31 : 0] P
    );

    mult_gen_0 u_mult_cos (
    .CLK(clk_100),  // input wire CLK
    .A(subchannels),      // input wire [15 : 0] A
    .B(ocos),      // input wire [15 : 0] B
    .P(omul_cos)      // output wire [31 : 0] P
    );


    always @(posedge clk_100 or posedge reset) begin
        if(reset) begin
            out_mulsin <= 16'd0;
            out_mulsin_t <= 32'd0;
            out_mulsin_t1 <= 32'd0;
            out_mulcos <= 16'd0;
            out_mulcos_t <= 32'd0;
            out_mulcos_t1 <= 32'd0;
        end
        else begin
            out_mulsin_t <= (omul_sin <<< bigger1); ///3
            out_mulcos_t <= (omul_cos <<< bigger1); ///;

            out_mulsin_t1 <=  out_mulsin_t[31:16];
            out_mulcos_t1 <=  out_mulcos_t[31:16];

            out_mulsin <= out_mulsin_t1 - shiftsin; ///
            out_mulcos <= out_mulcos_t1 - shiftcos; ///
        end
    end

    ////////////////////////////////////////////////////////////////
    /////CIC
    ////////////////////////////////////////////////////////////////

    cic_compiler_0 u_cic_sin20 (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(out_mulsin),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready.
    .m_axis_data_tdata(sin_cic5M),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );

    cic_compiler_0 u_cic_cos20 (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(out_mulcos),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .m_axis_data_tdata(cos_cic5M),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );



    cic_compiler_1 u_cic_sin25 (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(sin_cic5M[15:0]),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .m_axis_data_tdata(sin_cic200k),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );

    cic_compiler_1 u_cic_cos25 (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(cos_cic5M[15:0]),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .m_axis_data_tdata(cos_cic200k),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );


    cic_compiler_2 u_cic_sin20_2 (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(sin_cic200k[15:0]),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .m_axis_data_tdata(sin_cic10k),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );

    cic_compiler_2 u_cic_cos20_2 (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(cos_cic200k[15:0]),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .m_axis_data_tdata(cos_cic10k),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );

    /////////////////////////////////
    ///fir filter
    ////////////////////////////////
    
    fir_compiler_0 u_fir (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .s_axis_data_tdata({sin_cic10k[15:0], cos_cic10k[15:0]}),    // input wire [31 : 0] s_axis_data_tdata
    .m_axis_data_tvalid(),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata(ofir_all)    // output wire [31 : 0] m_axis_data_tdata
    );

    /////////////////////////////////
    ///CIC up
    ////////////////////////////////
    cic_compiler_3 cic_up_cos_1M (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(ofir_all[15:0]),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .m_axis_data_tdata(sigouty),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );

    cic_compiler_3 cic_up_sin_1M (
    .aclk(clk_100),                              // input wire aclk
    .s_axis_data_tdata(ofir_all[39:24]),    // input wire [15 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(),  // output wire s_axis_data_tready
    .m_axis_data_tdata(sigoutx),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid()  // output wire m_axis_data_tvalid
    );

    ////////////////////////////////
    // signout buffer
    ////////////////////////////////

endmodule
