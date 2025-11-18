# BLE-Control — Safety Analysis (ISO 14971 Summary)

**Document ID:** BLEC-SAF-ISO14971-A0  
**Revision:** A0  
**Applies to:** BLE-Control Wearable BLE Controller PCB  
**Author:** Caoilte Donohoe  
**Date:** 17/11/2025

---

## 1. Purpose and Scope

This document provides a **hardware-focused safety analysis** for the BLE-Control PCB in the context of **ISO 14971** (application of risk management to medical devices).

- BLE-Control is a **SELV-only external controller** used to communicate with an implantable neuro-stimulation system.
- It is **not** a patient-applied device and contains **no mains** or hazardous voltages.
- System-level risks (stimulation safety, implant leakage, clinical risks) are handled in the **implant system risk management file**.  
- This document covers **safety risks associated with the BLE-Control PCB itself**, especially:
  - Electrical safety of ports and power paths
  - EMC-related functional safety (mis-operation under disturbances)
  - Battery-related hazards within the BLE-Control boundary

---

## 2. References

- ISO 14971 — Medical devices — Application of risk management to medical devices  
- IEC 60601-1 — Medical electrical equipment — Part 1: General requirements for basic safety and essential performance  
- IEC 60601-1-2 — Medical electrical equipment — Part 1-2: EMC requirements  
- BLE-Control IEC 60601 Master Compliance Document (`BLE-Control_IEC60601_Compliance_Full.md`)  
- BLE-Control schematics:
  - `BLEC-SCH-0001` Power_Charge_USB  
  - `BLEC-SCH-0002` MCU_RF  
  - `BLEC-SCH-0003` Sensor_IO_Buttons_LED  

---

## 3. Device Role and Safety Boundary

### 3.1 Role in System

BLE-Control:

- Provides **BLE communication and control** to an implantable device.
- Supervises local sensors (skin temperature, IMU, humidity) and a user button.
- Has **no direct electrical connection to the patient**.

Essential performance of BLE-Control (from IEC 60601 analysis):

> Maintain BLE communication/control to the implant, or fail safe without causing unintended stimulation.

### 3.2 Safety Boundary

Within ISO 14971 terms:

- BLE-Control is a **subsystem** with a safety boundary defined by:
  - USB-C input (SELV)  
  - Battery connector (SELV)  
  - Antenna port (RF only)  
  - Enclosure interface (button, LED, sensors)  
  - SWD service header  

- **Outside this boundary**:
  - Mains isolation & leakage control → external PSU  
  - Stimulation safety & clinical risks → implant system + overall system risk file  

This document therefore focuses on **risks internal to BLE-Control** that could:

- Lead to **loss of essential performance**, or
- Contribute to **system-level hazards**.

---

## 4. Hazard Identification (Hardware-Focused)

The following table lists **primary hardware hazards** relevant to BLE-Control.

| ID  | Hazard Category         | Short Description                                    |
|-----|-------------------------|------------------------------------------------------|
| H1  | Electrical – Overcurrent| Excess current on USB or battery path               |
| H2  | Electrical – Overvoltage| Surge/ESD/abnormal VBUS damaging circuits           |
| H3  | Electrical – Reverse batt| Battery connected with reversed polarity           |
| H4  | Thermal                 | Excess heating of charger / LDO / PPTC / FET        |
| H5  | EMC – ESD              | ESD to USB, button, enclosure, or antenna           |
| H6  | EMC – Burst/Conducted RF| Disturbances causing mis-operation or resets        |
| H7  | EMC – Radiated RF       | Radio fields causing corrupted control or sensor data|
| H8  | Functional – Reset/Boot | Uncontrolled boot mode or GPIO state on reset       |
| H9  | Functional – BLE Failure| Loss of BLE link under disturbance                  |
| H10 | Data/Sensor integrity   | Corrupted sensor readings due to EMC                |

For each hazard, the subsequent section shows **risk controls implemented on BLE-Control**.

---

## 5. Risk Controls — Summary Table

### 5.1 Hardware Risk Control Overview

| Hazard ID | Risk Control Type     | Implementation on BLE-Control                                 |
|-----------|-----------------------|----------------------------------------------------------------|
| H1        | Protective components | PPTC F101 on USB_VBUS; charger current limits (BQ21061)        |
| H2        | Protective components | SMF5.0 TVS on VBUS; USBLC6 ESD; PESD on CC; layout control     |
| H3        | Design measure        | Reverse FET (Q101) on VBATT_RAW                               |
| H4        | Design + component sel.| Power dissipation budget; PPTC; thermal design; derating      |
| H5        | Protective components | TVS on USB, button, RF; ESD structures on CC & USB data        |
| H6        | Filtering + gating    | Ferrites, decoupling, TPS22910A sensor rail switch            |
| H7        | RF design + tuning    | 50 Ω CPWG; π-match; RF ESD footprint; antenna placement        |
| H8        | Circuit behaviour     | Defined BOOT0, reset network, GPIO pull-ups/downs             |
| H9        | System level + HW     | Robust RF front-end; watchdog in firmware (system level)      |
| H10       | Isolation + recovery  | Sensor rail isolation; local decoupling; possibility to power-cycle sensors |

---

## 6. Detailed Hazard → Control Mapping

### H1: Overcurrent on USB or Battery Path

- **Hazard**: Excessive current could cause overheating of tracks/components and possible damage or early failure.
- **Causes**:
  - Short on USB_VBUS or downstream rails
  - Internal fault in charger circuitry
- **Risk Controls**:
  - PPTC (F101) on USB_VBUS provides foldback during short-circuit faults.
  - Charger IC (BQ21061) enforces max charge current and thermal regulation.
  - Track widths and copper thickness selected for current rating.
