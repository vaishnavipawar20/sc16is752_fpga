`timescale 1ns / 1ps

module ep4ce6_board_top (
    input  wire clk,
    input  wire reset_n,
    input  wire spi_cs_n,
    input  wire spi_sclk,
    input  wire spi_mosi,
    output wire spi_miso,
    output wire txa,
    input  wire rxa,
    output wire txb,
    input  wire rxb,
    output wire irq_n,
    inout  wire [7:0] gpio
);

    // Board-specific pin mapping is intentionally left as a wrapper placeholder.
    // Replace this wrapper with the exact board schematic mapping once available.
    sc16is752_fpga_top u_core (
        .clk(clk),
        .reset_n(reset_n),
        .spi_cs_n(spi_cs_n),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .txa(txa),
        .rxa(rxa),
        .rtsa(),
        .ctsa(1'b0),
        .txb(txb),
        .rxb(rxb),
        .rtsb(),
        .ctsb(1'b0),
        .gpio(gpio),
        .irq_n(irq_n)
    );

endmodule
