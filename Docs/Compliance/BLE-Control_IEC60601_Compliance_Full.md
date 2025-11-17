# BLE-Control — IEC 60601 Master Compliance Document

**Document ID:** BLEC-60601-COMP-A1  
**Revision:** A1 (Full Expanded Version)  
**Applies to:** BLE-Control Wearable BLE Controller PCB  
**Author:** Caoilte Donohoe  
**Date:** 17/11/2025

---

## 1. DEVICE OVERVIEW & CLASSIFICATION

BLE-Control is a low-voltage, SELV-only external BLE controller that serves as the communication interface to an implantable neuro-stimulation system. It is **not** a patient-applied device.

It includes the following subsystems:

- STM32WB55 microcontroller with integrated BLE radio  
- USB-C powered battery charging and power-path  
- Single-cell Li-Po power source  
- Sensors: TMP117 (skin temperature), BMI270 (IMU), SHTC3 (humidity/temp)  
- Operator I/O: tactile button, LED indicator  
- SWD service interface  
- RF antenna (2450AT18A100E) with π-match for EMC tuning  

### 1.1 Device Classification (IEC 60601)

- No mains exposure on PCB  
- SELV-only architecture (all voltages ≤ 5 V)  
- No patient-applied parts on this PCB  
- Intended for **Professional Healthcare Environment** (IEC 60601-1-2 Class A)  
- External PSU supplies mains isolation & leakage protection  
- BLE-Control is a **subsystem**, not a standalone medical electrical device  

---

## 2. IEC 60601-1 BASIC SAFETY JUSTIFICATION

### 2.1 SELV-Only Architecture

All voltages present on BLE-Control are SELV:

- USB-C VBUS = 5 V  
- Li-Po cell = 4.2 V max  
- Regulated rails = 3.3 V  

No voltage exceeds SELV limits, eliminating electric shock hazards at the PCB level.

### 2.2 Protection Against Overvoltage, Overcurrent & Incorrect Connections

**USB-C Port**

- PPTC (F101) protects against overcurrent faults on `USB_VBUS`.  
- SMF5.0 TVS clamps surge/ESD events on VBUS.  
- CC1/CC2 protected via PESD5V0 ESD diodes.  
- D+ / D– protected via USBLC6-2SC6Y and ACM2012D-900-2P-T00 (ESD + common-mode choke + series resistors).

**Battery Path**

- Reverse FET (Q101) protects against reversed battery insertion on `VBATT_RAW`.  
- Charger IC (BQ21061) enforces JEITA temperature charging profile and current/voltage limits.  
- NTC monitoring via `BAT_NTC_10K` ensures thermal safety of the cell.

**Sensor Rail**

- TPS22910A provides on/off control to isolate sensors under fault.  
- Decoupling and ferrite isolation prevent hazardous thermal conditions by limiting fault currents and localising noise.

### 2.3 Essential Performance

Essential performance for BLE-Control is defined as:

> **“Maintain BLE communication/control to the implant, or fail safe without causing unintended stimulation.”**

MCU provisions:

- Reset, brown-out, and boot behaviour clearly defined.  
- GPIO defaults enforced via pull-ups/downs.  
- BLE subsystem remains operational under EMC stress as far as possible or **reboots into a safe state** (no uncontrolled outputs).  
- No GPIO on this PCB directly drives stimulation hardware; all stimulation safety resides in the implant.

### 2.4 Protection from Mechanical, Fire & Thermal Hazards

- PPTC on USB helps prevent thermal runaway under overcurrent.  
- Charger (BQ21061) and LDO (TPS7A02) power dissipation kept within derated limits.  
- No component expected to exceed safe touch temperatures (per IEC 60601-1 tables) when correctly integrated in the enclosure.  
- Enclosure ensures no operator contact with live electronics or Li-Po pouch.

---

## 3. IEC 60601-1-2 EMC JUSTIFICATION

BLE-Control includes measures for:

- **ESD immunity**: TVS diodes on every external interface (USB, button, RF, CC lines).  
- **Burst immunity**: ferrites, RC networks and decoupling on power and sensor rails.  
- **Surge immunity**: VBUS TVS at USB entry.  
- **Radiated immunity**: RF CPWG geometry, local decoupling and sensor rail isolation.  
- **Conducted RF immunity**: filtering on USB and sensor rails.  
- **Emission control**: π-match for RF, USB filtering, and supply filtering.

