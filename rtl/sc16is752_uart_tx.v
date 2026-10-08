`timescale 1ns / 1ps

module sc16is752_uart_tx (
    input  wire clk,
    input  wire reset,
    input  wire tx_enable,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    input  wire [3:0] data_bits,
    input  wire parity_en,
    input  wire parity_odd,
    input  wire stop_bits_1,
    input  wire stop_bits_2,
    input  wire baud_tick,
    output reg  tx_out,
    output reg  tx_busy,
    output reg  tx_fifo_empty
);

    localparam TX_IDLE = 2'd0;
    localparam TX_START = 2'd1;
    localparam TX_DATA = 2'd2;
    localparam TX_STOP = 2'd3;

    reg [1:0] state;
    reg [3:0] bit_count;
    reg [7:0] shifter;
    reg       parity_bit;
    reg [1:0] stop_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= TX_IDLE;
            bit_count    <= 4'd0;
            tx_out       <= 1'b1;
            tx_busy      <= 1'b0;
            tx_fifo_empty <= 1'b1;
            shifter      <= 8'd0;
            parity_bit   <= 1'b0;
            stop_count   <= 2'd0;
        end else begin
            if (tx_start && (state == TX_IDLE)) begin
                shifter <= tx_data;
                state   <= TX_START;
                tx_busy <= 1'b1;
                tx_fifo_empty <= 1'b0;
                bit_count <= 4'd0;
                parity_bit <= 1'b0;
                stop_count <= 2'd0;
                tx_out <= 1'b0;
            end else if (baud_tick) begin
                case (state)
                    TX_IDLE: begin
                        tx_out <= 1'b1;
                        tx_busy <= 1'b0;
                    end
                    TX_START: begin
                        tx_out <= 1'b0;
                        state <= TX_DATA;
                        bit_count <= 4'd0;
                    end
                    TX_DATA: begin
                        if (bit_count < data_bits) begin
                            tx_out <= shifter[0];
                            shifter <= {1'b0, shifter[7:1]};
                            bit_count <= bit_count + 1'b1;
                        end else begin
                            if (parity_en) begin
                                tx_out <= parity_odd ^ ^shifter;
                                state <= TX_STOP;
                            end else begin
                                state <= TX_STOP;
                                tx_out <= 1'b1;
                            end
                        end
                    end
                    TX_STOP: begin
                        tx_out <= 1'b1;
                        if (stop_bits_2) begin
                            if (stop_count < 2'd1) begin
                                stop_count <= stop_count + 1'b1;
                            end else begin
                                state <= TX_IDLE;
                                stop_count <= 2'd0;
                                tx_busy <= 1'b0;
                                tx_fifo_empty <= 1'b1;
                            end
                        end else begin
                            state <= TX_IDLE;
                            tx_busy <= 1'b0;
                            tx_fifo_empty <= 1'b1;
                        end
                    end
                    default: begin
                        state <= TX_IDLE;
                    end
                endcase
            end
        end
    end

endmodule
