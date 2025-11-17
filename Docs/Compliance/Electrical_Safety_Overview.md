# BLE-Control — Electrical Safety Overview (IEC 60601-1)

**Document ID:** BLEC-ELEC-SAFETY-A0  
**Revision:** A0  
**Applies to:** BLE-Control Wearable BLE Controller PCB  
**Author:** Caoilte Donohoe  
**Date:** 17/11/2025

---

## 1. Purpose

This document summarises the **electrical safety concept** of the BLE-Control PCB relative to **IEC 60601-1**.  
It defines the voltage domains, safety boundaries, protective components, and assumptions about the external power supply and implant system.

BLE-Control is a **low-voltage, SELV-only external controller**, not a standalone mains-powered medical device and not a patient-applied part.

---

## 2. Voltage Levels and Insulation Concept

### 2.1 SELV-Only Architecture

All voltages present on the BLE-Control PCB are **SELV (Safety Extra-Low Voltage)**:

- USB-C VBUS: nominal **5 V**  
- Li-Po cell: maximum **4.2 V**  
- Regulated rails: **+3V3_SYS** and **+3V3_SENS** (3.3 V)  

There are:

- **No mains voltages**  
- **No hazardous live parts**  
- **No applied parts** connected to the patient from this PCB  

The **mains isolation, creepage/clearance, and patient leakage limits** specified by IEC 60601-1 are realised by:

- The **external medical-grade PSU** (USB supply or adapter), and  
- The **implantable device** and its own isolation barriers.

BLE-Control is strictly within the **SELV side** of the system.

---

## 3. Power Inputs and Protection

### 3.1 USB-C Power Input (VBUS)

The USB-C connector brings in a 5 V SELV supply. Safety-related protections:

- **PPTC resettable fuse (F101)** on `USB_VBUS`:
  - Limits current during faults (shorts, internal failure).
- **TVS diode (SMF5.0)** on VBUS:
  - Clamps surge and ESD events.
- **ESD protection on CC and data lines:**
  - PESD devices on CC1/CC2.
  - USBLC6 on D+/D–.
