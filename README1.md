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

## EDA environment
- **Altium Designer 25.3.3 (AD25)**

---

## Highlights
- **MCU:** STM32WB55CGU6 (BLE 5.0 + Cortex-M4, QFN-48)
- **Power:**
  - **Charger/power-path:** **TI BQ21061** (USB-C sink) — **TS** to pack **10 k NTC**, **INT** open-drain to MCU
  - **Main 3V3:** **TPS7A02-3.3** (VIN = **PMID** ) → **`+3V3_SYS`**
  - **Aux:** **LSLDO** (from BQ21061) kept **separate** with ≥2.2 µF; **not** tied to `+3V3_SYS`
  - **Sensors rail:** **TPS22910A** load-switch creates **`3V3_SENS`** (gated by `SENS_EN`)
  - **USB-C front end:** PPTC (**MF-PSMF050X-2**), **VBUS TVS**, low-C **CC ESD**, shield **1 MΩ // 1 nF (C0G)**
- **Battery:** 1-cell Li-Po, **3-wire with 10 k NTC** (JST-GH-3); requires **IEC 62133-2**, **UN 38.3** (see [docs/Battery/](docs/Battery/))
- **RF:** 2.4 GHz chip antenna, **π-match (DNP)**, CPWG 50 Ω, via-fence; RF ESD pad (DNP)
- **Sensors (on `3V3_SENS`):** **BMI270** (IMU), **TMP117** (skin temp, default) **SHTC3** (Ambient Temp)
- **Debug:** **Tag-Connect TC2030-NL** (Cortex/SWD) — programming independent of USB data
- **I/O:** 1× tactile button (ESD + 100 Ω series), 1× status LED (active-low)
- **Key nets (flat project):** `+3V3_SYS`, `3V3_SENS`, `USB_FS_P/N`, `I2C_SCL/SDA`, `I2C_CHG_SCL/SDA`, `BQ_INT`, `CE_MCU`, `SENS_EN`, `LED_STAT_N`

**MCU pin highlights (QFN-48):**
- **`BQ_INT → PA10`** (EXTI, falling-edge, pull-up to 3V3 on board)
- **I²C (charger bus)**: **I2C1_CHG_XXX** on **PB6 (SCL)** / **PB7 (SDA)**
- **I²C (sensors bus)**: **I2C3_SENS_XXX** on **PA7 (SCL)** / **PB4 (SDA)** *(or alt pins as routed)*

---

## Medical-minded protection & EMC (Class A focus)
> Goal: apply protections and layout habits so **IEC 60601-1-2 Ed.4 (Class A)** pre-compliance is more predictable.  
> *Showcase only; not a certified device.*

