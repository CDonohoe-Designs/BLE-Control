# BLE-Control — Schematic Overview (Master Summary)
**Document ID:** BLEC-SCH-OVERVIEW-A2**  
**Revision:** A2 (EVT)**  
**Master PDF:** `BLE-Control_Schematic_Master.pdf`  
**Design Tool:** Altium Designer 25 (AD25)  

This document provides an expanded overview of the complete BLE-Control schematic set.  
It correlates each schematic sheet with system-level safety, EMC behaviour, essential performance,  
and supports traceability for IEC 60601-1, IEC 60601-1-2, ISO 14971, and ISO 13485 Design Controls.

---

# 1. Purpose of This Document

The schematic is the **authoritative source of truth** for the BLE-Control hardware.  
This overview enables reviewers to:

- Understand the structure of the design quickly  
- Trace key nets across sheets  
- See how safety and EMC considerations are implemented at circuit level  
- Map components to risk controls and BoM criticality  
- Relate the electrical architecture to RF, firmware, and system behaviour  
- Use the PDF as a cross-reference for compliance and test documents

---

# 2. Schematic Set Structure

The SmartPDF contains **three primary sheets**, covering all functional blocks:

### **1) Power_Charge_USB**  
→ Power entry, protection, battery system, charger, LDO, 3V3 rails, USB interface

### **2) MCU_RF**  
→ STM32WB55, RF front-end, crystals, clocks, SWD, reset/boot logic

### **3) Sensor_IO_Buttons_LED**  
→ Sensor suite, gated 3V3_SENS rail, button, interrupt lines, LED driver

Each sheet includes local notes for:
- Safety  
- EMC  
- Design rationale  
- Cross-sheet connectivity  

---

# 3. System Block Context (How the Schematic Maps to System Architecture)

BLE-Control is architected as:

### ✔ **A SELV-only embedded controller**  
No mains, no isolation barrier, no high-power stages.

### ✔ **A BLE communication module**  
Essential performance: **maintain BLE link or fail safe**.

### ✔ **A battery-powered wearable subsystem**  
Battery protection + JEITA temperature supervision handled in hardware.

### ✔ **A sensor platform**  
Isolated 3V3_SENS rail improves EMC robustness.

### ✔ **A medically-aligned electronics block**  
USB entry point hardened for IEC 60601-1-2 Class A.

---

# 4. Detailed Sheet Summaries (Expanded)

---

## 🟦 **Sheet 1 — Power_Charge_USB (BLEC-SCH-0001)**  
This sheet defines the **entire power safety chain**, implementing all protection and EMC mitigation before energy reaches the system.

### 4.1 USB Power Entry (USB4105-GF-A)
Includes:
- CC1/CC2 pull-downs (5.1 kΩ)
- TVS on CC pins (PESD)
- CMC on D+/D–
- USBLC6 ESD array  
- SMF5.0A TVS directly at VBUS  
- PPTC fuse limiting current to sub-1A levels

This aligns with **IEC 60601-1-2 operator-accessible port requirements**.

### 4.2 BQ21061 Charger / Power Path
Implements:
- CC/CV Li-ion charging  
- JEITA thermal profiling  
- VIN_BQ_F filtering  
- PMID → LDO supply  
- INT (open-drain) monitored by MCU  
- TS NTC monitoring (10k)  
- Reverse-FET consistent with TI reference design  

This creates a **controlled and safe energy entry path**.

### 4.3 TPS7A02 LDO (“always-on” rail)
- Provides **+3V3_SYS**
- Extremely low quiescent current
- Excellent PSRR at BLE frequencies  
- Soft-start reduces EMC-induced current spikes

### 4.4 Key Safety/EMC Design Choices
- USB-C is the **only exposure point for surge, ESD, EFT**  
- All harmful energy is clamped or limited **before** PMI and LDO  
- Full testpoint coverage for EVT validation  

---

## 🟦 **Sheet 2 — MCU_RF (BLEC-SCH-0002)**  
This sheet contains the main processor, real-time clocks, and RF path.

### 4.5 STM32WB55 Architecture
- Dual-core Cortex-M4F + M0+ RF core  
- DCDC/SMPS with mandated layout  
- USB FS native support  
- BLE 5.3 certified

The schematic exactly matches ST’s recommended connections, including:

- VREF, VDDUSB, RFVDD decoupling  
- BOOT0 pulled down for deterministic startup  
- NRST clean RC for robust behaviour under ESD/EFT  
- USB_FS_N/P series resistors for edge-rate control  

### 4.6 RF Front-End
Consists of:
- Johanson 2450AT18A100E antenna  
- π-match network (C14/L1/C15)  
- Differential RF filter (FL2)  
- RF ESD diode footprint  
- Controlled impedance feed  

The design is layout-ready for final antenna tuning (C14/C15/L1 = DNP or installed as per test results).

### 4.7 Clocking (HSE/LSE)
- 32MHz HSE crystal + load caps chosen per NDK spec  
- 32.768 kHz LSE crystal for RTC  
- Correct biasing and grounding  

Clock stability is essential for **BLE channel spacing and modulation accuracy**.

