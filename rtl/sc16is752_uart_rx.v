`timescale 1ns / 1ps

module sc16is752_uart_rx (
    input  wire clk,
    input  wire reset,
    input  wire rx_input,
    input  wire baud_tick,
    input  wire [3:0] data_bits,
    input  wire parity_en,
    input  wire parity_odd,
    input  wire [1:0] stop_bits,
    output reg  [7:0] rx_data,
    output reg  rx_valid,
    output reg  framing_error,
    output reg  parity_error,
    output reg  break_detected
);

    localparam RX_IDLE = 3'd0;
    localparam RX_START = 3'd1;
    localparam RX_DATA = 3'd2;
    localparam RX_PARITY = 3'd3;
    localparam RX_STOP = 3'd4;

    reg [2:0] state;
    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg       sampled_start;
    reg       prev_rx;
    reg [1:0] stop_count;

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
            sampled_start <= 1'b0;
            prev_rx <= 1'b1;
            stop_count <= 2'd0;
        end else begin
            prev_rx <= rx_input;

            if (baud_tick) begin
                case (state)
                    RX_IDLE: begin
                        rx_valid <= 1'b0;
                        if (rx_input == 1'b0 && prev_rx == 1'b1) begin
                            state <= RX_START;
                            bit_count <= 4'd0;
                            sample_start <= 1'b1;
                            stop_count <= 2'd0;
                        end
                    end

                    RX_START: begin
                        if (rx_input == 1'b0) begin
                            state <= RX_DATA;
                            bit_count <= 4'd0;
                            shift_reg <= 8'd0;
                            sampled_start <= 1'b0;
                        end else begin
                            state <= RX_IDLE;
                        end
                    end

                    RX_DATA: begin
                        if (bit_count < data_bits) begin
                            shift_reg[bit_count] <= rx_input;
                            bit_count <= bit_count + 1'b1;
                        end else begin
                            if (parity_en) begin
                                state <= RX_PARITY;
                            end else begin
                                state <= RX_STOP;
                            end
                        end
                    end

                    RX_PARITY: begin
                        if (parity_odd) begin
                            parity_error <= 1'b0;
                        end else begin
                            parity_error <= 1'b0;
                        end
                        state <= RX_STOP;
                    end

                    RX_STOP: begin
                        rx_data <= shift_reg;
                        rx_valid <= 1'b1;
                        if (rx_input == 1'b0) begin
                            framing_error <= 1'b1;
                        end else begin
                            framing_error <= 1'b0;
                        end
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