- **Residual risk**:  
  - Acceptable, given SELV level and external PSU with its own protections.

---

### H2: Overvoltage / Surge on USB_VBUS

- **Hazard**: Surge/ESD on VBUS could damage BLE-Control or propagate to other subsystems.
- **Causes**:
  - ESD to connector
  - Surge events on external PSU or USB cable
- **Risk Controls**:
  - SMF5.0 TVS on VBUS clamps surge/ESD.
  - PPTC limits surge current.
  - Layout places TVS close to USB connector.
- **Residual risk**:
  - Managed by aligning test levels with IEC 61000-4-2/-4/-5.

---

### H3: Reverse Battery Connection

- **Hazard**: Battery connected backwards causing damage or heating.
- **Cause**: Mis-assembly or incorrect battery pack wiring.
- **Risk Controls**:
  - Q101 reverse FET configuration between VBATT_RAW and VBAT_PROT.
  - Charger IC designed for Li-Po; pack to include its own protection circuit.
- **Residual risk**:
  - Reduced to acceptable by mechanical keying and the FET scheme.

---

### H4: Thermal Hazards (Charger / LDO / PPTC / FET)

- **Hazard**: Excessive component temperature.
- **Causes**:
  - High ambient + charging at maximum current
  - PPTC in continuous fault state
- **Risk Controls**:
  - Charger current-limited by design (and may be configurable).
  - PPTC chosen for appropriate hold/trip current.
  - Thermal layout (copper pour, vias) helps heat spreading.
- **Residual risk**:
  - To be verified by thermal tests at worst-case load and ambient.

---

### H5: ESD Hazards (USB, Button, RF, Enclosure)

- **Hazard**: ESD causes device damage or unsafe states.
- **Causes**:
  - User touching enclosure near button or USB shell
  - Static discharge to antenna or enclosure metalwork
- **Risk Controls**:
  - PESD and USBLC6 ESD diodes on USB data and CC lines.
  - SMF5.0 at VBUS.
  - PESD on button node and optional RF ESD at antenna feed.
  - Shield connected via R||C to control discharge paths.
- **Residual risk**:
  - Device may reset or degrade performance, but hardware is robust against permanent damage within spec.

---

### H6: Burst / Conducted RF Disturbances

- **Hazard**: EFT/burst or conducted RF leads to uncontrolled behaviour or resets.
- **Causes**:
  - Coupling via PSU, USB cable, or internal harness.
- **Risk Controls**:
  - Ferrites and decoupling on key rails (VIN_BQ, 3V3 rails, 3V3_SENS).
  - Local bypass capacitors on MCU, sensors, charger and LDO.
  - Sensor rail isolatable via TPS22910A for recovery if required.
- **Residual risk**:
  - System-level testing required; at board level, controls are proportionate for Class A environment.

---

### H7: Radiated RF Interference

- **Hazard**: RF fields (external or self-generated) compromise BLE link or cause mis-operation.
- **Causes**:
  - External RF sources (WiFi, other radios)
  - Poor antenna match leading to high emissions
- **Risk Controls**:
  - 50 Ω CPWG for RF feed, short trace and via fence.
  - π-match network for tuning radiated emissions and sensitivity.
  - Decoupling on RF supply pins and internal SMPS pins.
- **Residual risk**:
  - Managed by RF tuning, enclosure-level design and system-level EMC tests.

---

### H8: Reset / Boot Misbehaviour

- **Hazard**: On power-up or reset, device enters unintended state or boot mode.
- **Causes**:
  - BOOT0 left floating, poor reset network.
- **Risk Controls**:
  - BOOT0 strapped to GND via resistor with TP access only.
  - Defined pull-ups/downs on critical GPIO lines.
- **Residual risk**:
  - Minimal; start-up behaviour deterministic.

---

### H9: BLE Link Failure Under Disturbance

- **Hazard**: BLE link is lost during EMC stress, potentially affecting system-level function.
- **Controls at Board Level**:
  - Stable RF path, matched antenna and decoupled RF supplies.
  - No direct high-energy coupling paths into RF front end.
- **System Level**:
  - Firmware watchdog and link supervision (outside this PCB’s scope).
- **Residual risk**:
  - Considered acceptable for Class A environment with system-level mitigations.

---

### H10: Sensor Data Integrity

- **Hazard**: Corrupted temperature/IMU/humidity data leads to wrong system decisions.
- **Causes**:
  - EMC-induced noise on I²C or sensor rails
- **Risk Controls**:
  - Short I²C traces and local decoupling.
  - Sensor rail isolation and power-cycling (TPS22910A).
  - No direct patient safety decisions implemented solely on this board’s raw data.
- **Residual risk**:
  - Limited to non-hazardous misreadings; system-level filtering and sanity checks recommended.

---

## 7. Risk Acceptance and Link to IEC 60601

- **All hazards identified** are mitigated to a level consistent with:
  - SELV-only operation per IEC 60601-1  
  - EMC robustness per IEC 60601-1-2 (Class A)  
- Remaining risks are:
  - Primarily **loss or degradation of function**, not direct patient harm.  
  - Addressed further in **system-level risk management** (controller + implant + PSU).

---

## 8. Traceability

This safety analysis should be cross-referenced with:

- **IEC 60601 Compliance Document**: `BLE-Control_IEC60601_Compliance_Full.md`  
- **Schematic Sheets**: BLEC-SCH-0001/0002/0003  
- **BoM**: `BLE-Control_Medical_BoM.xlsx` (safety-critical components flagged)  
- **System Risk Management File** (for the complete medical system)

---

_End of Safety_Analysis_ISO14971.md_
