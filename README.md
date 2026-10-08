# SC16IS752 FPGA RTL Project

This repository contains a Quartus II 13.0 SP1-compatible project skeleton for an FPGA-resident digital model of the NXP SC16IS752 dual-UART. The code here is intentionally staged as a Phase 1 implementation, following the phased plan requested in the design brief.

Important notes:
- This project is a synthesizable Verilog-2001 skeleton, not a claim of full SC16IS752 compatibility.
- The design targets the Intel/Altera Cyclone IV E EP4CE6 family.
- Board-specific pin assignments are left as TODO placeholders because no board schematic or exact required pinout was provided in this session.
- The SPI interface, reset logic, register access plumbing, and a single UART channel are included to establish the baseline architecture.
- The design intentionally avoids FPGA-specific vendor IP and does not rely on SystemVerilog constructs.

## Target platform

- FPGA family: Cyclone IV E
- Target device: EP4CE6E22C8 / EP4CE6C22C8 (exact device name must be verified in the installed Quartus device database)
- Quartus version: Quartus II Web Edition 13.0 SP1
- HDL: Verilog-2001
- Board clock: parameterized; do not hard-code a board oscillator value without verifying the exact board schematic

## Repository layout

- rtl/     : synthesizable RTL modules
- tb/      : testbench files
- quartus/ : Quartus project and QSF files
- docs/    : architecture and validation documentation

## Quick start

1. Open Quartus II 13.0 SP1.
2. Create a new project in the `quartus/` directory.
3. Add the source files under `rtl/`.
4. Set the top-level entity to `sc16is752_fpga_top` or `ep4ce6_board_top` depending on the wrapper you use.
5. Update `quartus/project.qsf` or `PIN_ASSIGNMENT_TEMPLATE.qsf` with the real board pin assignments.
6. Compile the project.

## Included in this phase

- reset controller
- SPI slave skeleton with Mode 0 timing and command framing
- configurable register-access layer
- one reusable UART channel module
- basic TX and RX datapath
- top-level FPGA wrapper and board wrapper skeleton

## Not yet complete in this phase

- full dual-channel SC16IS752 register banking
- full IRQ and interrupt priorities
- complete hardware/software flow control
- GPIO and modem control details
- complete FIFO-depth behavior required by the SC16IS752 datasheet
- full compatibility for dual-UART timing and loopback
- optional I2C / IrDA

## Documentation

See the files in `docs/` for the architecture and verification plan. The docs are intentionally written as a staged implementation guide rather than a claim of full end-product compatibility.

## Important compliance note

This code is structured to follow the requested design process and to keep the digital implementation synthesizable in Quartus II 13.0 SP1. Board-specific IO and exact pin assignments are intentionally left as TODO to avoid fabricating verified pin numbers.

## Next step

The next implementation stage is to extend the register file and UART channel logic to full dual-channel operation, FIFOs, and loopback support before moving on to interrupts and GPIO.
