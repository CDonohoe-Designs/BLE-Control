# BLE-Control — Wearable BLE Controller (Altium AD25 + IEC 60601-style Design)

**BLE-Control** is a low-power wearable controller designed around **STM32WB55**  
(BLE 5 dual-core Cortex-M4/M0+).  
The goal is to demonstrate **robust hardware design, EMC-aware layout, documented power architecture, risk thinking (ISO 14971), and medical-style documentation structure** — suitable for a **professional portfolio** or **design review**.


**BLE-Control** is a small, low-power wearable control board built around **STM32WB55** (BLE 5 + Cortex-M4).  
This is a **portfolio/showcase** design intentionally aligned to **IEC 60601-1** (basic safety & essential performance) and **IEC 60601-1-2 Ed.4** (EMC, **Class A** – professional healthcare environment) habits, with documentation patterns influenced by **ISO 13485** (QMS) and **ISO 14971** (risk).  
> *Not a claim of compliance; design-for-compliance focus only.*

> ⚠️ *Design-for-compliance only — not a medical device.*

---
## 📂 Repository Structure Overview

```text
BLE-Control/
│
├── Docs/                ← Main documentation hub
│   ├── Schematic/
│   ├── BoM/
│   ├── Compliance/
│   ├── Battery/
│   ├── Risk/
│   ├── Reports/
│   └── testing/
│
├── Hardware/
│   └── Altium/          ← Full AD25 hardware project
│
├── Firmware/            ← STM32WB55 firmware (CubeIDE)
│
└── LICENSE_MIT

---

# 🚀 Quick Navigation

### 📘 Full Documentation (start here)
→ **[`Docs/README.md`](Docs/README.md)**  
Structured like a mini **Design History File (DHF)**:

- Schematic (master PDF + overview)  
- Medical-style BoM + component-criticality  
- Safety boundary & 60601 rationale  
- EMC notes & port classification  
- Risk register (ISO 14971)  
- Battery pack documentation  
- Bring-up + AD25 rules

---

### 📐 Hardware (Altium AD25)
→ **[`Hardware/Altium/`](Hardware/Altium/)**  

Includes:

- Complete AD25 project (`.PrjPcb`, `.SchDoc`, `.PcbDoc`)  
- Outputs, Draftsman drawings, OutJobs  
- Component libraries  
- SmartPDF source

---

### 💻 Firmware (STM32WB55)
→ **[`Firmware/`](Firmware/)**  

- STM32CubeIDE project  
- BLE stack integration (CPU2 Wireless Coprocessor)  
- Startup & bring-up code  
- Board support notes

---

### 📊 Key Engineering Docs

- **Schematic (PDF):**  
  → [`Docs/Schematic/BLE-Control_Schematic_Master.pdf`](Docs/Schematic/BLE-Control_Schematic_Master.pdf)

- **Medical BoM:**  
  → [`Docs/BoM/BLE-Control_Medical_BoM.md`](Docs/BoM/BLE-Control_Medical_BoM.md)

- **Risk Register:**  
  → [`Docs/Risk/Risk_Register.md`](Docs/Risk/Risk_Register.md)

- **EMC Notes:**  
  → [`Docs/Reports/EMC_Precompliance_Notes.md`](Docs/Reports/EMC_Precompliance_Notes.md)

---

# 🧩 System Overview

BLE-Control contains three core domains:

### 1. Power / Charging / USB-C

- **BQ21061** charger/power-path  
- Reverse-battery PMOS  
- **TPS7A02-3.3** → `+3V3_SYS`  
- **TPS22910A** → `3V3_SENS` (gated sensor rail)  
- USB-C hardened with:  
  - PPTC  
  - VBUS TVS  
  - CC ESD  
  - USBLC6  
  - Common-mode choke  
  - Shield bleed `1 MΩ // 1 nF C0G`  

### 2. MCU + RF (STM32WB55)

- Dual-core + BLE 5  
- USB FS with 22 Ω series  
- 32 MHz HSE + 32.768 kHz LSE  
- On-chip SMPS with 10 µH + (optional 10 nH helper)  
- RF feed → π-match (DNP default) → Johanson antenna  
- SWD via **Tag-Connect TC2030-CTX-NL**

### 3. Sensors + I/O

- TMP117 (precision temperature)  
- BMI270 (IMU)  
- SHTC3 (humidity/T)  
- All on **3V3_SENS** gated by MCU  
- Button with ESD + RC + 100 Ω  
- LED indicator (active-low)  

---

