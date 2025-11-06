# BLE-Control — Wearable BLE Control Board (Altium AD25) 


**BLE-Control** is a small, low-power wearable control board **I built** around the **STM32WB55** (BLE 5 + Cortex-M4).  
This is a **portfolio/showcase design I intentionally aligned** to **IEC 60601-1** (basic safety & essential performance) and **IEC 60601-1-2 Ed.4** (EMC, **Class A** – professional healthcare environment) practices, with documentation patterns influenced by **ISO 13485** (QMS) and **ISO 14971** (risk management). It is a Work in Progress 
> *Not a claim of compliance; design-for-compliance focus only.*

---
## EDA environment
- **Altium Designer 25.3.3 build 18 **
---

## Highlights
- **MCU:** STM32WB55CGU6 (BLE 5.0 + Cortex-M4)
- **Power:** Single-cell Li-Po, **TI BQ25180** ultra-low-Iq charger (USB-C sink) with **ship-mode** +  **TPS22910A** gated sensor rail
- **Sensors:** **BMI270** (6-axis IMU), **MAX17048** (fuel gauge, always-on), **SHTC3** (temp+RH, switched)
- **RF:** 2.4 GHz **chip antenna** with **π-match (DNP)** and optional **RF ESD (DNP)**
- **Debug:** **Tag-Connect TC2030-NL** (Cortex/SWD) — I don’t need USB D+/D− for programming
- **I/O:** 1× tactile button, 1× status LED, expansion pads (I²C/SPI/3V3/GND)
- **Form factor:** 4-layer, 0.8 mm PCB, **0402 passives** (0603 only for bulk/ESD)
- **Regulatory focus:** I designed toward **IEC 60601-1** and **60601-1-2 Class A**; docs follow **ISO 13485** / **ISO 14971** patterns

---

## Medical-minded protection & EMC (Class A focus)
> Goal: apply sensible protections and layout habits so **IEC 60601-1-2 Ed.4 (Class A)** pre-compliance is predictable. I document these as risk controls per **ISO 14971**.  
> *Showcase only; not a certified device.*

- **USB-C (charging port)**
  - **VBUS TVS** at the receptacle; shortest return to GND
  - **D+/D− ESD** array adjacent to pins
  - **CC1/CC2 ESD** (low-C) within a few mm
  - **Shield bleed:** **1 MΩ // 1 nF (C0G)** shell→GND
  - **CMC on D+/D− (DNP)** unless I enable USB data
- **RF feed (2.4 GHz)**
  - **Ultra-low-C RF ESD (DNP)** pad to GND; π-match footprints (DNP) for post-tune; via-fence along CPWG
- **Buttons / test pads**
  - **Small ESD TVS** at touch point; **100 Ω** series at the MCU pin
- **Power / grounding**
  - L2 **solid GND**; via-in-pad under MCU EPAD; **tight SMPS loop**; bead-isolated **+3V3_ANA** (or direct with local decoupling)
- **ESD test intent**
  - Design targets **±8 kV contact / ±15 kV air** (IEC 61000-4-2) at touch points; returns share the same stitching path as the touched metal
- **Risk mgmt hooks (ISO 14971)**
  - TVS, series resistors, shield bleed, reverse-battery PMOS, VBAT limits captured as **risk controls** with planned verification steps

---

## How this repo aligns with medical standards (plain-English)

**My goal:** demonstrate the “design-for-compliance” habits a medical team expects.  
*Showcase, not a certification claim.*

### IEC 60601-1 — Basic safety & essential performance
- **Ask:** user/patient safety (shock, burn, mechanical, fire); protect “essential performance.”
- **Do:** SELV only + **external medical-grade PSU** for charging; reverse-battery PMOS; conservative creepage/clearance for 3.3 V; VBAT_MCU ≤ 3.6 V; derating; define **essential performance** (BLE control path) and test it.

