# Resource Budget (Planned / Estimated)

This document records the target resource plan for the Cyclone IV E EP4CE6 implementation. The project is intentionally designed to be resource-aware and to favor inferred memory over large distributed register arrays.

## EP4CE6 device summary

- Logic elements (LEs): approximately 6000
- Embedded memory: 30 M9K blocks
- Total memory: 270 Kb
- Embedded multipliers: 15
- PLLs: 2

## Planned usage

### Estimated FIFO memory

- TX FIFO A: 64 x 8 bits
- RX FIFO A: 64 x (data + error/status)
- TX FIFO B: 64 x 8 bits
- RX FIFO B: 64 x (data + error/status)

This is expected to fit within M9K blocks when implemented using inferred memory, but actual Quartus mapping must be verified.

### Estimated register logic

- Register file and control decode: moderate
- UART channel control: moderate
- SPI slave: moderate
- Interrupt logic: moderate
- GPIO/modem logic: moderate

## Actual post-synthesis usage

This section is intentionally left as a placeholder for Quartus compilation results.

- Actual LEs used: TBD
- Actual M9K blocks used: TBD
- Actual memory bits used: TBD
- Fmax / timing result: TBD

## Phase 1 note

The skeleton is deliberately conservative to avoid over-allocating FPGA resources while establishing the right architecture. If the final implementation exceeds the target budget, the first optimization step should be FIFO inference and control sharing rather than removing essential functionality.
