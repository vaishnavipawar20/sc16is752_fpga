`timescale 1ns / 1ps

module sc16is752_fpga_top (
    input  wire clk,
    input  wire reset_n,

    input  wire spi_cs_n,
    input  wire spi_sclk,
    input  wire spi_mosi,
    output wire spi_miso,

    output wire txa,
    input  wire rxa,
    output wire rtsa,
    input  wire ctsa,

    output wire txb,
    input  wire rxb,
    output wire rtsb,
    input  wire ctsb,

    inout  wire [7:0] gpio,
    output wire irq_n
);

    wire reset;
    wire reset_sync;
    wire [7:0] spi_cmd;
    wire [7:0] spi_data;
    wire spi_cmd_valid;
    wire spi_read_req;
    wire spi_write_req;
    wire [7:0] spi_read_data;
    wire [7:0] reg_read_data;
    wire [7:0] spi_addr;
    wire [7:0] spi_data_in;
    wire spi_write_en;
    wire spi_read_en;
    wire [1:0] channel_sel;

    sc16is752_reset u_reset (
        .clk(clk),
        .reset_n(reset_n),
        .reset_sync(reset_sync),
        .reset_sync_n()
    );

    assign reset = ~reset_sync;

    sc16is752_spi_slave u_spi (
        .clk(clk),
        .reset(reset),
        .cs_n(spi_cs_n),
        .sclk(spi_sclk),
        .mosi(spi_mosi),
        .miso(spi_miso),
        .cmd_byte(spi_cmd),
        .data_byte(spi_data),
        .cmd_valid(spi_cmd_valid),
        .read_req(spi_read_req),
        .write_req(spi_write_req),
        .read_data(spi_read_data),
        .host_read_data(reg_read_data)
    );

    sc16is752_register_file u_reg (
        .clk(clk),
        .reset(reset),
        .spi_addr(spi_addr),
        .spi_data_in(spi_data_in),
        .spi_write(spi_write_en),
        .spi_read(spi_read_en),
        .channel_sel(channel_sel),
        .reg_data_out(reg_read_data),
        .divisor_a(),
        .divisor_b(),
        .lcr_a(),
        .lcr_b(),
        .ier_a(),
        .ier_b(),
        .spr_a(),
        .spr_b(),
        .thr_a(),
        .thr_b()
    );

    wire [15:0] ch_a_divisor;
    wire [7:0] ch_a_tx_data;
    wire ch_a_baud_enable;
    wire ch_a_tx_busy;
    wire ch_a_rx_valid;
    wire [7:0] ch_a_rx_data;

    sc16is752_uart_channel u_uart_a (
        .clk(clk),
        .reset(reset),
        .divisor(ch_a_divisor),
        .baud_enable(ch_a_baud_enable),
        .tx_fifo_data(ch_a_tx_data),
        .tx_fifo_write(1'b0),
        .rx_input(rxa),
        .tx_output(txa),
        .tx_busy(ch_a_tx_busy),
        .rx_valid(ch_a_rx_valid),
        .rx_data(ch_a_rx_data),
        .framing_error(),
        .parity_error(),
        .break_detected()
    );

    assign rtsa = 1'b0;
    assign txb = 1'b1;
    assign rtsb = 1'b0;
    assign irq_n = 1'b1;
    assign gpio = 8'bz;

endmodule
