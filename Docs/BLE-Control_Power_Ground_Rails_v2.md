# BLE-Control — Power & Ground (STM32WBxx, AD25)

---

## 0) Context from `Power_Charge_USB.SchDoc` (naming & nets)
- USB-C receptacle (**USB4105-GF-A**), PPTC (**MF-PSMF050X-2**), TVS (**SMF5.0A**), ferrite (**BLM15AG121**), charger **BQ21062YFPR**.
- Key nets exported to the rest of the design: **`VBAT`** (battery), **`PMID`** (charger mid node), **`+3V3_SYS`** (system 3.3 V rail).
- The BQ21062 has a **local pin called BQ_VDD** (IC1-D1).
---

## 1) VDDSMPS vs VDD — what & why (STM32WBxx)
- **`VDD`** = external 3.3 V rail for I/O and most internal domains. In this design it is **`+3V3_SYS`**.
- **`VDDSMPS`** = external 3.3 V **input to the MCU’s internal buck (SMPS)** which generates the core voltage.  
  Keeping a **separate pin** lets me place **tight local decoupling** (e.g., **4.7 µF + 0.1 µF**) and keep the **SMPS high-di/dt loop compact**, reducing noise on the broader VDD network.
- **`VDD`, `VDDRF`, and `VDDSMPS` are tied to the same external rail (`+3V3_SYS`)**, but have **different decoupling** and roles.

---

## 2) Rail Map (what each pin wants)

### Core & RF supplies (same net)
- **`VDDx` (all VDD pins) → `+3V3_SYS`**  
  Decouple **100 nF (0402) per pin** placed at the pin, plus **4.7–10 µF bulk** near the MCU.
- **`VDDRF` → `+3V3_SYS` (same net as VDD)**  
  Tie directly to VDD (no bead). Add **100 nF at the pin**.
- **`VDDSMPS` → `+3V3_SYS` (same net as VDD)**  
  Input to on-chip SMPS. Decouple **4.7 µF + 100 nF** to GND at the pins.

### On-chip SMPS cell (footprint even if you start in BYPASS)
- **`VLXSMPS`**: from `+3V3_SYS` **through L1** to `VLXSMPS`.  
  Start with **L1 = 2.2 µH (8 MHz mode) or 10 µH (4 MHz mode)**. Optionally add **10 nH in series** with L1 for best RX performance.
- **`VFBSMPS`**: SMPS output sense node. Place **Cbulk = 4.7 µF** from `VFBSMPS` → `GND` close to pins.  
  **Do not power external loads from `VFBSMPS`**; its voltage varies with RF/TX state.
- **BYPASS option**: Provide **0 Ω links** so `VDDSMPS`, `VLXSMPS`, `VFBSMPS` can be shorted to `VDD` (same net) if you decide to run LDO/BYPASS initially. Keep all SMPS footprints for easy later enable.

### Analog domain
- **`VDDA` → `+3V3_ANA`** (or straight to `+3V3_SYS` if you want simple)  
  Minimal: **100 nF + 1 µF** to **`VSSA`** at the pin.  
  “Quieter” option: **`+3V3_SYS` → ferrite bead → `+3V3_ANA`**, then **100 nF + 1 µF** to `VSSA` at the MCU.
- **`VREF+`**: simplest is **tie to `VDDA`** with **100 nF + 1 µF** at the pin. Leave pads for an external reference later if desired.

### USB domain
- **`VDDUSB`**: MCU USB FS isn’t used, so I **tie to `VDD`** (keeps PA11/PA12 usable) and add local 100 nF.  
  If used, supply **3.0–3.6 V** with local decoupling and handle ESD/CC in the USB sheet.

### Backup domain
- **`VBAT` (RTC/LSE backup)**: **Max 3.6 V** (don’t connect to raw Li-ion).  
  Options:  
  - **Simple:** **net-tie `VBAT` → `VDD`** and place **100 nF** at VBAT.  
  - **True backup:** feed from **3.0–3.3 V** source (coin cell/supercap/regulator) with **100 nF** at the pin.

---

## 3) Ground Strategy (single, solid plane)

- **`VSS` (all digital grounds)**: one **continuous GND plane (L2)** under MCU & RF. Heavy stitching vias.
- **`VSSRF` (incl. exposed pad)**: same **`GND`** net. Use **via-in-pad array** under the MCU/EPAD and a **via fence** near RF pins and π-match area to give returns a short path.
- **`VSSSMPS`**: same **`GND`** plane. Keep the **SMPS loop** (`VLXSMPS` → L1 → `VFBSMPS` → `VSSSMPS`) **very tight**. Place the **4.7 µF** from `VFBSMPS` to `VSSSMPS` as close as possible.
- **`VSSA` (analog ground)**: tie to the main **`GND`** plane **right beside the MCU** (short, low-Z). Ensure **`VDDA`/`VREF+` decouplers return to `VSSA`**. No split planes required on this small board.

---

## 4) Power_Charge_USB ⇄ MCU_RF net mapping

