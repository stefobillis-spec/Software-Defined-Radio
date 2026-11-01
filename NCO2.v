`timescale 1ns / 1ps

module NCO2 #(
    parameter WIDTH = 24,
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

localparam signed POS_PI_BOUNDARY = 24'sb001000000000000000000000; // +1 = +pi scaled
localparam signed NEG_PI_BOUNDARY = 24'sb111000000000000000000000; // -1 = -pi scaled


wire signed [WIDTH-1:0] phase_inc_scaled; // 24 bits 


// Calculate required FCW from freq
wire [49:0] temp; // Allows up to 50Mhz with 24 bits
wire [23:0] FCW;
wire [27:0] round;
reg [23:0] FCW_reg;

assign temp = $unsigned(freq) * 2**(WIDTH-3);
assign round = (2*temp) % CLK_FREQ;


assign FCW = (round >= CLK_FREQ/2) ? (2*temp/CLK_FREQ+1) :
              (round < CLK_FREQ/2) ? (2*temp/CLK_FREQ) : (2*temp/CLK_FREQ);


///////////////////////////////////////



assign phase_inc_scaled = FCW_reg; 


always @(posedge(clk)) begin
    if (reset == 1) begin
        phase_reg <= 0;
        phase_out <= 0;
        data_vld <= 0;
    end
    else begin
        data_vld <= 1;
        FCW_reg <= FCW;
        if (phase_vld == 1) begin
            phase_reg <= add_phase;
        end
        else begin
            if ((phase_reg + phase_inc_scaled) < POS_PI_BOUNDARY) 
                phase_reg <= phase_reg + phase_inc_scaled;
            else
                phase_reg <= NEG_PI_BOUNDARY;
            end
        phase_out <= phase_reg;
    end
end


endmodule