# 🛡 Design-for-Compliance Highlights

*(Not certified; reflects professional habits and design intent)*

### IEC 60601-1 (Basic safety & essential performance)

- Full SELV design (<5.0 V)  
- Battery safety via BQ21061 + pack NTC  
- Reverse battery protection  
- Defined essential performance: **BLE command/control**

### IEC 60601-1-2 (Ed.4) EMC

- Classified ports (USB, button, sensor rail, RF)  
- Surge/ESD/EFT protection at USB entry  
- Segmented power domains for immunity (`3V3_SYS` vs `3V3_SENS`)  
- RF/SMPS layout discipline based on ST AN5165  

### ISO 14971 (Risk)

- Full risk register included  
- Hazards mapped to hardware controls  
- Residual-risk evaluation  
- Precompliance EMC test strategy  

### ISO 13485 (Documentation style)

Repo mirrors a simplified DHF structure:

```text
Docs/
  Schematic/
  BoM/
  Compliance/
  Risk/
  Battery/
  Reports/
  testing/
# 🧪 BLE-Control — Bring-Up & Testing Summary

This document captures the recommended bring-up flow and key test procedures for the BLE-Control hardware platform.

---

## 🔧 Recommended Bring-Up Order

### 1. **Verify Power Path & Rails**
- Power via USB-C or bench supply.
- Confirm:
  - `VBUS`
  - `VBAT_RAW`
  - `VBAT_PROT`
  - `PMID`
  - `+3V3_SYS` (TPS7A02 output)
- Check for ripple, inrush anomalies, or unstable startup.

### 2. **Flash STM32WB55 (SMPS-bypass mode)**
- Leave SMPS inductors populated or install 0 Ω bypass links.
- Program using Tag-Connect TC2030-CTX-NL.
- Load minimal firmware (heartbeat LED + UART/SWV optional).

### 3. **Enable Charger & Monitor `BQ_INT`**
- Validate:
  - USB attachment detection
  - Correct CC pull-down behaviour
  - BQ21061 charge state transitions
  - `BQ_INT` on MCU (falling-edge EXTI)

### 4. **Bring Up Sensors (`SENS_EN` → `3V3_SENS`)**
- Assert `SENS_EN` → TPS22910A enables the sensor rail.
- Confirm correct voltage and soft-start behaviour.
- Check I²C access to:
  - TMP117
  - BMI270
  - SHTC3

### 5. **Enable SMPS & Verify Ripple**
- Populate SMPS inductors (10 µH + optional 10 nH helper).
- Remove any bypass 0 Ω links if used.
- Measure ripple on:
  - `VLXSMPS`
  - `VDD`
  - `+3V3_SYS`

### 6. **RF Bring-Up + π-Match Tuning**
- Conduct preliminary RF tests:
  - Return-loss sweep of antenna
  - Harmonic scan
  - π-match population depending on results

### 7. **Run STM32CubeMonitor-RF PER Tests**
- Validate BLE link margin.
- Test across multiple channels.
- Measure Packet Error Rate (PER) at various distances and orientations.

---

## 📡 EMC Pre-Compliance Checklist

### **IEC 61000-4-2 (ESD)**
- ±8 kV contact  
- ±15 kV air  
- Test:
  - USB shield
  - Button
  - Enclosure reference points

### **IEC 61000-4-4 (Burst/EFT)**
- ±1 kV at VBUS entry (through external PSU)

### **IEC 61000-4-3 (Radiated Immunity)**
- 10 V/m, 80 MHz–2.7 GHz  
- Observe:
  - BLE stability (RSSI)
  - Sensor I²C errors
  - Reset line behaviour
  - Spurious interrupts

### **IEC 61000-4-6 (Conducted RF Immunity)**
- 3 Vrms, 150 kHz–80 MHz  
- Monitor:
  - BLE performance  
  - I²C bus integrity  
  - Power rail droop

---

## 📌 What to Monitor During EMC Testing

- **BLE RSSI**  
- **Packet Error Rate (PER)**  
- **I²C behaviour** (stall, NACK bursts, timing anomalies)  
- **Reset events**  
- **False interrupts**  
- **Rail stability** (`+3V3_SYS`, `3V3_SENS`, `PMID`)  

---

## 🔧 Tools Used

- **Altium Designer 25**  
- **STM32CubeIDE / STM32CubeProgrammer**  
- **LTspice / Python** (signal analysis, power ripple, FFT, etc.)  
- **STM32CubeMonitor-RF** (BLE PER, RSSI, channel sweep)  

---


