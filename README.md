# BLE-Control — Low-Power BLE Sensor Platform

I designed BLE-Control as a compact, battery-powered BLE sensor platform based on the **STM32WB55**. The project combines USB-C charging, Li-Po power management, low-power regulation, motion and environmental sensing, and Bluetooth Low Energy communications on a compact 4-layer PCB.

My focus was on the complete embedded hardware architecture, including power management, sensor integration, RF/BLE considerations, PCB layout, debugging access and hardware/firmware integration.

## PCB Render

<p align="center">
  <img src="./BLE_Control_PCB.PNG" alt="BLE-Control PCB 3D render" width="750">
</p>

## Design Files

**[View Complete Schematic (PDF)](Docs/Schematic/BLE_Control_Schematic.pdf)**

**[Altium Design Files](Hardware/Altium/)**

**[STM32CubeIDE Firmware](Firmware/)**

---

## Design Highlights

- STM32WB55 MCU with integrated Bluetooth Low Energy
- USB-C power and charging interface
- Li-Po battery charging and power-path management
- Low-quiescent-current 3.3 V system supply
- MCU-controlled sensor power rail
- BMI270 inertial measurement unit
- TMP117 precision temperature sensor
- SHTC3 humidity and temperature sensor
- BLE antenna matching network
- USB protection and ESD components
- Tag-Connect SWD programming/debug interface
- 4-layer PCB designed in Altium Designer
- STM32CubeIDE development environment
- Hardware bring-up and verification planning

---

# System Overview

BLE-Control contains three main functional areas:

**Power & Charging → STM32WB55 / BLE → Sensors & I/O**

The architecture was developed around battery operation and low-power control. The main system rail remains available to the STM32WB55, while the sensor rail can be switched by the MCU when measurements are required.

This allows the sensors to be powered down when they are not being used rather than operating continuously.

---

## 1. Power / Charging / USB-C

The power architecture is designed around USB-C input and Li-Po battery operation.

Key components include:

- **BQ21061** battery charger and power-path controller
- Reverse-battery protection
- **TPS7A02-3.3** low-quiescent-current regulator for `+3V3_SYS`
- **TPS22910A** load switch providing the gated `3V3_SENS` sensor rail

The USB-C interface includes:

- PPTC protection
- VBUS TVS protection
- CC-line ESD protection
- USBLC6 protection
- Common-mode choke
- Shield bleed network

The separate `3V3_SENS` rail allows the MCU to remove power from the sensors when they are not required.

---

## 2. MCU + BLE

The design is based on the **STM32WB55**, combining the main embedded processor and Bluetooth Low Energy radio.

The MCU section includes:

- STM32WB55 dual-core wireless MCU
- Bluetooth Low Energy
- USB Full Speed
- 32 MHz HSE
- 32.768 kHz LSE
- STM32WB internal SMPS support
- RF matching network
- Chip antenna
- SWD programming/debug through Tag-Connect

The RF output is routed through the external matching network before reaching the antenna.

---

## 3. Sensors + I/O

The sensor subsystem includes:

- **BMI270** — inertial measurement unit
- **TMP117** — precision temperature sensor
- **SHTC3** — humidity and temperature sensor

The sensors operate from the switched `3V3_SENS` rail and communicate with the STM32WB55 over I²C.

Additional I/O includes:

- User button
- LED status indication
- Debug/programming interface
- Hardware test points

---

# Power Architecture

Power management was an important part of the design.

The main power path is:

**USB-C / Li-Po → BQ21061 → TPS7A02 → +3V3_SYS**

with a separately controlled sensor supply:

**+3V3_SYS → TPS22910A → 3V3_SENS**

This allows the STM32WB55 to remain operational while the sensor subsystem is powered down when it is not needed.

The architecture therefore combines battery charging, power-path management, low-quiescent-current regulation and load switching rather than powering all circuitry continuously from a single rail.

---

# PCB Design

I developed the PCB in **Altium Designer 25** as a compact 4-layer embedded design.

The layout work considered:

- Power-path placement
- Charger and regulator current loops
- STM32WB55 decoupling
- RF component placement
- Antenna region
- USB differential routing
- ESD return paths
- Sensor placement
- Ground return paths
- Programming/debug access
- Test-point accessibility

