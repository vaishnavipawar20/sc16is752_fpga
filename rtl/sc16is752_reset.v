`timescale 1ns / 1ps

module sc16is752_reset (
    input  wire clk,
    input  wire reset_n,
    output wire reset_sync,
    output wire reset_sync_n
);

    reg [1:0] reset_ff;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            reset_ff <= 2'b00;
        end else begin
            reset_ff <= {reset_ff[0], 1'b1};
        end
    end

    assign reset_sync = ~reset_ff[1];
    assign reset_sync_n = reset_ff[1];

endmodule
