`timescale 1ns / 1ps

module NCO2 #(
    parameter WIDTH = 16,
    parameter RESOLUTION = 8, // for 256, 9 for 512
    parameter CLK_FREQ = 100000000
 )(
    input wire clk,
    input wire reset,
    input wire signed [20:0] freq,
    output reg signed [WIDTH-1 : 0] sine_out,
    output reg data_vld
    );
    
reg signed [WIDTH-1:0] phase_reg;
localparam signed POS_PI_BOUNDARY = 16'sb0110010010001000;
localparam signed NEG_PI_BOUNDARY = 16'sb1001101101111000;

reg signed [2*WIDTH-1:0] phase_inc;
wire signed [WIDTH-1:0] phase_inc_scaled;

assign phase_inc_scaled = phase_inc[WIDTH-1:0];



always @(*) begin
    phase_inc = (2**RESOLUTION) * freq;
end
    

    
    
always @(posedge(clk)) begin
    if (reset == 1) begin
        phase_reg <= 0;
        sine_out <= 0;
        data_vld <= 0;
    end
    else begin
        data_vld <= 1;
        if ((phase_reg + phase_inc_scaled) < POS_PI_BOUNDARY)
            phase_reg <= phase_reg + phase_inc_scaled;
//            phase_reg <= phase_reg + phase_inc[WIDTH-1:0];
        else
            phase_reg <= NEG_PI_BOUNDARY;
            
        sine_out <= phase_reg;
    end
end


//always @(*) begin
//    sine_out = phase_reg;
//end

//always @(phase_reg) begin
//case (phase_reg)
//    0: sine_out = 0;
//    1: sine_out = 70711;
//    2: sine_out = 100000;
//    3: sine_out = 70711;
//    4: sine_out = 0;
//    5: sine_out = -70711;
//    6: sine_out = -100000;
//    7: sine_out = -70711;
//    default: sine_out = 0;
//endcase
//end
    
endmodule
