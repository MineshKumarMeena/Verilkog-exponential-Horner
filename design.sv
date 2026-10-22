
`timescale 1ns/1ps

module exp_horner(
    input clk,
    input rst,
    input start,
    input signed [31:0] x,
    output reg signed [31:0] y,
    output reg done
);

    // Fixed-point constants (Q16.16 format)
    parameter ONE   = 65536;
    parameter HALF  = 32768;
    parameter SIXTH = 10923;  // approx 1/6
    parameter C24   = 2731;   // approx 1/24

    reg [1:0] state;
    reg [1:0] step;

    reg signed [31:0] x_reg;
    reg signed [31:0] temp;

    // Multiply x with the current value
    wire signed [63:0] product;
    assign product = x_reg * temp;

    // Keep the fixed-point result (shift right by 16)
    wire signed [31:0] result;
    assign result = product >>> 16;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            step <= 0;
            x_reg <= 0;
            temp <= 0;
            y <= 0;
            done <= 0;
        end
        else begin
            done <= 0; // default value

            case (state)

                // Wait for start signal from testbench
                0: begin
                    if (start) begin
                        x_reg <= x;
                        temp <= C24;
                        step <= 0;
                        state <= 1; // go to calc state
                    end
                end

                // Calculate the approximation step by step
                1: begin
                    case (step)

                        0: begin
                            temp <= result + SIXTH;
                            step <= 1;
                        end

                        1: begin
                            temp <= result + HALF;
                            step <= 2;
                        end

                        2: begin
                            temp <= result + ONE;
                            step <= 3;
                        end

                        3: begin
                            y <= result + ONE;
                            state <= 2; // finished!
                        end
                        
                        default: step <= 0;

                    endcase
                end

                // Calculation finished, pulse done for 1 cycle
                2: begin
                    done <= 1;
                    state <= 0;
                end

                default: begin
                    state <= 0;
                end

            endcase
        end
    end

endmodule