- **USB-C entry**: VBUS TVS at receptacle, PPTC, CC ESD; shield bleed (**1 MΩ // 1 nF C0G**)
- **Power rails**: solid GND on L2, short return for TVS/PPTC; test points on VBAT/PMID/3V3
- **RF feed**: CPWG 50 Ω, via-fence, π-match DNP; RF ESD pad (DNP)
- **Buttons/IO**: SOD882 TVS at pad; 100 Ω series at MCU
- **Battery safety**: 3-wire pack with **10 k NTC** to charger **TS**; pack must provide **IEC 62133-2/UN 38.3** docs

---

## How this repo aligns with medical standards (plain-English)

### IEC 60601-1 — Basic safety & essential performance
- SELV only; external medical-grade PSU for charging  
- Reverse-battery PMOS, sensible creepage/clearance at 3.3 V  
- Define **essential performance** (BLE control path) and verify it

### IEC 60601-1-2 (Ed.4) — EMC (Class A)
- ESD entry control (VBUS TVS, CC ESD, D+/- option), shield bleed, plane discipline  
- Tight SMPS loops, crystal “islands”, RF via-fence and π-match

### ISO 13485 — Quality system (how I organize the work)
- Structured docs, BOM/MPNs, OutJobs/releases, linked datasheets/app notes

### ISO 14971 — Risk management
- Map hazards → controls (TVS/series-R/shield-bleed/reverse-battery/RF keepouts) → verification (ESD gun, continuity, PER)

---

## Documentation
- **Wearable Schematic Guide (v4):** [BLE-Control_Wearable_Schematic_Guide_AD25_v4.md](BLE-Control_Wearable_Schematic_Guide_AD25_v4.md)
- **Grouped BOM (v4):** [Docs/BOM/BLE-Control_BOM_Grouped_v4.md](Docs/BOM/BLE-Control_BOM_Grouped_v4.md)
- **Power & Ground Rules (STM32WBxx):** [Docs/BLE-Control_Power_Ground_Rails_v2.md](Docs/BLE-Control_Power_Ground_Rails_v2.md)
- **Build Plan (AD25):** [Docs/BLE-Control_Build_Plan_AD25.md](Docs/BLE-Control_Build_Plan_AD25.md)
- **CubeMonitor-RF test flow:** [Docs/testing/BLE_Control_CubeMonitorRF_Testing.md](Docs/testing/BLE_Control_CubeMonitorRF_Testing.md)
- **Battery pack docs:** [Docs/Battery/](Docs/Battery/) _(spec, RFQ template, incoming inspection)_


---

## Datasheets & Notes
See [Datasheets & Notes → Docs/Datasheets](Docs/Datasheets/Datasheets.md)

---

## Schematic partition (what lives where)
- **Power_Charge_USB.SchDoc**  
  **USB-C front end**, **BQ21061** charger (TS → pack **10 k NTC**), **TPS7A02-3.3 → `+3V3_SYS`**, test points; **LSLDO** local (≥2.2 µF), **do not** tie to `+3V3_SYS`.
- **MCU_RF.SchDoc**  
  **STM32WB55**, HSE 32 MHz & LSE 32.768 kHz, on-chip SMPS cell (L1=10 µH + 10 nH DNP), RF feed with **π-match (DNP)**, **TC2030 SWD**.
- **Sensor_IO_Buttons_LED.SchDoc**  
  **TPS22910A** → **`3V3_SENS`** (from `+3V3_SYS`, gated by `SENS_EN`), **BMI270**, **TMP117** (default)**SHTC3**, button (ESD + 100 Ω), status LED (active-low), I²C pulls to **`3V3_SENS`**, test pads.

---

## Power & ground rules (STM32WBxx)

### Rails
- **`+3V3_SYS`** = **main system rail** from **TPS7A02-3.3**  
- **`3V3_SENS`** = switched sensor rail from **TPS22910A** (local label; not exported)  
- **`LSLDO`** = auxiliary rail (local node, ≥2.2 µF to GND), **not** tied to `+3V3_SYS`  
- **`VDDA`**: tie to `+3V3_SYS` with **0.1 µF + 1 µF** to **VSSA**

### On-chip SMPS cell
- `+3V3_SYS → L1 (10 µH @ 4 MHz; 2.2 µH @ 8 MHz opt) [+10 nH DNP] → VLXSMPS`  
- `VFBSMPS → 4.7 µF → GND`, `VDDSMPS → (4.7 µF + 0.1 µF) → GND`  
- BYPASS: 0 Ω links for early bring-up if desired

### Layout essentials
- Tight SMPS loop; short/wide VLXSMPS  
- Crystal islands; keep LSE away from RF  
- CPWG 50 Ω, via-fence; π-match DNP; TVS returns short

---

## Debug (TC2030 — Cortex/SWD)

Pads (top view `1 2 3 / 4 5 6`): **1=VTref**, **2=SWDIO (PA13)**, **3=GND**, **4=SWCLK (PA14)**, **5=NRST**, **6=SWO (PB3, opt)**

### Handy hook table
| Pad | Signal | Net | WB55 Pin | Req | Notes |
|---:|---|---|---|:--:|---|
| 1 | VTref | +3V3_SYS | — | ✅ | Sense only |
| 2 | SWDIO | SWDIO | PA13 | ✅ | No series R |
| 3 | GND  | GND | — | ✅ | Stitch via |
| 4 | SWCLK | SWCLK | PA14 | ✅ | No series R |
| 5 | nRESET | NRST | NRST | ✅ | 10 k→3V3 (+100 nF opt) |
| 6 | SWO | SWO | PB3 | ✅ | SWV |

---

## BOM & releases
- **Grouped BOM (v4):** includes **TPS7A02-3.3**, **TPS22910A**, **PPTC**, **VBUS TVS**, **CC-ESD**, **shield R//C**, RF π-match/ESD (DNP), sensors, test points.  
- OutJob produces PDFs, fab/assy, XY, and BOM packages.

**Inductor picks**
- **10 µH (L1):** Murata **LQM21FN100M70L** (0805). Alt: Coilcraft **XFL2010-103MEC**  
- **10 nH (L1A, DNP):** Murata **LQW15AN10NG00D** (0402). Alt: TDK **MLG1005S10NHT000**  
- **8 MHz option:** 2.2 µH (e.g., Würth **74479774222**)

---

## STM32CubeIDE Firmware (STM32WB55CG, UFQFPN-48)
Project: `Firmware/BLE_Control/` → see `Firmware/BLE_Control/README.md`  
Wireless coprocessor (CPU2): flash BLE stack via **STM32CubeProgrammer → Wireless/FUS**; record versions.

---

## Bring-up sequence (what I do first)
1. **Power path:** verify **PMID/VBAT_PROT**; enable **TPS7A02-3.3 → +3V3_SYS**; check ripple/overshoot  
2. **MCU basic:** BYPASS SMPS (0 Ω links) for first flash; heartbeat LED + SWV  
3. **I²C (charger bus):** talk to **BQ21061**, confirm **INT** on **PA8** (falling-edge)  
4. **Sensors:** assert **SENS_EN → TPS22910A → 3V3_SENS**; I²C pull-ups on `3V3_SENS`; read BMI270/TMP117  
5. **Enable on-chip SMPS:** populate **L1** (+10 nH DNP option), remove BYPASS links; confirm current draw  
6. **RF:** π-match tune; verify PER with **STM32CubeMonitor-RF**

---

## Antenna tune checklist (π-match)
- Confirm stack-up & CPWG impedance; ground fence  
- Sniff test; check harmonics with SMPS on/off  
- Populate C-L-C to meet return-loss across BLE channels; lock values & update BOM

---

## Lightweight risk log (template I keep)
| Hazard | Sequence of events | Harm | Control | Verification | Residual risk |
|---|---|---|---|---|---|
| ESD into USB | Touch during charge | Loss of function | TVS on VBUS, CC ESD; shield R//C | IEC 61000-4-2 at shell & pins | Acceptable |
| Reverse battery | Wrong insertion | Damage | PMOS ideal-diode | Polarity test, brown-out | Acceptable |
| Over-voltage VBAT_MCU | Backup pin overstress | MCU damage | VBAT_MCU ≤ 3.3 V, 100 nF | DMM, power-off retention | Acceptable |
| RF desense | SMPS spur coupling | Reduced link margin | 10 nH helper, layout rules | PER across channels | Acceptable |

---

## Links & resources
- **AN5165 — STM32WB RF hardware guidelines**  
- **Phil’s Lab #139 — PCB Chip Antenna Hardware Design**: https://www.youtube.com/watch?v=UQBMROv7Dy4

---

## Change summary
- **Added** **TPS7A02-3.3** as the **main 3.3 V rail (`+3V3_SYS`)** (VIN = **PMID** preferred)  
- **Kept** **TPS22910A** to create **`3V3_SENS`** (gated sensors)  
- **Isolated** **LSLDO** (aux only; ≥2.2 µF, not tied to `+3V3_SYS`)  
- **Standardised battery** to **3-wire Li-Po with 10 k NTC**; added `docs/Battery/` (spec, RFQ, incoming inspection)  
- **Locked MCU wiring:** `BQ_INT → PA8` (EXTI), **I2C1 PB8/PB9** (charger), **I2C3 PC0/PC1** (sensors)  
- Tightened EMC notes (PPTC, CC-ESD, shield R//C) and RF guidance (π-match DNP)