### IEC 60601-1-2 (Ed.4) — EMC (Class A)
- **Ask:** withstand ESD/RF fields and limit emissions (hospital/clinical environment).
- **Do:** ESD entry control (VBUS TVS, D+/D− ESD, **CC-line ESD**, **shield R//C**); solid GND plane, **tight SMPS loop**, RF via-fence, crystal “island”; call out zap points/pass criteria (±8 kV/±15 kV).

### ISO 13485 — Quality system (how I organize the work)
- **Ask:** controlled processes, traceability, planned V&V, documented changes.
- **Do:** Structured docs, BOM with MPNs, checklists, OutJobs/releases, linked datasheets/app notes, relative paths for reproducibility.

### ISO 14971 — Risk management
- **Ask:** hazards → risks → controls → verify → residual risk.
- **Do:** Treat TVS/series-R/shield-bleed/reverse-battery/VBAT limits/RF keepouts as **risk controls**; map each to a **verification** (ESD gun, continuity, brown-out); keep a lightweight **risk log**.

**Bottom line**
- **60601-1** = safety → low-voltage domain + protective circuits  
- **60601-1-2 Class A** = EMC → ESD/EMI features + RF-aware layout  
- **ISO 13485** = process → controlled, reproducible outputs  
- **ISO 14971** = risk → explicit mitigations + verification

---

## Documentation
- **Wearable Schematic Guide:** [Docs/BLE-Control_Wearable_Schematic_Guide_AD25_v2.md](Docs/BLE-Control_Wearable_Schematic_Guide_AD25_v2.md)  
- **Power & Ground Rules (STM32WBxx):** [Docs/BLE-Control_Power_Ground_Rules.md](Docs/BLE-Control_Power_Ground_Rules.md)  
- **Build Plan (AD25):** [Docs/BLE-Control_Build_Plan_AD25.md](Docs/BLE-Control_Build_Plan_AD25.md)  
- **One-Page Connection Checklist:** [Docs/BLE-Control_Connection_Checklist_OnePage.md](Docs/BLE-Control_Connection_Checklist_OnePage.md)  
- **Grouped BOM:** [Docs/BOM/BLE-Control_BOM_Grouped.md](Docs/BOM/BLE-Control_BOM_Grouped.md)  
- **CubeMonitor-RF test flow:** [Docs/testing/BLE_Control_CubeMonitorRF_Testing.md](Docs/testing/BLE_Control_CubeMonitorRF_Testing.md)

---

## Datasheets & Notes
- **TI BQ25180 — Ultra-low-Iq charger (USB-C sink):** [Docs/Datasheets/TI_BQ25180_Datasheet.pdf](Docs/Datasheets/TI_BQ25180_Datasheet.pdf)  
- **TI TPS7A02-3V3 — Ultra-low-Iq LDO:** [Docs/Datasheets/TI_TPS7A02_Datasheet.pdf](Docs/Datasheets/TI_TPS7A02_Datasheet.pdf)  
- **TI TPS22910A — Load switch (active-low):** [Docs/Datasheets/TI_TPS22910A_Datasheet.pdf](Docs/Datasheets/TI_TPS22910A_Datasheet.pdf)  
- **STM32WB55xx Datasheet:** [Docs/Datasheets/stm32wb55xx_datasheet.pdf](Docs/Datasheets/stm32wb55xx_datasheet.pdf)  
- **AN5165 — STM32WB RF hardware guidelines:** [Docs/Datasheets/AN5165_RF_Hardware_STM32WB.pdf](Docs/Datasheets/AN5165_RF_Hardware_STM32WB.pdf)  
- **BQ21061 EVM User Guide (SLUUC59) — reference for BQ21062 alt:** https://www.ti.com/lit/ug/sluuc59/sluuc59.pdf

---

## Quick start (Altium AD25)
1. Open **`Hardware/Altium/BLE_Control.PrjPcb`**.
2. **Libraries**
   - **Integrated:** compile `Libraries/Integrated/*.LibPkg` → install via **Components → (gear) File-based Libraries**.
   - **Database:** open `Libraries/DBLib/BLE_Control.DBLib` (status **Connected**). Map to **Library Ref / Library Path / Footprint**; DB at `Libraries/Database/BLE_Control_Parts_DB.xlsx`.
3. Place parts on `Schematic/*.SchDoc`. **Project → Validate** → proceed to `BLE_Control.PcbDoc`.

---

## Schematic partition (what lives where)
- **Power_Batt_Charge_LDO.SchDoc** — **BQ25180** charger (USB-C sink, ship-mode), **TPS22910A** sensor rail (**VDD_SENS**), **TPS7A02-3V3**, thermistor input, **USB shield R//C bleed**, **CC ESD**  
- **MCU_RF.SchDoc** — **STM32WB55**, HSE 32 MHz & LSE 32.768 kHz, **on-chip SMPS cell** (L1=10 µH + optional 10 nH), decoupling, **RF π-match (DNP)**, **optional RF ESD (DNP)**, SWD pins  
- **USB_Debug.SchDoc** — USB-C receptacle, **5.1 kΩ Rd** on CC1/CC2 (sink-only), ESD, optional USB-FS path, **Tag-Connect TC2030-NL** (Cortex/SWD)  
- **IO_Buttons_LEDs.SchDoc** — Button (ESD + 100 Ω series), status LED  
- **Sensors.SchDoc** — **BMI270** (INT1/2→EXTI), **MAX17048** (always-on @ VBAT), **SHTC3** (on **VDD_SENS**), I²C pull-ups

---

## Power & ground rules (STM32WBxx)

### Rails
- **`VDD = VDDRF = VDDSMPS = +3V3_SYS`** (single 3V3 domain)
- **Analog:** `VDDA` via bead to `+3V3_ANA` (or direct to `+3V3_SYS`) with **0.1 µF + 1 µF** to **VSSA**; `VREF+` = `VDDA`
- **VBAT (MCU backup):** **Do not** tie to Li-ion (3.0–4.2 V). Use **3.0–3.3 V** backup or **net-tie to +3V3_SYS** with **100 nF**.  
  Naming hygiene: **`VBAT_MCU`** (pin) vs **`+BATT`** (pack)

### On-chip SMPS cell
- **Path:** `+3V3_SYS → L1 (10 µH for 4 MHz; 2.2 µH for 8 MHz) → [optional 10 nH] → VLXSMPS`
- **Decoupling:**  
  - `VFBSMPS → 4.7 µF → GND` **at pins** (not a system rail)  
  - `VDDSMPS → (4.7 µF + 0.1 µF) → GND` **at pins**
- **BYPASS option:** provide **0 Ω links** so `VDDSMPS/VLXSMPS/VFBSMPS` can be shorted to `VDD` for initial LDO bring-up

### Layout essentials
- **Tiny SMPS loop**; keep **VLXSMPS** short & wide; no RF/clock under-routes  
- **Crystal islands:** guard to GND, short tracks, symmetric loads; keep LSE away from RF  
- **RF CPWG:** clear keepout, via-fence, DNP π-match

---

## Debug (TC2030 — Cortex/SWD)

**Pin map (top view pads `1 2 3 / 4 5 6`):**  
**1=VTref (3V3 sense)**, **2=SWDIO (PA13)**, **3=GND**, **4=SWCLK (PA14)**, **5=nRESET (NRST)**, **6=SWO (PB3, optional)**

- Keep SWDIO/SWCLK/NRST **short, single-via** if possible; place near edge  
- **No paste** on pads; include **3 NPTH alignment holes**  
- Power target from board supply; VTref is **sense** only

### Handy hook table

| TC2030 Pad | Signal | Suggested Net | STM32WB55 Pin | Required | Notes |
|---:|---|---|---|:---:|---|
| 1 | VTref | +3V3_SYS | — | ✅ | Probe voltage sense; does not power target |
| 2 | SWDIO | SWDIO | PA13 | ✅ | Short trace; no series R |
| 3 | GND | GND | — | ✅ | Stitching via next to pad |
| 4 | SWCLK | SWCLK | PA14 | ✅ | Short trace; no series R |
| 5 | nRESET | NRST | NRST | ✅ | 10 k→3V3 + 100 nF→GND optional |
| 6 | SWO | SWO | PB3 | ◻️ | Optional SWV printf/trace |

---

## BOM & releases
- **Grouped BOM:** includes **L1 = 10 µH** (main SMPS), **L1A = 10 nH (DNP)** series helper, **CC-line ESD**, **USB shield R//C**, **button ESD + 100 Ω**, **RF ESD (DNP)** → [Docs/BOM/BLE-Control_BOM_Grouped.md](Docs/BOM/BLE-Control_BOM_Grouped.md)  
- **Releases:** OutJob produces PDFs, fab/assy, XY, and BOM packages

**Inductor picks** (as used/documented)
- **10 µH (L1):** Murata **LQM21FN100M70L** (0805). Alt: Coilcraft **XFL2010-103MEC**  
- **10 nH (L1A, optional):** Murata **LQW15AN10NG00D** (0402). Alt: TDK **MLG1005S10NHT000**  
- **8 MHz SMPS mode** option: **2.2 µH** (e.g., Würth **74479774222**) in place of 10 µH

---

## Firmware (STM32CubeIDE)
- **Project:** `Firmware/BLE_Control/` (CubeIDE 1.17.0)  
- **Wireless coprocessor (CPU2):** flash BLE stack via **STM32CubeProgrammer → Wireless/FUS**; record stack version in the firmware README  
- **Bring-up stubs:** I²C scan, IMU wake, fuel-gauge read, BLE advertisement, SWV logging on **PB3**

---

## Bring-up sequence (what I do first)
1. **Power path only:** charger + LDO rails up; verify **+3V3_SYS** ripple/overshoot; VBAT_MCU tied to 3V3 with 100 nF  
2. **MCU in LDO/BYPASS:** 0 Ω short the SMPS nodes; flash minimal firmware over SWD; heartbeat LED + SWV  
3. **Peripherals one-by-one:** I²C pull-ups ok; IMU/ALERT/INT lines; fuel gauge read; button interrupt  
4. **Enable SMPS:** populate **L1 (10 µH)** (+ optional **10 nH**), remove 0 Ω shorts; confirm stability & current draw  
5. **RF phase:** π-match DNP → populate after VNA/tune; verify PER with **STM32CubeMonitor-RF** ([guide](Docs/testing/BLE_Control_CubeMonitorRF_Testing.md))

---

## Antenna tune checklist (π-match)
- Confirm stack-up & CPWG impedance; check ground fence  
- Sniff-test near-field; check harmonics with SMPS on/off  
- Populate C-L-C to meet return-loss target across BLE channels  
- Lock values; **freeze keepout** and update BOM

---

## Lightweight risk log (template I keep)
| Hazard | Sequence of events | Harm | Control | Verification | Residual risk |
|---|---|---|---|---|---|
| ESD into USB | User touch during charge | Loss of function | TVS on VBUS, D+/D−, CC; shield R//C | IEC 61000-4-2 at shell & pins | Acceptable |
| Reverse battery | Wrong insertion | Board damage | PMOS ideal-diode | Polarity test, brown-out | Acceptable |
| Over-voltage VBAT_MCU | Tied to Li-ion | MCU damage | VBAT_MCU ≤ 3.3 V, 100 nF | DMM, power-off retention | Acceptable |
| RF desense | SMPS spur coupling | Reduced link margin | 10 nH helper, layout rules | PER across channels | Acceptable |

---

## Links & resources
- **AN5165 — STM32WB RF hardware guidelines:** [Docs/Datasheets/AN5165_RF_Hardware_STM32WB.pdf](Docs/Datasheets/AN5165_RF_Hardware_STM32WB.pdf)  
- **Phil’s Lab #139 — PCB Chip Antenna Hardware Design:** https://www.youtube.com/watch?v=UQBMROv7Dy4  
- **STM32WB Getting Started playlist:** https://www.youtube.com/playlist?list=PLnMKNibPkDnG9JRe2fbOOpVpWY7E4WbJ-  

---

### Change summary
- Switched charger to **BQ25180**; documented ship-mode and sink-only USB-C
- Added **SMPS cell** details (10 µH + optional 10 nH), **VBAT caution**, naming hygiene
- Fixed **TC2030** mapping (Cortex/SWD)
- Baked in **medical-minded ESD/EMC** practices and risk-control notes
- Linked **AN5165** and **Grouped BOM**; added bring-up & tuning checklists