The objective was to keep the power, RF, digital and sensor functions organised while maintaining a compact board footprint.

The complete schematic and Altium design files are available from the links near the top of this README.

---

# Embedded Development

The firmware development environment is based around **STM32CubeIDE** and the STM32WB55 platform.

The firmware area provides the basis for:

- Board bring-up
- GPIO control
- Sensor power control
- I²C sensor communication
- BLE development
- Programming and debugging

The STM32WB architecture separates the application processor from the wireless coprocessor, providing the foundation for BLE operation while the main MCU handles the application and sensor functions.

→ **[View STM32CubeIDE Firmware](Firmware/)**

---

# Hardware Bring-Up Strategy

I developed a staged bring-up approach so the major subsystems can be verified independently before operating the complete system.

## 1. Verify Power Path and Rails

Power the board from USB-C or a current-limited bench supply and verify:

- `VBUS`
- `VBAT_RAW`
- `VBAT_PROT`
- `PMID`
- `+3V3_SYS`

Check startup behaviour, current consumption, rail stability and ripple before progressing to MCU bring-up.

## 2. STM32WB55 Bring-Up

Program the STM32WB55 through the Tag-Connect SWD interface.

Initial firmware can establish:

- MCU programming
- Clock operation
- GPIO
- LED control
- Basic debugging

## 3. Charger Verification

Verify BQ21061 operation including:

- USB attachment
- Battery charging
- Charge-state transitions
- Interrupt/status behaviour

## 4. Sensor Rail Bring-Up

Assert `SENS_EN` and verify operation of the TPS22910A switched sensor supply.

Confirm `3V3_SENS` and establish I²C communication with:

- TMP117
- BMI270
- SHTC3

## 5. Power Measurements

Measure the main power rails under representative operating conditions.

Areas of interest include:

- Startup behaviour
- Regulator ripple
- Sensor rail switching
- Active current
- Low-power current

## 6. BLE / RF Bring-Up

Once the basic digital and power systems are operational, bring up the BLE interface and evaluate:

- BLE advertising
- Connection stability
- RSSI
- Packet Error Rate
- Antenna matching
- RF performance across representative orientations and distances

---

# Engineering Verification

The design includes provision for structured bench verification rather than relying only on schematic and PCB review.

### Power

- USB-C input behaviour
- Battery charging
- System rail regulation
- Sensor rail switching
- Startup/inrush
- Ripple
- Current consumption

### Digital

- STM32WB55 programming
- Clock operation
- Reset behaviour
- GPIO
- I²C communications
- Sensor identification and data acquisition

### BLE / RF

- Advertising and connection
- RSSI
- Packet Error Rate
- Antenna matching
- RF behaviour

### Robustness

- USB ESD behaviour
- Power cycling
- Brownout behaviour
- Repeated sensor power cycling
- Extended operation

---

# Project Status

This repository documents the hardware architecture, schematic, PCB design and supporting embedded-development material for BLE-Control.

The project is presented as a **development and portfolio platform rather than a qualified production product**. Hardware bring-up, RF characterisation and extended verification are treated separately from the completed design work documented here.

---

# Repository Navigation

### Schematic

**[Complete Schematic — PDF](Docs/Schematic/BLE_Control_Schematic.pdf)**

### Altium Hardware Design

**[Hardware/Altium](Hardware/Altium/)**

Includes the Altium project, schematic source, PCB layout and supporting design material.

### STM32CubeIDE

**[Firmware](Firmware/)**

Contains the STM32WB55 embedded-development material.

### Documentation

**[Docs](Docs/)**

Contains design notes, BOM information and supporting engineering documentation.

---

# Tools Used

**Hardware Design**
- Altium Designer 25

**Embedded Development**
- STM32CubeIDE

**Analysis**
- LTspice
- Python

**Development**
- Git / GitHub

---

# What This Project Demonstrates

BLE-Control demonstrates my approach to developing a compact battery-powered embedded product combining:

**power management + embedded hardware + BLE + sensors + PCB design + hardware/firmware integration**

The emphasis is on treating the individual circuits as parts of a complete system: managing battery power, controlling sensor consumption, integrating the STM32WB55 and BLE radio, providing practical programming/debug access, and planning the hardware bring-up needed to move from PCB design towards a working embedded platform.


