`timescale 1ns / 1ps

module NCO2 #(
    parameter WIDTH = 24,
    parameter CLK_FREQ = 50000000
 )(
    input wire clk,
    input wire reset,
    input wire [25:0] freq,
    input wire [WIDTH-1 : 0] add_phase,
    input wire phase_vld, 
    output reg signed [WIDTH-1 : 0] phase_out, // 24 bits
    output reg data_vld
    );
    
reg signed [WIDTH-1:0] phase_reg; // 24 bits
//localparam signed POS_PI_BOUNDARY = 16'sb0110010010001000; // +pi
//localparam signed NEG_PI_BOUNDARY = 16'sb1001101101111000; // -pi

//localparam signed POS_PI_BOUNDARY = 24'sb001000000000000000000000; // +1 = +pi scaled
//localparam signed NEG_PI_BOUNDARY = 24'sb111000000000000000000000; // -1 = -pi scaled


wire signed [WIDTH-1:0] phase_inc_scaled; // 24 bits 


// Calculate required FCW from freq
//wire [49:0] temp; // Allows up to 50Mhz with 24 bits
//wire [23:0] FCW;
//wire [27:0] round;
reg [23:0] FCW_reg;

////assign temp = $unsigned(freq) * 2**(WIDTH-3);
//assign temp = freq * 2**(WIDTH-3);
//assign round = (2*temp) % CLK_FREQ;


//assign FCW = (round >= CLK_FREQ/2) ? (2*temp/CLK_FREQ+1) :
//              (2*temp/CLK_FREQ);

reg [49:0] temp_reg;
reg [49:0] temp2_reg;
reg [27:0] round_reg;



always @(posedge(clk)) begin
    if (reset == 1) begin
        FCW_reg <= 0;
        temp_reg <=0;
        temp2_reg <=0;
        round_reg <=0;
    end 
    else begin
        temp_reg <= freq << (WIDTH - 2); // (WIDTH - 2)
        round_reg <= temp_reg % CLK_FREQ;
        temp2_reg <= temp_reg / CLK_FREQ;
        if (round_reg >= CLK_FREQ/2) begin
            FCW_reg <= (temp2_reg + 1);
        end
        else begin
            FCW_reg <= temp2_reg;
        end
    end
end




// =====================================================




///////////////////////////////////////

// Phase boundaries
localparam signed [WIDTH-1:0] POS_PI_BOUNDARY = 24'sh200000;
localparam signed [WIDTH-1:0] NEG_PI_BOUNDARY = 24'shE00000;

// One complete revolution (2*pi)
localparam signed [WIDTH:0] TWO_PI = 25'sh400000;

// Signed phase increment


// Extended phase sum
wire signed [WIDTH:0] phase_next;

assign phase_inc_scaled = FCW_reg;

assign phase_next =
    $signed({phase_reg[WIDTH-1], phase_reg}) +
    $signed({phase_inc_scaled[WIDTH-1], phase_inc_scaled});


always @(posedge clk) begin

    if (reset) begin
        phase_reg <= 0;
        phase_out <= 0;
        data_vld <= 0;
//        FCW_reg <= 0;
    end

    else begin

        data_vld <= 1;
//        FCW_reg <= FCW;

        if (phase_vld) begin
            phase_reg <= add_phase;
        end

        else begin

            if (phase_next >= POS_PI_BOUNDARY)
                phase_reg <= phase_next - TWO_PI;

            else if (phase_next < NEG_PI_BOUNDARY)
                phase_reg <= phase_next + TWO_PI;

            else
                phase_reg <= phase_next[WIDTH-1:0];

        end

        phase_out <= phase_reg;

    end
end


//assign phase_inc_scaled = FCW_reg; 


//always @(posedge(clk)) begin
//    if (reset == 1) begin
//        phase_reg <= 0;
//        phase_out <= 0;
//        data_vld <= 0;
//    end
//    else begin
//        data_vld <= 1;
//        FCW_reg <= FCW;
//        if (phase_vld == 1) begin
//            phase_reg <= add_phase;
//        end
//        else begin
//            if ((phase_reg + phase_inc_scaled) < POS_PI_BOUNDARY) 
//                phase_reg <= phase_reg + phase_inc_scaled;
//            else
//                phase_reg <= NEG_PI_BOUNDARY;
//            end
//        phase_out <= phase_reg;
//    end
//end


endmodule
