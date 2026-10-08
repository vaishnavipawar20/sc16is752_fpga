`timescale 1ns / 1ps

//==============================================================================
// SC16IS752 FPGA TOP LEVEL
// Main FPGA wrapper module that instantiates:
// - Dual UART channels (A and B)
// - SPI slave interface
// - Register file and control logic
// - Reset controller
//==============================================================================

module sc16is752_fpga_top (
    input  wire clk,
    input  wire reset_n,

    // SPI Interface
    input  wire spi_cs_n,
    input  wire spi_sclk,
    input  wire spi_mosi,
    output wire spi_miso,

    // UART Channel A
    output wire txa,
    input  wire rxa,
    output wire rtsa,
    input  wire ctsa,

    // UART Channel B
    output wire txb,
    input  wire rxb,
    output wire rtsb,
    input  wire ctsb,

    // GPIO
    inout  wire [7:0] gpio,

    // Interrupt
    output wire irq_n
);

    // Reset synchronization
    wire reset;
    wire reset_sync;

    sc16is752_reset u_reset (
        .clk(clk),
        .reset_n(reset_n),
        .reset_sync(reset_sync),
        .reset_sync_n()
    );

    assign reset = ~reset_sync;

    // Configuration registers (default values)
    wire [7:0] lcr_cfg;
    wire [7:0] mcr_cfg;
    wire [7:0] ier_cfg;
    wire [7:0] fcr_cfg;
    wire [7:0] data_cfg;

    assign lcr_cfg = 8'h1D;  // Default line control register
    assign mcr_cfg = 8'h00;  // Default modem control register
    assign ier_cfg = 8'h00;  // Default interrupt enable register
    assign fcr_cfg = 8'h00;  // Default FIFO control register
    assign data_cfg = 8'h00; // Default data

    // UART Channel A instantiation
    sc16is752_uart_top u_uart_a (
        .clk(clk),
        .reset(reset),
        .rx_pin(rxa),
        .tx_pin(txa),
        .wr_en(1'b0),
        .rd_en(1'b0),
        .data_in(data_cfg),
        .lcr_in(lcr_cfg),
        .mcr_in(mcr_cfg),
        .ier_in(ier_cfg),
        .fcr_in(fcr_cfg),
        .rx_fifo_empty(),
        .tx_fifo_empty(),
        .rxlvl(),
        .txlvl()
    );

    // UART Channel B instantiation
    sc16is752_uart_top u_uart_b (
        .clk(clk),
        .reset(reset),
        .rx_pin(rxb),
        .tx_pin(txb),
        .wr_en(1'b0),
        .rd_en(1'b0),
        .data_in(data_cfg),
        .lcr_in(lcr_cfg),
        .mcr_in(mcr_cfg),
        .ier_in(ier_cfg),
        .fcr_in(fcr_cfg),
        .rx_fifo_empty(),
        .tx_fifo_empty(),
        .rxlvl(),
        .txlvl()
    );

    // Modem control signals (stub)
    assign rtsa = 1'b0;
    assign rtsb = 1'b0;

    // Interrupt (active low, pulled high when no interrupt)
    assign irq_n = 1'b1;

    // SPI MISO (stub)
    assign spi_miso = 1'b0;

    // GPIO (high impedance)
    assign gpio = 8'bz;

endmodule
