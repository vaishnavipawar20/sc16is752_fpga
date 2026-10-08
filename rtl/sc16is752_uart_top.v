`timescale 1ns/1ps

//==============================================================================
// SC16IS752 UART CHANNEL (complete UART with TX/RX, FIFO, baud gen)
// A single UART channel with:
// - TX path with 64-byte FIFO
// - RX path with 64-byte FIFO + error flags
// - Configurable baud rate divisor
// - Programmable data format (5-8 bits, parity, stop bits)
//==============================================================================

module sc16is752_uart_top (
    input  wire clk,
    input  wire reset,

    // External UART pins
    input  wire rx_pin,
    output wire tx_pin,

    // Host control interface
    input  wire wr_en,
    input  wire rd_en,
    input  wire [7:0] data_in,
    input  wire [7:0] lcr_in,
    input  wire [7:0] mcr_in,
    input  wire [7:0] ier_in,
    input  wire [7:0] fcr_in,

    // Status outputs
    output wire rx_fifo_empty,
    output wire tx_fifo_empty,
    output wire [6:0] rxlvl,
    output wire [6:0] txlvl
);

    // Decoded control signals
    wire [3:0] data_bits;
    wire parity_enable;
    wire parity_odd;
    wire stop_1bit;
    wire stop_2bit;
    wire fifo_enable;
    wire rx_fifo_reset;
    wire tx_fifo_reset;
    wire loopback_enable;

    // Baud generator
    wire baud_tick;
    wire [15:0] divisor;

    // TX path
    wire tx_start;
    wire [7:0] tx_fifo_rd_data;
    wire tx_full, tx_empty;
    wire tx_busy;

    // RX path
    wire [10:0] rx_fifo_wr_data;  // 8 bits data + 3 bits error
    wire [10:0] rx_fifo_rd_data;
    wire rx_full, rx_empty;
    wire rx_valid;
    wire [7:0] rx_data_byte;
    wire rx_framing_error;
    wire rx_parity_error;
    wire rx_break_detected;

    // Example divisor (can be programmed via register interface)
    assign divisor = 16'd521;  // For 9600 baud at 50 MHz clock

    //--------------------------------------------------------------------------
    // Control Word Decoder
    //--------------------------------------------------------------------------
    sc16is752_uart_ctrl u_ctrl (
        .clk(clk),
        .reset(reset),
        .lcr_in(lcr_in),
        .mcr_in(mcr_in),
        .ier_in(ier_in),
        .fcr_in(fcr_in),
        .data_bits(data_bits),
        .parity_enable(parity_enable),
        .parity_odd(parity_odd),
        .stop_1bit(stop_1bit),
        .stop_2bit(stop_2bit),
        .fifo_enable(fifo_enable),
        .rx_fifo_reset(rx_fifo_reset),
        .tx_fifo_reset(tx_fifo_reset),
        .loopback_enable(loopback_enable),
        .rts_enable(),
        .cts_enable(),
        .xon1_enable(),
        .xoff1_enable(),
        .xon_any_enable(),
        .sw_flow_enable()
    );

    //--------------------------------------------------------------------------
    // Baud Rate Generator
    //--------------------------------------------------------------------------
    sc16is752_baudgen u_baudgen (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .divisor(divisor),
        .div_by_1_mode(1'b1),
        .baud_tick(baud_tick)
    );

    //--------------------------------------------------------------------------
    // TX FIFO (64 x 8 bits)
    //--------------------------------------------------------------------------
    sc16is752_tx_buffer u_tx_fifo (
        .clk(clk),
        .reset(tx_fifo_reset),
        .wr_en(wr_en),
        .rd_en(tx_start),
        .wr_data(data_in),
        .rd_data(tx_fifo_rd_data),
        .full(tx_full),
        .empty(tx_empty),
        .count(),
        .txlvl(txlvl)
    );

    //--------------------------------------------------------------------------
    // RX FIFO (64 x 11 bits: 8 data + 3 error flags)
    //--------------------------------------------------------------------------
    // Assemble RX FIFO write data: [error bits | data]
    assign rx_fifo_wr_data = {
        rx_break_detected,
        rx_parity_error,
        rx_framing_error,
        rx_data_byte
    };

    sc16is752_rx_buffer u_rx_fifo (
        .clk(clk),
        .reset(rx_fifo_reset),
        .wr_en(rx_valid),
        .rd_en(rd_en),
        .wr_data(rx_fifo_wr_data),
        .rd_data(rx_fifo_rd_data),
        .full(rx_full),
        .empty(rx_empty),
        .count(),
        .rxlvl(rxlvl)
    );

    //--------------------------------------------------------------------------
    // TX Transmitter
    //--------------------------------------------------------------------------
    // TX starts when FIFO is not empty
    assign tx_start = ~tx_empty;

    sc16is752_uart_tx u_tx (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_fifo_rd_data),
        .data_bits(data_bits),
        .parity_enable(parity_enable),
        .parity_odd(parity_odd),
        .stop_1bit(stop_1bit),
        .stop_2bit(stop_2bit),
        .tx_out(tx_pin),
        .tx_busy(tx_busy)
    );

    //--------------------------------------------------------------------------
    // RX Receiver
    //--------------------------------------------------------------------------
    sc16is752_uart_rx u_rx (
        .clk(clk),
        .reset(reset),
        .rx_in(loopback_enable ? tx_pin : rx_pin),  // Loopback support
        .baud_tick(baud_tick),
        .data_bits(data_bits),
        .parity_enable(parity_enable),
        .parity_odd(parity_odd),
        .stop_1bit(stop_1bit),
        .stop_2bit(stop_2bit),
        .rx_data(rx_data_byte),
        .rx_valid(rx_valid),
        .framing_error(rx_framing_error),
        .parity_error(rx_parity_error),
        .break_detected(rx_break_detected)
    );

    //--------------------------------------------------------------------------
    // Status Outputs
    //--------------------------------------------------------------------------
    assign rx_fifo_empty = rx_empty;
    assign tx_fifo_empty = tx_empty;

endmodule