- **Cable shield:**
  - Referenced to PCB ground via **R || C** network  
    (typically 1 MΩ // 1 nF) to control shield currents and ESD paths.

**Safety intent:**  
If the external PSU or cable misbehaves (transients, surge, short), BLE-Control:

- Limits fault current  
- Clamps overvoltage at the input stage  
- Avoids hazardous overheating

### 3.2 Battery Input

The Li-Po battery connects at the **VBAT_RAW** node.

Safety-related protections:

- **Reverse-polarity FET**:
  - Prevents current flow if battery is connected backwards.
- **Charger IC (BQ21061)**:
  - Limits charge current and voltage.
  - Monitors battery temperature via NTC input.
  - Supports JEITA-style temperature-based charge derating.
- **Pack-level protection**:
  - It is assumed a **single-cell Li-Po pack with integrated protection** (overcurrent / over-voltage / undervoltage) is used.

**Safety intent:**  
Prevent overheating, overcharging, and damage to the cell or PCB under normal and foreseeable misuse (reverse connection).

---

## 4. Internal Rails and Domain Separation

### 4.1 +3V3_SYS (System Rail)

This rail powers:

- MCU core and digital I/O  
- Charger logic / status  
- BLE RF section (through internal regulators)

Safety-related aspects:

- Decoupled and filtered from VBUS by the charger/power-path IC.  
- Current limited indirectly by charger configuration and PPTC on VBUS.  
- No direct patient or mains connection.

### 4.2 +3V3_SENS (Sensor Rail)

This rail powers:

- TMP117 (temperature)  
- BMI270 (IMU)  
- SHTC3 (humidity/temperature)  
- Any other on-board sensors

Generated via:

- **TPS22910A load switch (SENS_EN)** from +3V3_SYS  
- **Ferrite bead** + local decoupling

Safety intent:

- Allows **power-gating** of the sensor domain for:
  - Reduced EMC susceptibility
  - Recovery from latch-ups
  - Energy saving
- Ensures sensor power is clean and controlled.

---

## 5. Control Signals and Logic States

### 5.1 Deterministic Boot (BOOT0, NRST)

- **BOOT0**:
  - Pulled down via 100 kΩ.
  - Ensures MCU boots from User Flash by default.
- **NRST**:
  - 10 kΩ pull-up and RC network for controlled reset.
  - Ensures stable start-up even during disturbances on power rails.

These prevent unsafe or undefined behaviour on reset and at power-up.

### 5.2 Power Control Signals

- **CE_MCU**:
  - Controls charger / power-path enable.
  - Pulled up (≈100 kΩ) so power-path is **ON by default** (safe behaviour).
- **SENS_EN**:
  - Controls TPS22910A sensor rail switch.
  - Defaults low (internal pulldown) → sensors start **OFF**.
  - Prevents unintended sensor activity at power-up.

---

## 6. Protection Against Electrical Hazards

Even though BLE-Control is SELV-only, the design still mitigates:

1. **Overcurrent**
   - PPTC on VBUS
   - Charger current limiting
   - Appropriate track widths and copper areas

2. **Overvoltage / Surge**
   - TVS on VBUS and other exposed lines
   - ESD arrays on USB and button lines

3. **Reverse Polarity**
   - Reverse FET on battery input

4. **Excessive Power Dissipation**
   - Derated charger current
   - Thermal coupling via copper areas
   - External PSU expected to be current-limited

5. **Floating Inputs / Undefined States**
   - Explicit pull-ups/downs on key GPIOs:
     - BOOT0, interrupts, button, charger INT, I²C lines
   - Unused pins handled in firmware (analog mode)

---

## 7. Relationship to IEC 60601-1 Requirements

### 7.1 Basic Safety

Basic safety for the **overall system** (patient isolation, mains creepage, leakage currents) is largely handled by:

- The external medical-grade PSU  
- The implantable neuro-stimulation system

BLE-Control contributes to basic safety by:

- Staying within SELV limits  
- Robust input protection (USB, button)  
- Avoiding overheating under single-fault conditions in its own circuitry  

### 7.2 Essential Performance

Essential performance (as defined in the IEC 60601 Compliance document) is:

> Maintain BLE communication/control with the implant, or fail safe (e.g. loss of communication without sending unsafe commands).

Electrical safety design supports this by:

- Ensuring deterministic reset and boot behaviour  
- Preventing ESD/burst from forcing uncontrolled logic states  
- Maintaining power integrity to MCU and RF under expected disturbances  

---

## 8. Assumptions and System-Level Dependencies

BLE-Control relies on the following **system-level assumptions**:

1. **External PSU**:
   - Compliant with IEC 60601-1 / IEC 62368-1  
   - Provides isolation from mains and patient circuits  
   - Meets required creepage/clearance and leakage current limits

2. **Battery Pack**:
   - Single Li-Po cell with integrated protection (OCP/OVP/UVP)  
   - Installed according to polarity and mechanical keying

3. **Enclosure**:
   - Non-conductive or suitably insulated around user-accessible areas  
   - Provides required mechanical protection and ingress protection as needed

4. **Implant System**:
   - Responsible for **stimulation safety**, patient isolation, and control algorithms  
   - Uses BLE-Control only as a communication peripheral

---

## 9. Conclusion

From an electrical safety standpoint, BLE-Control:

- Operates entirely within SELV limits  
- Provides overcurrent, overvoltage, and reverse-polarity protection  
- Uses deterministic boot/reset and well-defined GPIO biasing  
- Avoids floating inputs and unstable states  
- Segregates sensor power for better control and EMC robustness  

The PCB, when used with a compliant external PSU and suitably designed implant system and enclosure, is consistent with the **electrical safety expectations of IEC 60601-1** at the subsystem level.

---

_End of Electrical_Safety_Overview.md_
