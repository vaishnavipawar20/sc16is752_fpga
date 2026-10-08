# SC16IS752 FPGA RTL Architecture

The architecture is intentionally modular so that the SC16IS752 register interface, UART datapath, and SPI slave can be developed independently and validated piece by piece.

```text
                     +---------------------------+
                     |   SC16IS752 FPGA TOP      |
                     |                           |
SPI CS/SCLK/MOSI ---->|  SPI SLAVE                |
MISO <----------------|                           |
                     |                           |
                     +-----------+---------------+
                                 |
                                 v
                    +---------------------------+
                    | REGISTER FILE / COMMAND  |
                    | DECODER                  |
                    +------------+--------------+
                                 |
                 +---------------+----------------+
                 |                                |
                 v                                v
        +------------------+             +------------------+
        | UART CHANNEL A   |             | UART CHANNEL B   |
        |                  |             |                  |
        RXA --------> TX/RX -> TXA   RXB --------> TX/RX -> TXB
        CTSA <------ modem          CTSB <------ modem
        RTSA ------> modem          RTSB ------> modem
        +------------------+             +------------------+
                 |                                |
                 +---------------+----------------+
                                 |
                                 v
                          +------------------+
                          | IRQ / STATUS     |
                          | / FLOW CONTROL   |
                          +------------------+
```

## Core design goals

- Single, synthesizable clock domain with clock-enable based timing
- SPI slave in asynchronous domain with safe synchronization to the main clock
- Register-file abstraction between host interface and UART datapath
- One reusable UART channel module instantiated for each channel
- FIFO logic inferred in memory blocks when possible
- Quartus II 13.0 SP1 compatibility using Verilog-2001 constructs

## Clocking strategy

The implementation uses one primary FPGA system clock and avoids unnecessary derived clocks. SPI SCLK is asynchronous to the FPGA clock and must be treated as an external-domain signal.

## Phase 1 status

This repository currently contains the base architecture needed for:

- reset generation
- SPI command decoding skeleton
- host register access abstraction
- one UART channel datapath structure
- basic TX/RX logic templates

The later phases add FIFO depth, dual-channel instantiation, interrupts, GPIO, and advanced flow-control behavior.
