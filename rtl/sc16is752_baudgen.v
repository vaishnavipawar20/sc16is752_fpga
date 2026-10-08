`timescale 1ns / 1ps

module sc16is752_baudgen #(
    parameter CLOCK_FREQ_HZ = 50000000
) (
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire [15:0] divisor,
    output wire tick
);

    reg [15:0] counter;
    reg        tick_r;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            tick_r  <= 1'b0;
        end else if (enable) begin
            if (divisor == 16'd0) begin
                counter <= 16'd0;
                tick_r  <= 1'b0;
            end else begin
                if (counter >= divisor - 1'b1) begin
                    counter <= 16'd0;
                    tick_r  <= 1'b1;
                end else begin
                    counter <= counter + 1'b1;
                    tick_r  <= 1'b0;
                end
            end
        end else begin
            counter <= 16'd0;
            tick_r  <= 1'b0;
        end
    end

    assign tick = tick_r;

endmodule