The design is intended for **IEC 60601-1-2 Class A** (professional environment) pre-compliance and system-level tuning.

---

## 4. PORT CLASSIFICATION (IEC 60601-1-2)

Per IEC 60601-1-2, ports are classified and tested as follows:

| Port / Interface                 | Classification                   | Notes                               |
|----------------------------------|----------------------------------|-------------------------------------|
| USB-C (VBUS, CC, D+, D–)        | AC/DC SELV Input Port           | External PSU, EMC entry point       |
| Battery Connector               | Internal SELV Power Port        | Not operator-accessible in use      |
| RF Antenna                      | RF Port (Intentional Radiator)  | 2.4 GHz BLE antenna                 |
| Pushbutton                      | Operator-Accessible Control     | ESD-protected operator input        |
| LED Indicator                   | Operator Indicator              | Status only, SELV                   |
| Sensors (I²C)                   | Internal Signal Ports           | On-board, no external leads         |
| SWD Header                      | Service Port Only               | Used for programming/debug only     |

This table forms the basis for the EMC test plan and risk analysis.

---

## 5. PER-SHEET COMPLIANCE JUSTIFICATION

### 5.1 POWER_CHARGE_USB (BLEC-SCH-0001)

**Safety**

- All rails on this sheet are SELV (≤ 5 V).  
- Overcurrent protection via PPTC on USB_VBUS.  
- Surge protection via SMF5.0 TVS on VBUS.  
- Reverse battery protection via FET on VBATT_RAW.  
- Safe charging with temperature monitoring through an NTC thermistor and charger safety limits.

**EMC**

- `USB_VBUS`: TVS + PPTC → supports IEC 61000-4-5 surge, 61000-4-2 ESD.  
- CC lines: PESD5V0 ESD clamps → supports 61000-4-2 contact/air discharge.  
- D+ / D–: USBLC6 ESD, common-mode choke and series resistors → controls emissions and improves ESD/burst immunity.  
- Shield connection via **1 MΩ // 1 nF** to GND → provides RF return path while limiting low-frequency currents on cable shield.

**Example Schematic Note**

**IEC 60601 compliance:**
**USB-C = AC/DC SELV input. Protected via PPTC, TVS, CC ESD, and USBLC6+CMC to support IEC 60601-1-2 (IEC 61000-4-2/-4/-5) surge/ESD/burst requirements.**


---

### 5.2 MCU_RF (BLEC-SCH-0002)

**Safety**

- All MCU pins operate from SELV rails (3.3 V).  
- GPIO pull-ups/downs ensure safe behaviour on reset and during brown-out.  
- No patient connections or applied parts originate on this sheet.

**EMC**

- RF π-match (C-L-C) allows tuning of harmonics and spurs to meet radiated emission limits.  
- RF ESD footprint near antenna feed supports ±8 kV contact ESD robustness.  
- CPWG with via-fence controls RF return and reduces unintended radiation.  
- USB_FS includes 22 Ω series resistors at the MCU pins for edge-rate control and improved ESD immunity together with upstream protection.  
- Internal SMPS pins are tightly decoupled to reduce switching noise injection into digital and RF domains.

**Example Schematic Note**

> **RF port = intentional radiator. Includes π-match and RF ESD footprint. SWD = service-only port. USB_FS lines damped for EMC robustness.**

---

### 5.3 SENSOR_IO_BUTTONS_LED (BLEC-SCH-0003)

**Safety**

- All sensors powered from SELV rails (3.3 V).  
- TMP117 temperature sensor is indirectly coupled to skin via enclosure; no conductive patient connection is present on the PCB.  
- Button and LED are on the enclosure; no direct patient contact to pins.  

**EMC**

- Button network: TVS at pad + 100 Ω series resistor + RC filter → strong immunity to ESD and fast transients, minimising false triggers.  
- Sensor rail isolated via ferrite bead and decoupling → limits conducted RF paths.  
- TPS22910A allows power-cycling of the sensor rail to recover from EMC-induced latch-ups or misbehaviour.  
- I²C lines are short and locally decoupled at each sensor to reduce radiated susceptibility.

**Example Schematic Note**

> **Button protected via TVS+100 Ω+RC. Sensor rail isolated & gated for EMC recovery. No patient-applied parts.**

