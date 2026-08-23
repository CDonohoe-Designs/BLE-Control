# BLE-Control — Wearable BLE Controller

BLE-Control is a compact, low-power wearable controller built around the STM32WB55 (BLE 5 + Cortex-M4/M0+), designed with robust power delivery, RF performance, USB-C protection, and sensor interfacing in mind. The system includes a protected USB-C charging front end (PPTC, TVS, CMC, ESD), a TI BQ21061 charger/power-path, a clean 3.3 V system rail from TPS7A02, and a switchable sensor domain feeding TMP117, BMI270, and SHTC3. 

## PCB Render

<p align="center">
  <img src="./BLE_Control_PCB.PNG" alt="BLE Control PCB 3D render" width="750">
</p>

## 2-Minute Engineering Review

I designed BLE-Control as a compact **low-power BLE wearable controller** that brings together power-path design, RF integration, USB-C protection, sensors and embedded bring-up considerations on one platform.

### Engineering focus

- **BLE embedded platform** — STM32WB55 dual-core MCU/radio architecture with SWD programming and BLE bring-up path
- **Power architecture** — BQ21061 charger/power path, low-noise 3.3 V regulation and a switchable sensor rail
- **USB-C robustness** — PPTC, TVS, ESD protection, common-mode filtering and controlled shield treatment
- **RF design intent** — STM32WB55 RF output, differential filtering, π-match provision, chip antenna and controlled RF routing strategy
- **Sensor integration** — TMP117, BMI270 and SHTC3 on a gated low-power domain
- **Bring-up planning** — staged verification of power, programming, charger, sensors, SMPS and RF performance
- **Design-for-test / EMC thinking** — test points, interface protection, return paths and pre-compliance checks considered during the hardware design

### Quick review

- **[Hardware / Altium source](Hardware/Altium/)**
- **[Documentation index](Docs/README.md)**
- **[Firmware area](Firmware/)**
- **[PCB render](BLE_Control_PCB.PNG)**

> **Current status:** the repository documents the hardware architecture, schematic/design work and planned bring-up approach. It is presented as an engineering portfolio project rather than a certified product design.

---

## ✔ Work Completed (More to do!)

## Project status

**Last updated:** _Nov 2025_ Summary

- ✅ **Schematic design**: Rev-A hierarchy complete (charger/LDO, MCU & RF, USB/debug, sensors, IO/buttons, testpoints).
- ✅ **First-pass BOM + docs**: Markdown BOM and design notes under `docs/`.
- ✅ **Standards & process docs**: ISO 13485 / ISO 14971 packs started; EMC/IEC alignment notes drafted.
- 🔄 **PCB layout (AD25)**: Stack-up and floorplanning in progress; routing and EMC tuning next.
- 🔄 **Design reviews**: EVT Rev-A sign-off checklists being filled in (schematic + PCB).
- ⏳ **Firmware & bring-up**: Basic STM32WB CubeIDE project to follow once PCB layout stabilises.



### **Hardware Design**
- Complete schematic capture in **Altium Designer 25**
- Power architecture finalised:
  - USB-C entry protection (PPTC, TVS, USBLC6, CMC, shield bleed)
  - BQ21061 charger/power-path wired and validated in schematic
  - TPS7A02-3.3 system rail finalised
  - TPS22910A sensor rail gating implemented
- Full RF chain designed:
  - STM32WB55 RF output → differential filter → π-match (DNP default) → chip antenna
  - CPWG routing strategy + via-fence defined
- Sensors subsystem defined (BMI270, TMP117, SHTC3)
- Tag-Connect TC2030-NL debug interface integrated

### **Documentation**
- `/Docs` folder structured like a mini Design History File

---

## My Roadmap

### **1. PCB Layout in Altium AD25**
- Stack-up definition (1.6 mm, 4-layer)
- Impedance-controlled CPWG for RF output
- SMPS layout (tight loop, ground islanding)
- USB-C differential routing & ESD return paths
- EMC placement discipline (TVS close to entry, CMC orientation, return paths)
- Placement of sensors & service loops for testing
- Test point optimisation

### **2. PCB DRC/EMC Review**
- High-speed/EMC checks (Rick Hartley rules)
- Return path verification
- Split of quiet vs noisy ccts
- Thermal considerations for charger IC

### **3. IEC / ISO Documentation Expansion**
- Full 60601-1 safety narrative 
- 60601-1-2 immunity for each port
- ISO 14971: expand risk register and residual risk justification
- ISO 13485: early DHF structure (revision control, traceability)

### **4. Firmware Bring-Up**
- Standby → Active → Sensor acquisition flow
- BLE service creation (GATT)
- BQ21061 telemetry/status decoding
- IMU & environmental sensing
- RF PER testing via CubeMonitor-RF

### **5. Pre-Compliance Preparation**
- Test plan for ESD/EFT/surge
- RF pre-scan (harmonics, match tuning)
- Power integrity measurements

This roadmap is updated as design work continues.


---

# Quick Navigation

###  Full Documentation 
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

###  Hardware (Altium AD25)
→ **[`Hardware/Altium/`](Hardware/Altium/)**  

Includes:

- Complete AD25 project (`.PrjPcb`, `.SchDoc`, `.PcbDoc`)  
- Outputs, Draftsman drawings, OutJobs  
- Component libraries  
- SmartPDF source

---

###  Firmware (STM32WB55)
→ **[`Firmware/`](Firmware/)**  

- STM32CubeIDE project  
- BLE stack integration (CPU2 Wireless Coprocessor)  
- Startup & bring-up code  
- Board support notes

---


#  System Overview

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

#  Design-for-Compliance Highlights

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
```


---
#  BLE-Control — Bring-Up & Testing Summary

This document captures the recommended bring-up flow and key test procedures for the BLE-Control hardware platform.


##  Bring-Up Order

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

##  EMC Pre-Compliance Checklist

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

##  Tools Used

- **Altium Designer 25**  
- **STM32CubeIDE / STM32CubeProgrammer**  
- **LTspice / Python** (signal analysis, power ripple, FFT, etc.)  
- **STM32CubeMonitor-RF** (BLE PER, RSSI, channel sweep)  

---