### 4.8 Debug / Programming
- Tag-Connect TC2030-CTX-NL  
- SWDIO/SWCLK access without exposed header  
- No EMI-prone long stubs  
- Classified as **Service Port** per IEC 60601-1-2  

### 4.9 Reset & Boot Logic
- BOOT0 = 100k pulldown  
- NRST = RC network  
- Ensures **no undefined MCU state**, even under strong ESD events.

---

## 🟦 **Sheet 3 — Sensor_IO_Buttons_LED (BLEC-SCH-0003)**

### 4.10 Sensor Domain (Isolated Rail)
The sensors live on **+3V3_SENS**, gated by TPS22910A.

This ensures:
- EMC recovery by cycling the rail  
- Lower coupling between high-speed MCU and sensor suite  
- Cleaner I²C operation under RF exposure  

Sensors implemented:
- TMP117 (precision medical-grade thermometry class)
- BMI270 (IMU)
- SHTC3 (humidity/temperature)

### 4.11 Button Input (BTN1)
Designed for **robust ESD and EFT behaviour** via:
- TVS clamp  
- 100Ω series resistor  
- RC debounce  
- 470k pull-up  
- Clean routing  

False triggers due to RF/EFT are mitigated.

### 4.12 Status LED
- Low-current indicator  
- Reverse diode protection if accidentally driven wrong  

### 4.13 Sensor I²C Bus
- Pull-ups on this sheet  
- Clean topology  
- Interrupt lines all biased properly (pull-down or pull-up as appropriate)  
- Consistent naming across sheets  

---

# 5. Cross-Sheet Key Nets (Expanded)

| Net | Origin | Destination | Rationale |
|------|----------|-------------|----------|
| **+3V3_SYS** | LDO | MCU, charger logic | Always-on stable rail |
| **+3V3_SENS** | TPS22910A | Sensors | EMC isolation |
| **USB_FS_P/N** | USB filters | MCU | High-speed differential pair |
| **I2C_CHG_SDA/SCL** | Sheet 1 | MCU | Charger configuration |
| **I2C3_SENS_SDA/SCL** | Sheet 3 | MCU | Isolated sensor bus |
| **BTN1** | Sheet 3 | MCU | Debounced, TVS protected |
| **TMP117_ALERT** | Sheet 3 | MCU | Precision temp alert |
| **BMI270_INT1/2** | Sheet 3 | MCU | Motion/interrupt control |
| **CE_MCU** | MCU | Sheet 1 | Charger enable logic |
| **SENS_EN** | MCU | Sheet 3 | Sensor power control |
| **BQ_INT** | Sheet 1 | MCU | Charger status & faults |

---

# 6. Essential Performance Mapping

BLE-Control’s **essential performance** is:

> “Maintain BLE communication or fail safe with no unintended commands.”

The schematic supports this by:

- Deterministic boot/reset  
- Debounced and ESD-protected user input  
- Stable RF path  
- EMC segmentation of sensor domain  
- Power tree that rejects disturbances  
- MCU-level watchdog support (firmware dependent)  
- USB entry hardened for IEC 60601-1-2 Class A  

This ensures no hazardous stimulation commands can occur (since BLE-Control does not generate stimulation signals).

---

# 7. Layout Dependencies (Altium Implementation Notes)

The schematic includes multiple blocks where correct PCB layout is **mandatory**, including:

### ✔ BQ21061 “keep small, keep close” analog area  
- TS filter  
- Sense resistors  
- VIN_BQ_F filtering  
- PMID path impedance must be low

### ✔ WB55 SMPS section  
- L1/L2/L3 placement within 3–5 mm of MCU pins  
- Keep switching nodes tight

### ✔ RF π-match  
- CPWG with via fence  
- Keep away from switching currents  
- Maintain 50Ω trace to antenna

### ✔ USB FS differential pair  
- 22Ω resistors close to MCU  
- CMC close to connector  
- Keep skew low

These are referenced implicitly in the schematic; the layout must reflect ST/TI/Johanson guidelines.

---

# 8. Related Documentation

- **Medical BoM (full)**  
  `/Docs/BoM/BLE-Control_Medical_BoM.md`

- **Risk Register (ISO 14971)**  
  `/Docs/Risk/Risk_Register.md`

- **Safety Boundary Statement**  
  `/Docs/Compliance/Safety_Boundary_Statement.md`

- **Electrical Safety Overview**  
  `/Docs/Compliance/Electrical_Safety_Overview.md`

- **EMC Pre-compliance Notes**  
  `/Docs/Reports/EMC_Precompliance_Notes.md`

---

# 9. Change Control (ISO 13485 / Design File Link)

Any of the following changes require:

- ECR (Engineering Change Request)  
- Risk review  
- Compliance document update  
- SmartPDF regeneration  

### Changes requiring full control:
- Power tree modifications  
- ESD/TVS/protection changes  
- RF network changes  
- Crystal/component changes  
- Sensor rail changes  
- USB differential path changes  
- Reset/boot circuitry changes  

### Minor changes:
- Non-critical passives  
- Reference designators  
- Notes/comment blocks  

---

_End of Schematic Overview (A2)_