---

## 6. RISK CONTROLS (ISO 14971)

High-level hardware risk controls mapped to hazards:

| Hazard                         | Risk Control                                     | Implementation                                  |
|--------------------------------|--------------------------------------------------|-------------------------------------------------|
| ESD to USB connector           | ESD + surge clamps                               | SMF5.0, USBLC6, PESD on CC, shield R//C        |
| ESD to button                  | Local TVS + series resistor + RC filtering       | PESD5V0 at pad, 100 Ω, C29, R network          |
| Burst / fast transients       | Ferrites + local decoupling + RC networks        | FBs on rails, C localised, RC on button        |
| Reverse battery connection    | Reverse-protection FET                           | Q101 on VBATT_RAW                               |
| Overcurrent from USB          | PPTC + charger current limits                    | F101 + BQ21061 configuration                    |
| RF interference into sensors  | Isolated sensor rail + decoupling + power gating | FB2, C24, TPS22910A                             |
| RF harmonic emissions         | π-match tuning network                           | C14, L1, C15 (DNP-tuneable)                     |

These map directly into the risk management file (ISO 14971) with detailed hazard→cause→control→verification links.

---

## 7. VERIFICATION & VALIDATION REQUIREMENTS

### 7.1 Electrical Safety Testing

- Verify all accessible circuits are SELV.  
- Measure surface temperatures at maximum load and worst-case ambient.  
- Validate Li-Po charging behaviour (voltage, current, termination, temperature).

### 7.2 EMC Pre-Compliance

Planned pre-compliance tests for BLE-Control within its enclosure:

- Radiated immunity: 80–6000 MHz (per IEC 61000-4-3 as applied in 60601-1-2).  
- Conducted RF: 150 kHz–80 MHz on AC/DC input (via external PSU test setup).  
- ESD: ±8 kV contact / ±15 kV air to user-accessible points (button, enclosure, USB shell).  
- EFT/Burst: on VBUS and relevant lines per 61000-4-4 via the PSU/cable interface.  
- Surge: 61000-4-5 on AC side of PSU; VBUS surge handling verified via TVS/PPTC combination.  

### 7.3 System-Level V&V

At system level (controller + PSU + implant + enclosure):

- Verify BLE communication remains stable or recovers gracefully during EMC exposure.  
- Verify no unintended commands or unsafe stimulation commands are sent under EMC stress.  
- Verify error-handling and watchdog behaviour when faults occur.

---

## 8. BoM REQUIREMENTS FOR MEDICAL COMPLIANCE

The project BoM for BLE-Control includes:

- Manufacturer and MPN for each component  
- Lifecycle status (Active, NRND, Obsolete)  
- Safety relevance (Yes/No)  
- EMC relevance (Yes/No)  
- Approved alternates where appropriate  
- Traceability to schematic reference designators  

**Safety-critical items include:**

- F101 – PPTC on USB_VBUS  
- D101 – VBUS TVS diode  
- USBLC6 ESD array on D+ / D–  
- PESD clamps on button, CC, RF (where fitted)  
- BQ21061 charger IC  
- TPS7A02 LDO  
- RF antenna and match components influencing emissions  

Changes to these parts require **impact assessment** against IEC 60601-1, 60601-1-2, and ISO 14971 risk controls.

---

## 9. SYSTEM SAFETY BOUNDARY

BLE-Control is a **SELV-only subsystem**.

- No patient leakage, isolation, or applied-part safety resides on this PCB.  
- Isolation, leakage limits, and stimulation safety are fulfilled by:
  - External medical-grade PSU  
  - Implantable medical device (ASIC + leads)  
  - System enclosure and system-level design  

BLE-Control provides **internal electrical and EMC robustness** per IEC 60601-1-2 **within its SELV safety scope** and interfaces cleanly with the system safety boundary.

---

## 10. CONCLUSION

BLE-Control includes:

- Full SELV architecture  
- Surge/ESD/EMC protections on all ports  
- Battery safety and temperature supervision  
- RF tuning and filtering provisions  
- Sensor isolation and fault recovery mechanisms  
- Safe default GPIO states and predictable reset/boot behaviour  

This document serves as the **full justification** for IEC 60601-1 and IEC 60601-1-2 compliance at the PCB subsystem level, to be used inside the Design History File, Technical File, and EMC/safety design reviews.

---
