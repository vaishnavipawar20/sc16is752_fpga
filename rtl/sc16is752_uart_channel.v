`timescale 1ns / 1ps

module sc16is752_uart_channel (
    input  wire clk,
    input  wire reset,
    input  wire [15:0] divisor,
    input  wire baud_enable,
    input  wire [7:0] tx_fifo_data,
    input  wire tx_fifo_write,
    input  wire rx_input,
    output wire tx_output,
    output wire tx_busy,
    output wire rx_valid,
    output wire [7:0] rx_data,
    output wire framing_error,
    output wire parity_error,
    output wire break_detected
);

    wire baud_tick;
    wire tx_start;
    wire [7:0] tx_data_internal;
    wire rx_valid_internal;
    wire [7:0] rx_data_internal;

    sc16is752_baudgen #(
        .CLOCK_FREQ_HZ(50000000)
    ) u_baud (
        .clk(clk),
        .reset(reset),
        .enable(baud_enable),
        .divisor(divisor),
        .tick(baud_tick)
    );

    sc16is752_uart_tx u_tx (
        .clk(clk),
        .reset(reset),
        .tx_enable(baud_enable),
        .tx_start(tx_fifo_write),
        .tx_data(tx_fifo_data),
        .data_bits(4'd8),
        .parity_en(1'b0),
        .parity_odd(1'b0),
        .stop_bits_1(1'b1),
        .stop_bits_2(1'b0),
        .baud_tick(baud_tick),
        .tx_out(tx_output),
        .tx_busy(tx_busy),
        .tx_fifo_empty()
    );

    sc16is752_uart_rx u_rx (
        .clk(clk),
        .reset(reset),
        .rx_input(rx_input),
        .baud_tick(baud_tick),
        .data_bits(4'd8),
        .parity_en(1'b0),
        .parity_odd(1'b0),
        .stop_bits(2'd0),
        .rx_data(rx_data_internal),
        .rx_valid(rx_valid_internal),
        .framing_error(framing_error),
        .parity_error(parity_error),
        .break_detected(break_detected)
    );

    assign rx_valid = rx_valid_internal;
    assign rx_data = rx_data_internal;

endmodule
