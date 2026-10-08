`timescale 1ns / 1ps

module tb_sc16is752_single_top;

    reg clk;
    reg reset_n;
    reg spi_cs_n;
    reg spi_sclk;
    reg spi_mosi;
    wire spi_miso;

    wire txa;
    reg  rxa;
    wire rtsa;
    reg  ctsa;
    wire txb;
    reg  rxb;
    wire rtsb;
    reg  ctsb;
    wire [7:0] gpio;
    wire irq_n;

    sc16is752_fpga_top dut (
        .clk(clk),
        .reset_n(reset_n),
        .spi_cs_n(spi_cs_n),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .txa(txa),
        .rxa(rxa),
        .rtsa(rtsa),
        .ctsa(ctsa),
        .txb(txb),
        .rxb(rxb),
        .rtsb(rtsb),
        .ctsb(ctsb),
        .gpio(gpio),
        .irq_n(irq_n)
    );

    // Simple clock generation.
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // SPI clock generation.
    initial begin
        spi_sclk = 1'b0;
        forever #20 spi_sclk = ~spi_sclk;
    end

    task spi_write_byte;
        input [7:0] data;
        integer i;
        begin
            spi_cs_n = 1'b0;
            for (i = 7; i >= 0; i = i - 1) begin
                spi_mosi = data[i];
                #20;
            end
            #20;
            spi_cs_n = 1'b1;
            spi_mosi = 1'b0;
        end
    endtask

    initial begin
        reset_n = 1'b0;
        spi_cs_n = 1'b1;
        spi_mosi = 1'b0;
        rxa = 1'b1;
        ctsa = 1'b1;
        rxb = 1'b1;
        ctsb = 1'b1;

        #50;
        reset_n = 1'b1;

        // Basic reset check.
        #50;
        $display("[TB] Reset deasserted, starting SPI checks");

        // Example: send a dummy command byte to the SPI slave.
        // This is intentionally minimal and meant as a project starter.
        spi_write_byte(8'h00);
        #50;

        $display("[TB] Simulation complete");
        $finish;
    end

endmodule
