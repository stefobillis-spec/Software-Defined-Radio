`timescale 1ns / 1ps

module NCO2 #(
    parameter WIDTH = 19,
    parameter RESOLUTION = 8, // for 256, 9 for 512
    parameter CLK_FREQ = 100000000
 )(
    input wire clk,
    input wire reset,
    input wire signed [25:0] freq,
    input wire [WIDTH-1 : 0] add_phase,
    input wire phase_vld,
    output reg signed [WIDTH-1 : 0] phase_out, // 24 bits
    output reg data_vld
    );
    
reg signed [WIDTH-1:0] phase_reg; // 24 bits
//localparam signed POS_PI_BOUNDARY = 16'sb0110010010001000; // +pi
//localparam signed NEG_PI_BOUNDARY = 16'sb1001101101111000; // -pi

localparam signed POS_PI_BOUNDARY = 19'sb0010000000000000000; // +pi
localparam signed NEG_PI_BOUNDARY = 19'sb1110000000000000000; // -pi


reg signed [2*WIDTH-1:0] phase_inc; // 48 bits
wire signed [WIDTH-1:0] phase_inc_scaled; // 24 bits
reg signed [WIDTH-1:0] add_phase_reg;



// Calculate required FCW from freq
wire [49:0] temp; // Allows up to 50Mhz
wire [23:0] FCW;
reg [23:0] FCW_reg;

assign temp = $unsigned(freq) * 2**(WIDTH-3);
assign FCW =  2*temp/CLK_FREQ;

///////////////////////////////////////



assign phase_inc_scaled = phase_inc[WIDTH-1:0];



always @(*) begin
    phase_inc = FCW_reg;
end
    


always @(posedge(clk)) begin
    if (add_phase != add_phase_reg)
        add_phase_reg <= add_phase;
    else begin
       add_phase_reg <= 0; 
    end
    end


always @(posedge(clk)) begin
    if (reset == 1) begin
        phase_reg <= 0;
        phase_out <= 0;
        data_vld <= 0;
    end
    else begin
        FCW_reg <= FCW;
//        add_phase_reg <= add_phase;
        data_vld <= 1;
        if ((phase_reg + phase_inc_scaled + add_phase_reg) < POS_PI_BOUNDARY)
            phase_reg <= phase_reg + phase_inc_scaled + add_phase_reg;
//            phase_reg <= phase_reg + phase_inc[WIDTH-1:0];
        else
            phase_reg <= NEG_PI_BOUNDARY;
            
        phase_out <= phase_reg;
    end
end


endmodule
