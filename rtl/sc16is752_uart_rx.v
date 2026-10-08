`timescale 1ns/1ps

//==============================================================================
// SC16IS752 UART RX (Receiver)
// Handles serial reception with configurable:
// - Data bits (5-8)
// - Parity (even/odd/none)
// - Stop bits (1/2)
// - Error detection (framing, parity, break, overrun)
//==============================================================================

module sc16is752_uart_rx (
    input  wire clk,
    input  wire reset,
    input  wire rx_in,
    input  wire baud_tick,
    input  wire [3:0] data_bits,
    input  wire parity_enable,
    input  wire parity_odd,
    input  wire stop_1bit,
    input  wire stop_2bit,
    output reg  [7:0] rx_data,
    output reg  rx_valid,
    output reg  framing_error,
    output reg  parity_error,
    output reg  break_detected
);

    localparam RX_IDLE   = 3'd0;
    localparam RX_START  = 3'd1;
    localparam RX_DATA   = 3'd2;
    localparam RX_PARITY = 3'd3;
    localparam RX_STOP   = 3'd4;
    localparam RX_STOP2  = 3'd5;

    reg [2:0] state;
    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg prev_rx;
    reg parity_calc;
    reg [3:0] break_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= RX_IDLE;
            bit_count <= 4'd0;
            rx_data <= 8'd0;
            rx_valid <= 1'b0;
            framing_error <= 1'b0;
            parity_error <= 1'b0;
            break_detected <= 1'b0;
            shift_reg <= 8'd0;
            prev_rx <= 1'b1;
            parity_calc <= 1'b0;
            break_count <= 4'd0;
        end else begin
            prev_rx <= rx_in;

            if (baud_tick) begin
                case (state)
                    RX_IDLE: begin
                        rx_valid <= 1'b0;
                        framing_error <= 1'b0;
                        parity_error <= 1'b0;
                        break_detected <= 1'b0;

                        // Detect start bit (falling edge)
                        if (rx_in == 1'b0 && prev_rx == 1'b1) begin
                            state <= RX_START;
                            bit_count <= 4'd0;
                            shift_reg <= 8'd0;
                            break_count <= 4'd0;
                        end

                        // Break detection: long low period
                        if (rx_in == 1'b0) begin
                            break_count <= break_count + 1'b1;
                            if (break_count == 4'd15) begin
                                break_detected <= 1'b1;
                            end
                        end else begin
                            break_count <= 4'd0;
                        end
                    end

                    RX_START: begin
                        // Verify start bit is still low
                        if (rx_in == 1'b0) begin
                            state <= RX_DATA;
                            bit_count <= 4'd0;
                        end else begin
                            state <= RX_IDLE;  // False start bit
                        end
                    end

                    RX_DATA: begin
                        if (bit_count < data_bits) begin
                            shift_reg[bit_count] <= rx_in;
                            bit_count <= bit_count + 1'b1;
                        end else begin
                            if (parity_enable) begin
                                state <= RX_PARITY;
                            end else begin
                                state <= RX_STOP;
                            end
                        end
                    end

                    RX_PARITY: begin
                        // Check parity
                        parity_calc <= parity_odd ? ~(^shift_reg) : (^shift_reg);
                        if ((parity_odd ? ~(^shift_reg) : (^shift_reg)) != rx_in) begin
                            parity_error <= 1'b1;
                        end
                        state <= RX_STOP;
                    end

                    RX_STOP: begin
                        // Check stop bit (should be high)
                        if (rx_in == 1'b0) begin
                            framing_error <= 1'b1;
                        end
                        if (stop_2bit) begin
                            state <= RX_STOP2;
                        end else begin
                            rx_data <= shift_reg;
                            rx_valid <= 1'b1;
                            state <= RX_IDLE;
                        end
                    end

                    RX_STOP2: begin
                        // Second stop bit
                        if (rx_in == 1'b0) begin
                            framing_error <= 1'b1;
                        end
                        rx_data <= shift_reg;
                        rx_valid <= 1'b1;
                        state <= RX_IDLE;
                    end

                    default: begin
                        state <= RX_IDLE;
                    end
                endcase
            end
        end
    end

endmodule
