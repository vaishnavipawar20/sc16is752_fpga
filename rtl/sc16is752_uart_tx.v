`timescale 1ns/1ps

//==============================================================================
// SC16IS752 UART TX (Transmitter)
// Handles serial transmission with configurable:
// - Data bits (5-8)
// - Parity (even/odd/none)
// - Stop bits (1/2)
// - Baud rate
//==============================================================================

module sc16is752_uart_tx (
    input  wire clk,
    input  wire reset,
    input  wire baud_tick,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    input  wire [3:0] data_bits,
    input  wire parity_enable,
    input  wire parity_odd,
    input  wire stop_1bit,
    input  wire stop_2bit,
    output reg  tx_out,
    output reg  tx_busy
);

    localparam TX_IDLE   = 3'd0;
    localparam TX_START  = 3'd1;
    localparam TX_DATA   = 3'd2;
    localparam TX_PARITY = 3'd3;
    localparam TX_STOP   = 3'd4;
    localparam TX_STOP2  = 3'd5;

    reg [2:0] state;
    reg [3:0] bit_count;
    reg [7:0] shifter;
    reg parity_bit;
    reg [1:0] stop_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= TX_IDLE;
            bit_count <= 4'd0;
            tx_out <= 1'b1;
            tx_busy <= 1'b0;
            shifter <= 8'd0;
            parity_bit <= 1'b0;
            stop_count <= 2'd0;
        end else if (baud_tick) begin
            case (state)
                TX_IDLE: begin
                    tx_out <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shifter <= tx_data;
                        state <= TX_START;
                        tx_busy <= 1'b1;
                        bit_count <= 4'd0;
                        parity_bit <= 1'b0;
                        stop_count <= 2'd0;
                    end
                end

                TX_START: begin
                    tx_out <= 1'b0;  // Start bit
                    state <= TX_DATA;
                    bit_count <= 4'd0;
                end

                TX_DATA: begin
                    if (bit_count < data_bits) begin
                        tx_out <= shifter[0];
                        shifter <= {1'b0, shifter[7:1]};
                        bit_count <= bit_count + 1'b1;
                    end else begin
                        if (parity_enable) begin
                            state <= TX_PARITY;
                        end else begin
                            state <= TX_STOP;
                        end
                    end
                end

                TX_PARITY: begin
                    // Calculate parity: XOR of all data bits
                    parity_bit <= parity_odd ? ~(^shifter) : (^shifter);
                    tx_out <= parity_odd ? ~(^shifter) : (^shifter);
                    state <= TX_STOP;
                end

                TX_STOP: begin
                    tx_out <= 1'b1;  // Stop bit
                    if (stop_2bit) begin
                        state <= TX_STOP2;
                        stop_count <= 2'd0;
                    end else begin
                        state <= TX_IDLE;
                        tx_busy <= 1'b0;
                    end
                end

                TX_STOP2: begin
                    tx_out <= 1'b1;  // Second stop bit
                    state <= TX_IDLE;
                    tx_busy <= 1'b0;
                end

                default: begin
                    state <= TX_IDLE;
                    tx_out <= 1'b1;
                    tx_busy <= 1'b0;
                end
            endcase
        end
    end

endmodule
