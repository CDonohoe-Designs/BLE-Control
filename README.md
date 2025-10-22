# BLE-Control — BLE-Enabled Wearable Controller

A low-power BLE-enabled wearable controller inspired by Capri Medical’s “LUNA-Control” device.

This unit powers and communicates with a miniature implant (e.g. ASIC-based stimulator). The system uses an STM32WB55 MCU with BLE 5.0, battery charging, power monitoring, and debug interface.

---

## Hardware Features

- **MCU:** STM32WB55CGU6 (BLE + Cortex-M4)
- **BLE 5.0** with custom services/advertising
- **Battery system:** LiPo (3.7V), charge via BQ25120 or MCP73831
- **Regulation:** 3.3 V LDO with enable pin
- **USB-C / UART debug**
- **Button + LED for user control**
- **Sensor-ready I²C/SPI interface**

---

## Firmware Features

- BLE Peripheral mode, advertising under name: `BLE-Control`
- Low-power STOP mode with wake on button press
- UART/USB debug output
- LED blink for status
- Ready for BLE services: implant handshake, sensor push, firmware update

---

## Repo Structure

- `Hardware/`: Schematic, PCB image, Altium project (in future releases)
- `Firmware/`: STM32CubeIDE or Arduino code, BLE logic
- `Report/`: PDF overview and system block diagrams
- `Simulation/`: Optional — power budget or BLE range model

---

## BLE Interface Preview

- UUID: 1234ABCD-5678-9ABC-DEF0-1234567890AB
- Characteristics:
  - `0x01`: Device status
  - `0x02`: Implant trigger / handshake
  - `0x03`: Battery level
