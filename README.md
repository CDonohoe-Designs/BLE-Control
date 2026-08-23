# BLE-Control — Low-Power BLE Sensor Platform

I designed **BLE-Control** as a compact, battery-powered embedded hardware platform based on the **STM32WB55**. The project combines USB-C, Li-Po charging and power management, a low-power 3.3 V rail, switched sensor power, motion/environmental sensing and Bluetooth Low Energy hardware on a 4-layer PCB.

My focus was the complete hardware architecture: power, sensing, RF/BLE, USB, PCB layout, programming/debug access and a practical bring-up strategy.

> **Status:** hardware design / portfolio platform. It is not presented as a qualified production product.

## PCB render

<p align="center">
  <img src="./BLE_Control_PCB.PNG" alt="BLE-Control PCB 3D render" width="750">
</p>

## Design files

- **[Complete schematic — PDF](Docs/Schematic/BLE-Control.pdf)**
- **[Altium design source](Hardware/Altium/)**
- **[STM32CubeMX configuration / firmware scaffold](Firmware/BLE_Control/)**
- **[Documentation](Docs/)**

---

## Design highlights

- **STM32WB55** dual-core wireless MCU with integrated BLE radio
- USB-C power and USB Full Speed interface
- **BQ21061** single-cell Li-Po charging / power-path management
- Reverse-battery protection
- **TPS7A02-3.3** low-quiescent-current system regulator
- **TPS22910A** MCU-controlled sensor power rail
- **BMI270** inertial measurement unit
- **TMP117** precision temperature sensor
- **SHTC3** humidity / temperature sensor
- BLE RF matching network and chip antenna
- USB / CC / VBUS ESD and transient protection
- Tag-Connect SWD programming/debug interface
- 4-layer PCB designed in Altium Designer

## System architecture

```text
USB-C / Li-Po
      |
      v
   BQ21061
 charger / power path
      |
      v
  TPS7A02 3.3 V
      |
      +------------------> STM32WB55 + BLE
      |
      v
  TPS22910A
 switched 3V3_SENS
      |
      +--> BMI270
      +--> TMP117
      +--> SHTC3
```

The MCU remains powered from `+3V3_SYS`, while the sensor subsystem can be disconnected using `3V3_SENS`. This lets firmware remove sensor power when measurements are not required.

## Power / charging / USB-C

The power section was designed around USB-C input and single-cell Li-Po operation. It includes:

- BQ21061 charger / power-path controller
- battery reverse-polarity protection
- low-quiescent-current 3.3 V regulation
- switched sensor rail
- PPTC input protection
- VBUS transient protection
- CC-line and USB data ESD protection
- USB common-mode filtering
- shield bleed network

A single-cell Li-Po can approach or fall below the 3.3 V rail near the end of discharge. Because the present design uses an LDO rather than a buck-boost converter, **low-battery regulation headroom is an explicit design trade-off to verify during bring-up**.

## MCU + BLE

The STM32WB55 section includes:

- 32 MHz HSE and 32.768 kHz LSE clocks
- USB Full Speed
- SWD / SWO debug access
- RF matching / filtering
- chip antenna
- local decoupling and test access

The PCB RF area was laid out with attention to the antenna keepout, short matching-network connections, controlled RF routing intent and ground return paths.

## Sensors + I/O

The sensor subsystem contains:

- **BMI270** — 6-axis IMU
- **TMP117** — precision temperature sensor
- **SHTC3** — humidity / temperature sensor

The sensors share I²C and operate from the switched `3V3_SENS` rail. Additional I/O includes a user button, status LED, interrupt lines and hardware test points.

## PCB design

The board was developed in **Altium Designer 25** as a compact 4-layer design. Layout considerations included:

- charger and regulator current loops
- STM32WB55 decoupling
- USB differential routing
- ESD return paths
- RF matching and antenna region
- ground return continuity
- sensor placement
- debug/programming access
- test-point accessibility

## Bring-up strategy

I planned bring-up in stages rather than attempting to power and debug the entire system at once:

1. **Power path** — verify VBUS, battery nodes and `+3V3_SYS` using a current-limited supply.
2. **MCU** — establish SWD programming, clocks, GPIO and reset behaviour.
3. **Charger** — verify USB attachment, battery charging and charger status.
4. **Sensor rail** — enable `3V3_SENS` and verify I²C devices individually.
5. **Power measurements** — measure startup, ripple and active / low-power current.
6. **BLE / RF** — bring up advertising and connection, then evaluate RSSI, packet behaviour and antenna matching.

## Firmware status

The repository currently contains the **STM32CubeMX `.ioc` board configuration** used to define MCU clocks, USB, SWD, I²C pins, sensor interrupts and GPIO assignments.

The BLE application stack and sensor application firmware are **not yet published in this repository**, so the firmware folder should be treated as a bring-up/configuration scaffold rather than a completed firmware implementation.

## Verification status

The design includes a structured schematic-review checklist and planned bench verification for:

- power and charging
- MCU programming / clocks / reset
- I²C sensor communication
- sensor power switching
- USB operation
- BLE / RF behaviour
- power cycling and brownout behaviour

**[View the schematic design review](Docs/Reviews/BLE_Control_Schematic_Review_Design_V1_0.md)**

## Repository structure

```text
BLE-Control/
├── Hardware/
│   └── Altium/
├── Firmware/
│   └── BLE_Control/
├── Docs/
│   ├── Battery/
│   ├── BoM/
│   ├── Datasheets/
│   ├── PCB/
│   ├── Reviews/
│   └── Schematic/
├── BLE_Control_PCB.PNG
└── README.md
```

## Tools

- **Altium Designer 25** — schematic and PCB design
- **STM32CubeMX / STM32CubeIDE** — MCU configuration and embedded development
- **LTspice / Python** — supporting analysis where required
- **Git / GitHub** — source and design documentation

---

This project demonstrates my approach to a complete battery-powered embedded design: **power management + MCU + BLE/RF + sensors + PCB layout + testability + bring-up planning**.
