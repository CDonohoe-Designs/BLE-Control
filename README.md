# BLE-Control — Wearable BLE Control Board (Altium AD25)

**BLE-Control** is a small, low-power wearable control board built around **STM32WB55** (BLE 5 + Cortex-M4).  
This is a **portfolio/showcase** design intentionally aligned to **IEC 60601-1** (basic safety & essential performance) and **IEC 60601-1-2 Ed.4** (EMC, **Class A** – professional healthcare environment) habits, with documentation patterns influenced by **ISO 13485** (QMS) and **ISO 14971** (risk).  
> *Not a claim of compliance; design-for-compliance focus only.*

---

## Table of contents
- [EDA environment](#eda-environment)
- [Highlights](#highlights)
- [Medical-minded protection & EMC (Class A focus)](#medical-minded-protection--emc-class-a-focus)
- [How this repo aligns with medical standards (plain-English)](#how-this-repo-aligns-with-medical-standards-plain-english)
  - [IEC 60601-1 — Basic safety & essential performance](#iec-60601-1--basic-safety--essential-performance)
  - [IEC 60601-1-2 (Ed.4) — EMC (Class A)](#iec-60601-1-2-ed4--emc-class-a)
  - [ISO 13485 — Quality system (how I organize the work)](#iso-13485--quality-system-how-i-organize-the-work)
  - [ISO 14971 — Risk management](#iso-14971--risk-management)
- [Documentation](#documentation)
- [Datasheets & Notes](#datasheets--notes)
- [Quick start (Altium AD25)](#quick-start-altium-ad25)
- [Schematic partition (what lives where)](#schematic-partition-what-lives-where)
- [Power & ground rules (STM32WBxx)](#power--ground-rules-stm32wbxx)
  - [Rails](#rails)
  - [On-chip SMPS cell](#on-chip-smps-cell)
  - [Layout essentials](#layout-essentials)
- [Debug (TC2030 — Cortex/SWD)](#debug-tc2030--cortexswd)
  - [Handy hook table](#handy-hook-table)
- [BOM & releases](#bom--releases)
- [STM32CubeIDE Firmware (STM32WB55CG, UFQFPN-48)](#stm32cubeide-firmware-stm32wb55cg-ufqfpn-48)
- [Bring-up sequence (what I do first)](#bring-up-sequence-what-i-do-first)
- [Antenna tune checklist (π-match)](#antenna-tune-checklist-π-match)
- [Lightweight risk log (template I keep)](#lightweight-risk-log-template-i-keep)
- [Links & resources](#links--resources)
- [Change summary](#change-summary)

---
## Documentation
- **Wearable Schematic Guide (v4):** [BLE-Control_Wearable_Schematic_Guide_AD25_v4.md](BLE-Control_Wearable_Schematic_Guide_AD25_v4.md)
- **Grouped BOM (v4):** [Docs/BoM/BLE-Control_BOM_Grouped_v4.md](Docs/BoM/BLE-Control_BOM_Grouped_v4.md)
- **Power & Ground Rules (STM32WBxx):** [Docs/BLE-Control_Power_Ground_Rails_v2.md](Docs/BLE-Control_Power_Ground_Rails_v2.md)
- **Build Plan (AD25):** [Docs/BLE-Control_Build_Plan_AD25.md](Docs/BLE-Control_Build_Plan_AD25.md)
- **CubeMonitor-RF test flow:** [Docs/testing/BLE_Control_CubeMonitorRF_Testing.md](Docs/testing/BLE_Control_CubeMonitorRF_Testing.md)
---

## EDA environment
- **Altium Designer 25.x (AD25)**

---

## Highlights
- **MCU:** STM32WB55CGU6 (BLE 5.0 + Cortex-M4)
- **Power:** Single-cell Li-Po, **TI BQ21062** (USB-C sink) with power-path and **LS/LDO** → **+3V3_SYS**  
  – **PPTC** on VBUS (**Bourns MF-PSMF050X-2, 0.5 A hold**), **VBUS TVS**, **CC ESD**, **shield R//C (1 MΩ // 1 nF C0G)**
- **Sensors (on `VDD_SENS`):** **BMI270** (IMU), **BME280** (env; alt path SHTC3+LPS22HH),  
  **TMP117** (skin temp, default) with variant **MAX30208** on a rigid-flex tail (DNP in Proto_A)
- **RF:** 2.4 GHz **chip antenna** with **π-match (DNP)**, **50 Ω CPWG**, via-fence; optional **RF ESD (DNP)**; optional inline **u.FL (DNP)**
- **Debug:** **Tag-Connect TC2030-NL** (Cortex/SWD) — USB data not required for programming
- **I/O:** 1× tactile button (ESD + 100 Ω series), 1× status LED (low-current), expansion pads
- **Form factor:** 4-layer, **0.8 mm** PCB, **0402** passives (0603 only for bulk/ESD)
- **Regulatory focus:** designed toward **IEC 60601-1** and **60601-1-2 Class A**; docs follow **ISO 13485**/**ISO 14971** patterns

---

## Medical-minded protection & EMC (Class A focus)
> Goal: apply protections and layout habits so **IEC 60601-1-2 Ed.4 (Class A)** pre-compliance is more predictable.  
> *Showcase only; not a certified device.*

- **USB-C (charging port)**
  - **VBUS TVS** at the receptacle, shortest return to GND
  - **PPTC** (0.5 A hold) in series with VBUS
  - **CC1/CC2 ESD** (low-C) within a few mm; **D+/D− ESD** pads kept for symmetry/option
  - **Shield bleed:** **1 MΩ // 1 nF (C0G)** shell→GND
- **RF feed (2.4 GHz)**
  - **Ultra-low-C RF ESD (DNP)** pad to GND; **π-match DNP** for post-tune; CPWG with via-fence
- **Buttons / user pads**
  - **SOD882 TVS** at the pad; **100 Ω** series at the MCU pin
- **Grounding / loops**
  - L2 **solid GND**; via-in-pad under MCU EPAD; **tight SMPS loop**; clean crystal islands

---

## How this repo aligns with medical standards (plain-English)

**Intent:** demonstrate the “design-for-compliance” habits a medical team expects.  
*Showcase, not a certification claim.*

### IEC 60601-1 — Basic safety & essential performance
- **Ask:** protect user/patient; preserve essential performance.
- **Do:** SELV only; external medical-grade PSU for charging; reverse-battery PMOS; conservative creepage/clearance at 3.3 V; define essential performance (BLE control path) and test it.

### IEC 60601-1-2 (Ed.4) — EMC (Class A)
- **Ask:** withstand ESD/RF fields; limit emissions in professional environments.
- **Do:** ESD entry control (VBUS TVS, D+/D− ESD, **CC-line ESD**, **shield R//C**); solid plane, **tight SMPS**, RF via-fence, crystal “island”; call out zap points/pass criteria (±8 kV/±15 kV).

### ISO 13485 — Quality system (how I organize the work)
- **Ask:** controlled processes, traceability, planned V&V, documented changes.
- **Do:** structured docs, BOM with MPNs, checklists, OutJobs/releases, linked datasheets/app notes, reproducible paths.

### ISO 14971 — Risk management
- **Ask:** hazards → risks → controls → verify → residual risk.
- **Do:** treat TVS/series-R/shield-bleed/reverse-battery/VBAT limits/RF keepouts as **risk controls**; map each to a **verification** (ESD gun, continuity, brown-out).

**Bottom line**
- **60601-1** = safety → low-voltage + protective circuits  
- **60601-1-2 Class A** = EMC → ESD/EMI features + RF-aware layout  
- **ISO 13485** = process → controlled, reproducible outputs  
- **ISO 14971** = risk → mitigations + verification

---

## Documentation
- **Wearable Schematic Guide (v4):** `docs/BLE-Control_Wearable_Schematic_Guide_AD25_v4.md`  
- **Grouped BOM (v4):** `docs/BLE-Control_BOM_Grouped_v4.md`  
- **Power & Ground Rules (STM32WBxx):** `docs/BLE-Control_Power_Ground_Rails.md`  
- **Build Plan (AD25):** `docs/BLE-Control_Build_Plan_AD25.md`  
- **CubeMonitor-RF test flow:** `docs/testing/BLE_Control_CubeMonitorRF_Testing.md`



---

## Datasheets & Notes
- **TI BQ21062 — 1-cell charger (power-path + LS/LDO):** https://www.ti.com/lit/gpn/bq21062  
- **STM32WB55xx Datasheet:** include under `docs/datasheets/`  
- **AN5165 — STM32WB RF hardware guidelines:** include under `docs/datasheets/`  
- **BQ21061/62 EVM User Guide (SLUUC59):** https://www.ti.com/lit/ug/sluuc59/sluuc59.pdf

### Bosch BMI270 (IMU)
- **Datasheet:** https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bmi270-ds000.pdf
- **Shuttle Board 3.0 (schematic/overview):** https://docs.rs-online.com/32e4/A700000008845135.pdf
- **Handling / Soldering / Mounting Guide:** https://www.mouser.com/pdfDocs/BST-BMI270-HS000.pdf

### Sensirion SHTC3 (Temp/RH)
- **Datasheet:** https://sensirion.com/media/documents/643F9C8E/63A5A436/Datasheet_SHTC3.pdf
- **Eval Kit – SEK-SHTC3-Sensors:** https://www.mouser.com/ProductDetail/Sensirion/SEK-SHTC3-Sensors
- **SensorBridge Technical Guide:** https://sensirion.com/media/documents/7F4762CB/642D8327/SEK-SensorBridge_Technical_Guide_D1.pdf
- **Design-in Guide (SHT/STS family):** https://sensirion.com/media/documents/FC5BED84/61644655/Sensirion_Temperature_Sensors_Design_Guide_V1.pdf

### Texas Instruments TMP117 (±0.1 °C)
- **Datasheet:** https://www.ti.com/lit/gpn/TMP117
- **EVM User Guide (schematic/BOM):** https://www.ti.com/lit/ug/snou161/snou161.pdf
- **Reference Design – TIDA-060034 (hearables ear temp flex):** https://www.ti.com/tool/TIDA-060034
- **App Note – Precise Temp Measurements (TMP116/117):** https://www.ti.com/lit/pdf/snoa986


---

## Quick start (Altium AD25)
1. Open **`Hardware/Altium/BLE_Control.PrjPcb`**.
2. **Libraries**
   - Integrated: compile `Libraries/Integrated/*.LibPkg` and add via **Components → (gear) File-based Libraries**.
   - Database: connect `Libraries/DBLib/BLE_Control.DBLib` → `Libraries/Database/BLE_Control_Parts_DB.xlsx`.
3. Place parts on `Schematic/*.SchDoc` → **Project → Validate** → open `BLE_Control.PcbDoc`.

---

## Schematic partition (what lives where)
- **Power_Charge_USB.SchDoc** — **BQ21062** (USB-C sink), **PPTC + TVS + CC ESD + shield R//C**, power-path to **PMID**, **LS/LDO → +3V3_SYS**, optional **VDD_SENS** gating via internal LS  
- **MCU_RF.SchDoc** — **STM32WB55**, HSE 32 MHz & LSE 32.768 kHz, **on-chip SMPS cell** (L1=10 µH + optional 10 nH), decoupling, **RF π-match (DNP)**, optional **RF ESD (DNP)**, **SWD/TC2030**  
- **Sensor_IO_Buttons_LED.SchDoc** — **BMI270**, **BME280** (or SHTC3+LPS22HH alt), **TMP117** (skin temp), button (ESD + 100 Ω), status LED, I²C pulls to **VDD_SENS**, test pads  
  *(Fuel gauge removed; no VBAT-powered I²C parts.)*

---

## Power & ground rules (STM32WBxx)

### Rails
- **`VDD = VDDRF = VDDSMPS = +3V3_SYS`** (single 3V3 domain)
- **`VDDA`**: tie to `+3V3_SYS` (no bead) with **0.1 µF + 1 µF** to **VSSA**
- **`VBAT (MCU backup)`**: keep **≤3.6 V**; either net-tie to `+3V3_SYS` with **100 nF**, or provide a 3.0–3.3 V backup

### On-chip SMPS cell
- Path: `+3V3_SYS → L1 (10 µH @ 4 MHz; 2.2 µH @ 8 MHz opt) [ +10 nH DNP ] → VLXSMPS`
- Decoupling: `VFBSMPS → 4.7 µF → GND` (at pins) and `VDDSMPS → (4.7 µF + 0.1 µF) → GND` (at pins)
- BYPASS: 0 Ω links to short `VDDSMPS/VLXSMPS/VFBSMPS` to `VDD` for early bring-up

### Layout essentials
- **Tight SMPS loop**; short/wide **VLXSMPS**
- Crystal “islands”, short symmetric loads; keep LSE away from RF
- **CPWG 50 Ω**, via-fence; **π-match DNP** until tuned

---

## Debug (TC2030 — Cortex/SWD)

**Pads (top view `1 2 3 / 4 5 6`):** 1=VTref, 2=SWDIO (PA13), 3=GND, 4=SWCLK (PA14), 5=NRST, 6=SWO (PB3, optional)

- Keep SWDIO/SWCLK/NRST short, single-via; place near edge  
- No paste on pads; include **3 NPTH alignment holes**  
- Target powers itself; VTref is **sense** only

### Handy hook table
| Pad | Signal | Net | WB55 Pin | Req | Notes |
|---:|---|---|---|:--:|---|
| 1 | VTref | +3V3_SYS | — | ✅ | Probe sense |
| 2 | SWDIO | SWDIO | PA13 | ✅ | No series R |
| 3 | GND | GND | — | ✅ | Stitch via |
| 4 | SWCLK | SWCLK | PA14 | ✅ | No series R |
| 5 | nRESET | NRST | NRST | ✅ | 10 k→3V3 + 100 nF optional |
| 6 | SWO | SWO | PB3 | ◻️ | Optional trace/SWV |

---

## BOM & releases
- **Grouped BOM (v4):** includes **L1=10 µH**, **L1A=10 nH (DNP)**, **PPTC**, **VBUS TVS**, **CC-ESD**, **shield R//C**, button ESD + 100 Ω, RF ESD/π-match (DNP), **TMP117** (+ MAX30208 flex variant, DNP)  
- OutJob produces PDFs, fab/assy, XY, and BOM packages

**Inductor picks**
- **10 µH (L1):** Murata **LQM21FN100M70L** (0805). Alt: Coilcraft **XFL2010-103MEC**  
- **10 nH (L1A, DNP):** Murata **LQW15AN10NG00D** (0402). Alt: TDK **MLG1005S10NHT000**  
- **8 MHz option:** 2.2 µH (e.g., Würth **74479774222**)

---

## STM32CubeIDE Firmware (STM32WB55CG, UFQFPN-48)
**Project path:** `Firmware/BLE_Control/` → see `Firmware/BLE_Control/README.md`  
**Wireless coprocessor (CPU2):** flash BLE stack via **STM32CubeProgrammer → Wireless/FUS** and record versions.

---

## Bring-up sequence (what I do first)
1. **Power path:** BQ21062 rails up; verify **+3V3_SYS** ripple/overshoot; VBAT_MCU policy set
2. **MCU in BYPASS:** short SMPS nodes; flash minimal FW; heartbeat LED + SWV
3. **Peripherals:** I²C pulls to **VDD_SENS** OK; BMI270 INTs; TMP117 reading; button EXTI
4. **Enable SMPS:** populate **L1 (10 µH)** (+ optional **10 nH**), remove shorts; check stability & current draw
5. **RF:** tune π-match; verify PER with **STM32CubeMonitor-RF**

---

## Antenna tune checklist (π-match)
- Confirm stack-up & CPWG impedance; ground fence
- Sniff-test near-field; check harmonics with SMPS on/off
- Populate C-L-C to meet return-loss across BLE channels; lock values & update BOM

---

## Lightweight risk log (template I keep)
| Hazard | Sequence of events | Harm | Control | Verification | Residual risk |
|---|---|---|---|---|---|
| ESD into USB | Touch during charge | Loss of function | TVS on VBUS, D+/D−, CC; shield R//C | IEC 61000-4-2 at shell & pins | Acceptable |
| Reverse battery | Wrong insertion | Damage | PMOS ideal-diode | Polarity test, brown-out | Acceptable |
| Over-voltage VBAT_MCU | Backup pin overstress | MCU damage | VBAT_MCU ≤ 3.3 V, 100 nF | DMM, power-off retention | Acceptable |
| RF desense | SMPS spur coupling | Reduced link margin | 10 nH helper, layout rules | PER across channels | Acceptable |

---

## Links & resources
- **AN5165 — STM32WB RF hardware guidelines**  
- **Phil’s Lab #139 — PCB Chip Antenna Hardware Design**: https://www.youtube.com/watch?v=UQBMROv7Dy4  
- **STM32WB Getting Started (playlist)**

---

## Change summary
- Switched power to **BQ21062 power-path + LS/LDO** (removed TPS7A02/TPS22910A)
- Removed **fuel gauge**; sensors consolidated on `VDD_SENS`
- Added **TMP117** skin-temp (default) + **MAX30208** rigid-flex tail variant (DNP)
- Consolidated **Sensors + I/O** into **Sensor_IO_Buttons_LED.SchDoc**
- Tightened EMC notes (PPTC, CC-ESD, shield R//C) and updated RF guidance


