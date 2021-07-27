`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2021 11:52:52 AM
// Design Name: 
// Module Name: main
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


module main(
    input clk_in,
    input rst,
    input rst1,

    output ZmodDAC_0_DAC_CLKIN_0,
    output ZmodDAC_0_DAC_CLKIO_0,
    output ZmodDAC_0_DAC_CS_0,
    output [13:0] ZmodDAC_0_DAC_DATA_0,
    output ZmodDAC_0_DAC_EN_0,
    output ZmodDAC_0_DAC_RESET_0,
    output ZmodDAC_0_DAC_SCLK_0,
    inout ZmodDAC_0_DAC_SDIO_0,
    output ZmodDAC_0_DAC_SET_FS1_0,
    output ZmodDAC_0_DAC_SET_FS2_0,


    output ZmodADC_0_SC1_AC_H_0,
    output ZmodADC_0_SC1_AC_L_0,
    output ZmodADC_0_SC2_AC_H_0,
    output ZmodADC_0_SC2_AC_L_0,
    output ZmodADC_0_SC1_GAIN_H_0,
    output ZmodADC_0_SC1_GAIN_L_0,
    output ZmodADC_0_SC2_GAIN_H_0,
    output ZmodADC_0_SC2_GAIN_L_0,
    output ZmodADC_0_SC_COM_H_0,
    output ZmodADC_0_SC_COM_L_0,
    inout ZmodADC_0_sdio_sc_0,
    output ZmodADC_0_cs_sc1_0,
    output ZmodADC_0_sclk_sc_0,
    output ZmodADC_0_ADC_SYNC_0,
    input ZmodADC_0_ADC_DCO_0,
    input [13:0] ZmodADC_0_ADC_DATA_0,
    output ZmodADC_0_CLKIN_ADC_N_0,
    output ZmodADC_0_CLKIN_ADC_P_0,

    output LED,
    output [3:0] JB1M,
    output [3:0] JB5M

    );

    wire clk_100, clk_100_90, clk_400, clk_200, clk_25, clk_1;
    wire [31:0] m_axis_data_tdata;
    wire m_axis_data_tvalid;
    wire [15:0] sin, cos;
    wire [15:0] sigoutx05, sigouty05;
    wire [15:0] sigoutx6, sigouty6;

    wire LED05M, LED6M;


    wire [0:0]aresetn;
    wire [0:0]gpio_out;
    wire FCLK_100;
    wire [31:0]BRAM_PORTB_0_addr;
    wire BRAM_PORTB_0_clk;
    wire [31:0]BRAM_PORTB_0_din;
    wire [31:0]BRAM_PORTB_0_dout;
    wire BRAM_PORTB_0_en;
    wire BRAM_PORTB_0_rst;
    wire [3:0]BRAM_PORTB_0_we;

    wire signed [15:0] shift05_sin;
    wire signed [15:0] shift05_cos;
    wire signed [15:0] shift6_sin;
    wire signed [15:0] shift6_cos;

    reg signed [15:0] channelin;
    reg signed [15:0] channelenlarge;
    reg signed [15:0] channelshift;

    assign LED = LED05M && LED6M;

    wire signed [15:0] channel1;
    wire signed [15:0] channel2;
    
    reg signed [15:0] sin6, cos6;
    reg signed [15:0] sin05, cos05;
    reg signed [15:0] sigout;
    reg m_axis_data_channel = 1'b0;

    
    ////////////////////////////////////////////////////////////////
    //////CLK
    ////////////////////////////////////////////////////////////
    clk_wiz_0 u_clk(
        // Clock out ports
        .clk_100(clk_100),     // output clk_100
        .clk_100_90(clk_100_90),     // output clk_100_90
        .clk_400(clk_400),     // output clk_400
        .clk_200(clk_200),
        .clk_25(clk_25),     // output clk_25
        // Status and control signals
        .reset(rst), // input reset
        // Clock in ports
        .clk_in1(clk_in));      // input clk_in1

    ////////////////////////////////////////////////////////////////
    //////CLK divider
    ////////////////////////////////////////////////////////////
    Clock_divider #(.DIVISOR (100) ) u_clk_divide (
        .clock_in(clk_100),                    //
        .clock_out(clk_1));
    

    ////////////////////////////////////////////////////////////////
    //////DDS
    ////////////////////////////////////////////////////////////
    dds_compiler_0 u_dds (
        .aclk(clk_200),                              // input wire aclk
        .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
        .m_axis_data_tdata(m_axis_data_tdata));    // output wire [31 : 0] m_axis_data_tdata
    

    assign sin[15:0] = m_axis_data_tvalid? m_axis_data_tdata[31:16] : 16'b0;
    assign cos[15:0] = m_axis_data_tvalid? m_axis_data_tdata[15:0] : 16'b0;

    always @(posedge clk_200) begin
        m_axis_data_channel <= ~ m_axis_data_channel;
        if(m_axis_data_channel == 1'b0) begin
            sin05 <= sin;
            cos05 <= cos;
        end
        else begin
            sin6 <= sin;
            cos6 <= cos;
        end
    end

    always @(posedge clk_100) begin
        sigout <= (sin05>>>1) + (sin6>>>1);
    end


    ////////////////////////////////////////////////////////////////
    //////Zmod DAC
    ////////////////////////////////////////////////////////////
    ZmodDAC1411_Controller_0 u_dac (
        .SysClk(clk_100),              // input wire SysClk
        .DacClk(clk_100_90),              // input wire DacClk
        .sRst_n(!rst),              // input wire sRst_n
        .sInitDone_n(),    // output wire sInitDone_n
        .sCh1In(sigout[15:2]),              // input wire [13 : 0] sCh1In
        .sCh2In(channelshift),              // input wire [13 : 0] sCh2In
        .sDAC_EnIn(1'b1),        // input wire sDAC_EnIn
        .sExtCh1Scale(1'b0),  // input wire sExtCh1Scale
        .sExtCh2Scale(1'b0),  // input wire sExtCh2Scale
        .sDAC_CS(ZmodDAC_0_DAC_CS_0),            // output wire sDAC_CS
        .sDAC_SCLK(ZmodDAC_0_DAC_SCLK_0),        // output wire sDAC_SCLK
        .sDAC_SDIO(ZmodDAC_0_DAC_SDIO_0),        // inout wire sDAC_SDIO
        .sDAC_Reset(ZmodDAC_0_DAC_RESET_0),      // output wire sDAC_Reset
        .sDAC_ClkIO(ZmodDAC_0_DAC_CLKIO_0),      // output wire sDAC_ClkIO
        .sDAC_Clkin(ZmodDAC_0_DAC_CLKIN_0),      // output wire sDAC_Clkin
        .sDAC_Data(ZmodDAC_0_DAC_DATA_0),        // output wire [13 : 0] sDAC_Data
        .sDAC_SetFS1(ZmodDAC_0_DAC_SET_FS1_0),    // output wire sDAC_SetFS1
        .sDAC_SetFS2(ZmodDAC_0_DAC_SET_FS2_0),    // output wire sDAC_SetFS2
        .sDAC_EnOut(ZmodDAC_0_DAC_EN_0));     // output wire sDAC_EnOut


    ////////////////////////////////////////////////////////////////
    //////Zmod ADC
    ////////////////////////////////////////////////////////////
    ZmodADC1410_Controller_0 u_adc (
        .SysClk(clk_100),                          // input wire SysClk
        .ADC_InClk(clk_400),                    // input wire ADC_InClk
        .sRst_n(!rst),                          // input wire sRst_n
        .sInitDone_n(),                // output wire sInitDone_n
        .FIFO_EMPTY_CHA(),          // output wire FIFO_EMPTY_CHA
        .FIFO_EMPTY_CHB(),          // output wire FIFO_EMPTY_CHB
        .sCh1Out(channel1),                        // output wire [15 : 0] sCh1Out
        .sCh2Out(channel2),                        // output wire [15 : 0] sCh2Out
        .sCh1CouplingConfig(1'b0),  // input wire sCh1CouplingConfig
        .sCh2CouplingConfig(1'b0),  // input wire sCh2CouplingConfig
        .sCh1GainConfig(1'b1),          // input wire sCh1GainConfig
        .sCh2GainConfig(1'b1),          // input wire sCh2GainConfig
        .sTestMode(1'b0),                    // input wire sTestMode
        .adcClkIn_p( ZmodADC_0_CLKIN_ADC_P_0),                  // output wire adcClkIn_p
        .adcClkIn_n(ZmodADC_0_CLKIN_ADC_N_0),                  // output wire adcClkIn_n
        .adcSync(ZmodADC_0_ADC_SYNC_0),                        // output wire adcSync
        .DcoClk(ZmodADC_0_ADC_DCO_0),                          // input wire DcoClk
        .dADC_Data(ZmodADC_0_ADC_DATA_0),                    // input wire [13 : 0] dADC_Data
        .sADC_SDIO(ZmodADC_0_sdio_sc_0),                    // inout wire sADC_SDIO
        .sADC_CS(ZmodADC_0_cs_sc1_0),                        // output wire sADC_CS
        .sADC_Sclk(ZmodADC_0_sclk_sc_0),                    // output wire sADC_Sclk
        .sCh1CouplingH(ZmodADC_0_SC1_AC_H_0),            // output wire sCh1CouplingH
        .sCh1CouplingL(ZmodADC_0_SC1_AC_L_0),            // output wire sCh1CouplingL
        .sCh2CouplingH(ZmodADC_0_SC2_AC_H_0),            // output wire sCh2CouplingH
        .sCh2CouplingL(ZmodADC_0_SC2_AC_L_0),            // output wire sCh2CouplingL
        .sCh1GainH(ZmodADC_0_SC1_GAIN_H_0),                    // output wire sCh1GainH
        .sCh1GainL(ZmodADC_0_SC1_GAIN_L_0),                    // output wire sCh1GainL
        .sCh2GainH(ZmodADC_0_SC2_GAIN_H_0),                    // output wire sCh2GainH
        .sCh2GainL(ZmodADC_0_SC2_GAIN_L_0),                    // output wire sCh2GainL
        .sRelayComH(ZmodADC_0_SC_COM_H_0),                  // output wire sRelayComH
        .sRelayComL(ZmodADC_0_SC_COM_L_0));                  // output wire sRelayComL
    

    //////////////////////////////////////////////
    ////signalEnhance
    ///////////////////////////////////////////

    always @(posedge clk_100 or posedge rst) begin
        if(rst) begin
            channelin <= 16'd0;
        end
        else begin
            channelin <= channel1;
            channelenlarge <= channelin <<< 0;
            channelshift <= channelenlarge-16'd0;
        end
    end

    ila_2 u_ila2 (
        .clk(clk_100), // input wire clk


        .probe0(channel1), // input wire [15:0]  probe0  
        .probe1(channelshift) // input wire [15:0]  probe1
    );
    ////////////////////////////////////////////////////////////////
    //// demodulate 05MHz
    ////////////////////////////////////////////////////////////////
    demodulationFun #(.bigger1 (2) ) u_demodulation_05M (
        .clk_100(clk_100),
        .clk_1(clk_1),
        .reset(rst),
        .sin(sin05),
        .cos(cos05),
        .sigin(channelshift),
        .shiftsin(shift05_sin),
        .shiftcos(shift05_cos),

        .sigoutx(sigoutx05),
        .sigouty(sigouty05)); 
    
    ////////////////////////////////////////////////////////////////
    //// demodulate 20MHz
    ////////////////////////////////////////////////////////////////
    demodulationFun #(.bigger1 (3) ) u_demodulation_6M(
        .clk_100(clk_100),
        .clk_1(clk_1),
        .reset(rst),
        .sin(sin6),
        .cos(cos6),
        .sigin(channelshift),
        .shiftsin(shift6_sin),
        .shiftcos(shift6_cos),

        .sigoutx(sigoutx6),
        .sigouty(sigouty6));
    

    ////////////////////////////////////////////////////////////////
    //// sigoutput 1MHz
    ////////////////////////////////////////////////////////////////
    SignaloutFun #(.bigger1 (1) ) u_sigout05M(
        .clk_100(clk_100),
        .clk_1(clk_1),
        .reset(rst),
        .clk_25(clk_25),
        .shift1(0),
        .shift2(0),

        .siginx(sigoutx05),
        .siginy(sigouty05),

        .LED(LED05M),
        .JB(JB1M));


    ////////////////////////////////////////////////////////////////
    //// sigoutput 5MHz
    ////////////////////////////////////////////////////////////////
    SignaloutFun #(.bigger1 (1) ) u_sigout6M(
        .clk_100(clk_100),
        .clk_1(clk_1),
        .reset(rst),
        .clk_25(clk_25),
        .shift1(0),
        .shift2(0),

        .siginx(sigoutx6),
        .siginy(sigouty6),

        .LED(LED6M),
        .JB(JB5M));

    ////////////////////////////////////////////////////////////////
    ////// Remove DC function
    ////////////////////////////////////////////////////////////////
    RemoveDCFun u_NoDC(
        .clk(clk_100),                          // input wire clk
        .rst(rst),
        .start(rst1),
        .shift05sin(sigoutx05),          // input wire shift05sin
        .shift05cos(sigouty05), // input wire shift05cos
        .shift6sin(sigoutx6), // input wire shift6sin
        .shift6cos(sigouty6), // input wire shift6cos
        .shiftnew05sin(shift05_sin), // output wire shift
        .shiftnew05cos(shift05_cos), // output wire shift
        .shiftnew6sin(shift6_sin), // output wire shift
        .shiftnew6cos(shift6_cos) // output wire shift
    );







endmodule
