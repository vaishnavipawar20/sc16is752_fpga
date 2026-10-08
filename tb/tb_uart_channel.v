`timescale 1ns / 1ps

module tb_sc16is752_spi;

    reg clk;
    reg reset_n;
    reg cs_n;
    reg sclk;
    reg mosi;
    wire miso;

    sc16is752_fpga_top dut (
        .clk(clk),
        .reset_n(reset_n),
        .spi_cs_n(cs_n),
        .spi_sclk(sclk),
        .spi_mosi(mosi),
        .spi_miso(miso),
        .txa(),
        .rxa(1'b1),
        .rtsa(),
        .ctsa(1'b1),
        .txb(),
        .rxb(1'b1),
        .rtsb(),
        .ctsb(1'b1),
        .gpio(),
        .irq_n()
    );

    initial begin
        clk = 1'b0;
        reset_n = 1'b0;
        cs_n = 1'b1;
        sclk = 1'b0;
        mosi = 1'b0;
        #20 reset_n = 1'b1;
        #100;
        $display("SPI tb started");
        $finish;
    end

    always #5 clk = ~clk;
    always #10 sclk = ~sclk;

endmodule