| From `Power_Charge_USB` | Use in `MCU_RF`               | Notes |
|---|---|---|
| `+3V3_SYS`              | `VDDx`, `VDDRF`, `VDDSMPS`   | All same rail; per-pin decoupling on VDDx/VDDRF; **4.7 µF + 0.1 µF** at VDDSMPS. |
| `+3V3_SYS` via L1       | `VLXSMPS`                    | L1 = 2.2 µH (8 MHz) or 10 µH (4 MHz), optional +10 nH series. |
| —                       | `VFBSMPS`                    | Place **4.7 µF** to GND; **not a system rail**. |
| `+3V3_SYS` or `+3V3_ANA`| `VDDA`, `VREF+`              | 0.1 µF + 1 µF to VSSA at pins; bead optional for `+3V3_ANA`. |
| `VBAT`                  | `VBAT` (MCU)                 | ≤ 3.6 V; either net-tie to VDD (with 0.1 µF) or feed from 3.0–3.3 V backup. |
| *(local)* `BQ_VDD`      | —                            | Charger IC local pin only; **do not** confuse with MCU VDD rail. |
| `GND`                   | `VSS`, `VSSRF/EPAD`, `VSSSMPS`, `VSSA` | Single solid plane; via-in-pad on EPAD; compact SMPS loop. |

---

## 5) Schematic How-To (AD25)

1. **Power Ports:** Place global `+3V3_SYS`, `+3V3_ANA` (if used), and `GND` power ports.  
2. **SMPS Cell:** Draw the block with `L1`, optional `L2=10 nH` in series, `Cbulk 4.7 µF` on `VFBSMPS`, and `Cvdsmps 4.7 µF + 100 nF` on `VDDSMPS`.  
   - Add **0 Ω links** labelled “BYPASS” to short `VDDSMPS/VLXSMPS/VFBSMPS` to `VDD` when not using SMPS.  
3. **Decouplers:** One **100 nF per `VDDx`**, plus bulk **4.7–10 µF** per side of the MCU.  
4. **Analog Node:** `VDDA` to `+3V3_ANA` via bead **or** straight to `+3V3_SYS`; **`VREF+` → `VDDA`**. Place **100 nF + 1 µF** to `VSSA`.  
5. **USB Node:** `VDDUSB` → `VDD` (if unused) with 100 nF; otherwise to a 3.0–3.6 V rail with local caps.  
6. **VBAT:** Net-tie to `VDD` + 100 nF **or** bring in 3.0–3.3 V backup with 100 nF; label “Max 3.6 V”.  
7. **Ground Pins:** Expose **`VSSRF/EPAD`** pin on the symbol and annotate: “via array to GND, keepout under HSE/RF”.  
8. **Naming hygiene:** Keep the charger’s local **`BQ_VDD`** distinct from MCU **`VDD`** to avoid ERC/DRC confusion.

---

## 6) Net Labels & Classes (to drive layout rules later)

- **Rails:** `+3V3_SYS`, `+3V3_ANA`, `VDD`, `VDDA`, `VREF+`, `VDDRF`, `VDDSMPS`, `VLXSMPS`, `VFBSMPS`, `VDDUSB`, `VBAT`, `GND`/`VSSA`.  
- **Parameter Sets (recommended):**  
  - On RF nets: `NetClass=RF`, `ImpedanceClass=RF_50R`, `ClearanceClass=RF_Clear`.  
  - On HSE/LSE nets: `NoViasHint=True`, `KeepoutHint=True`.  
  - On SMPS nets: `NetClass=SMPS_HOT` (for wider/shorter routing + extra clearance).

---

## 7) Quick ERC/DFM Checklist

- ✅ **`VDD`, `VDDRF`, `VDDSMPS`** are the **same `+3V3_SYS` net**.  
- ✅ **SMPS BYPASS** links present so you can defer SMPS bring-up.  
- ✅ **Each `VDDx` has 100 nF at-pin**, plus bulk caps near the device.  
- ✅ **`VDDA`/`VREF+` decouplers** return to **`VSSA`**, which is tied to **`GND`** very close by.  
- ✅ **`VBAT` ≤ 3.6 V** (either net-tied to `VDD` or from a safe backup source).  
- ✅ **`VSSRF/EPAD`** note: via-in-pad array to **GND**; SMPS loop tight; RF returns short.  
- ✅ **Naming hygiene:** charger **`BQ_VDD`** not reused as MCU **`VDD`**.

---

## 8) Starter BOM Hints (0402 unless noted)

- **VDD decouplers:** 100 nF X7R; Bulk 4.7–10 µF X5R/X7R (0603 allowed).  
- **VDDRF decoupler:** 100 nF X7R.  
- **VDDSMPS caps:** 4.7 µF + 100 nF (low ESR).  
- **SMPS L1:** 2.2 µH (8 MHz) **or** 10 µH (4 MHz), Isat ≥ peak current; DCR low. Optional series **10 nH**.  
- **VFBSMPS cap:** 4.7 µF X5R/X7R.  
- **VDDA/VREF+:** 100 nF NP0/C0G + 1 µF X7R; **ferrite bead** 600 Ω@100 MHz (if `+3V3_ANA` split is used).  
- **VDDUSB:** 100 nF.  
- **VBAT:** 100 nF.

---

### Drop-in Text (for your schematic header)
> **Power/Ground Rules:** `VDD = VDDRF = VDDSMPS = +3V3_SYS`. If SMPS is unused initially, short `VDDSMPS/VLXSMPS/VFBSMPS → VDD` (BYPASS). `VDDA` decouple to `VSSA` (100 nF + 1 µF); `VREF+` → `VDDA`. Single solid **GND plane** with via-in-pad on **EPAD** and tight SMPS loop. `VBAT` ≤ 3.6 V (net-tie to `VDD` or 3.0–3.3 V backup). Parameter sets: RF=50 Ω, HSE/LSE no-vias/keepout, SMPS_HOT widened. Use `BQ_VDD` as the charger’s local net name; reserve `VDD` for the MCU rail.
