# BLE-Control — Wearable BLE Controller (Altium AD25 + IEC 60601-style Design)

**BLE-Control** is a low-power wearable controller designed around **STM32WB55**  
(BLE 5 dual-core Cortex-M4/M0+).  
The goal is to demonstrate **robust hardware design, EMC-aware layout, documented power architecture, risk thinking (ISO 14971), and medical-style documentation structure** — suitable for a **professional portfolio** or **design review**.

> ⚠️ *Design-for-compliance only — not a medical device.*

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
