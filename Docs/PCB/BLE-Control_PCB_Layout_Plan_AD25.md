# BLE-Control PCB Layout Plan (AD25, IEC 60601-1 / -1-2 minded)

Working design notes for the BLE-Control wearable PCB.  
Target: **4-layer, 0.8 mm**, STM32WB55 BLE, BQ21061 charger, sensors, USB-C.

This is a jump-off point for detailed block-by-block placement and routing.

---

## 1. Board & Stackup

**Tentative board outline (rev-A target)**  
- **PCB size:** ≈ **34 mm × 22 mm**, 4-layer, 0.8 mm  
- Long edge: left↔right (X), short edge: bottom↔top (Y)

**Layer stack (current AD25 stack)**

| Layer        | Type     | Cu   | Thick (mm) | Notes                    |
|--------------|----------|------|------------|--------------------------|
| Top Overlay  | Overlay  | —    | —          | Silkscreen               |
| Top Solder   | Solder   | —    | ~0.01      |                          |
| **L1_TOP**   | Signal   | 1 oz | 0.035      | All main components      |
| Dielectric 2 | Prepreg  | —    | 0.20       | Dk≈4.1                   |
| **L2_GND**   | Plane    | 1 oz | 0.018      | **Solid ground plane**   |
| Dielectric 1 | Core     | —    | 0.30       | Dk≈4.8                   |
| **L3_PWR_SIG** | Plane  | 1 oz | 0.018      | Power pours + some sigs  |
| Dielectric 3 | Prepreg  | —    | 0.20       | Dk≈4.1                   |
| **L4_BOTTOM**| Signal   | 1 oz | 0.035      | Mostly GND / slow sigs   |
| Bot Solder   | Solder   | —    | ~0.01      |                          |
| Bot Overlay  | Overlay  | —    | —          | Silkscreen               |

**Key principles**

- **L2_GND is never split** – continuous reference for RF, USB and all fast edges.  
- **L3_PWR_SIG**: mainly planes for `3V3_SYS`, `3V3_SENS`, `VBAT_PROT` etc; only local routing.  
- L4 used for slower signals and extra GND copper (under battery).

IEC-60601-1-2 benefit: tight current loops + solid reference plane ⇒ lower emissions and better immunity.

---

## 2. Grids & Units (AD25)

- **Units:** mm (`Q` toggles mil/mm in PCB editor).
- **Normal snap grid:** `0.05 mm` (placement & routing).  
- **Fine snap grid:** `0.025 mm` (temporary for 0.4 mm BGA escape etc.).
- **Visible grid:** `0.5 mm`.

All key packages (0.4 mm BGA, 0.5 mm BMI270, 0.65 mm SON) land cleanly on 0.05 mm grid multiples.

---

## 3. Top vs Bottom Side Strategy

**Top side (user/outside)** — almost everything:

- Connectors: **J2 USB-C**, **J1 JST-GH**, **J3 TC2030** (debug).
- RF: **ANT1**, π-match network (C14/C15/L1/L3/FL2) and **ESD_RF1**.
- MCU: **STM32WB55 (IC3)** + all decouplers, bulk caps, crystals Y1/Y2.
- Power: **BQ21061 (IC1)**, **TPS7A02 (IC2)**, **TPS22910 (IC7)**, **Q101** reverse FET, **L2** power inductor, input/output/bulk caps.
- USB protection: **F101, D101, FL101, D102, ESD_CC1/2, R1/R104**.
- Sensors: **BMI270, SHTC3, TMP117** + their passives & I²C pulls.
- User I/O: **SW1**, **LED1 + R20**, button ESD **D3** + R24.
- Most testpoints (especially power rails).

**Bottom side (battery/skin)** — keep **flat and quiet**:

- Large GND pour (shielding over battery).
- Possibly a few **non-critical 0402 passives** (pull-ups, config links), via’d straight to top.
- Avoid tall parts under the battery; avoid routing under antenna keep-out.

Bottom copper acts as a shield toward the patient side during immunity tests.

---

## 4. Zones & IEC Mindset

I divide the board into four conceptual zones:

- **Zone A – USB / Power entry (noisy I/O)**  
  J2, F101, D101, FL101, D102, ESD_CCx, BQ21061, TPS7A02, Q101, J1.  
  *Main IEC 61000-4-2/-4/-5/-6 injection point.*

- **Zone B – RF / MCU core**  
  STM32WB55, RF network, decoupling, clocks.  
  *Primary source of high-frequency emissions.*

- **Zone C – Sensors (quiet analog/digital)**  
  BMI270, SHTC3, TMP117, I²C bus.  
  *Susceptible to RF and transients; keep away from Zone A switching.*

- **Zone D – User & service I/O**  
  SW1, LED1, TC2030, testpoints.  
  *ESD at user interfaces and debugging harness.*

Layout decisions should always ask:  
> “Can we keep disturbance energy inside Zone A and avoid coupling into B/C?”

---

## 5. Net Classes (schematic-driven)

Net classes defined via Net Class Directives in schematics:

- `PWR_MAIN`  
  `VBUS`, `VIN_BQ`, `VBATT_RAW`, `VBAT_PROT`, main trunks of `3V3_SYS`, `3V3_SENS`.
- `USB_FS`  
  `USB_FS_R_P`, `USB_FS_R_N` (connector → CMC → ESD → MCU).
- `rf_50ohms`  
  RF path from STM32WB RF pin → π-match/FL2 → ANT1 feed.
- `DIG_FAST`  
  `SWDIO`, `SWCLK`, `SWO`, `NRST`, fast GPIO with long traces, USB logic-side lines.
- `SENS_DIG`  
  `I2C_SCL/SDA`, BMI270 INT1/INT2, TMP117 ALERT, SHTC3 alerts if used.
- `SENS_ANALOG`  
  `BAT_NTC_10K` and any future analog sense nets.
- `DEFAULT`  
  Everything else.

---

## 6. Impedance Profiles

Defined in **Layer Stack Manager → Impedance**:

- **`S50`** – single-ended 50 Ω (RF feed)  
  - Layer: `L1_TOP`, Ref: `L2_GND`  
  - Calculated width: **0.36921 mm**  
  - Impedance: ~**49.98 Ω**  
  - Used by: `rf_50ohms` class.

- **`D90_USB`** – differential 90 Ω (USB FS)  
  - Layer: `L1_TOP`, Ref: `L2_GND`  
  - Provides **Width (W1)** and **Gap** values used in diff-pair rule.  
  - Used by: `USB_FS` class.

These profiles are the single source of truth for controlled-impedance routing.

---

## 7. PCB Rules – Summary

### 7.1 Global manufacturing limits

- **Default track width:**  
  - Pref `0.12 mm`, Min `0.10 mm`, Max `0.30 mm`.
- **Default clearance:** `0.10 mm`.
- **Standard via:**  
  - Pad `0.45 mm`, Hole `0.20 mm`.
- **Tight via (local, e.g. under BQ BGA):**  
  - Pad `0.35 mm`, Hole `0.15 mm` (used only in a defined Room).

### 7.2 Width rules by class (Routing → Width)

- `Width_RF_50ohms` – `InNetClass('rf_50ohms')`  
  - Min / Pref / Max: **`0.369 mm`** (locked to `S50` profile).

- `Width_USB_FS` – `InNetClass('USB_FS')`  
  - Min / Pref / Max: values from `D90_USB` profile (e.g. `0.15 mm`).

- `Width_PowerMain` – `InNetClass('PWR_MAIN')`  
  - Pref `0.25 mm`, Min `0.20 mm`, Max `0.40 mm`.

- Other classes (`DIG_FAST`, `SENS_DIG`, `SENS_ANALOG`) can use default width or custom rules as needed.

### 7.3 Clearance rules (Electrical → Clearance)

- `Clearance_Default` – `All`  
  - Clearance: `0.10 mm`.

- `Clearance_PowerToAll` – Between `Net Class PWR_MAIN` and `Any Net`  
  - Clearance: `0.15 mm`.

- `Clearance_NoiseToAnalog` – Between `(PWR_MAIN OR DIG_FAST)` and `SENS_ANALOG`  
  - Clearance: `0.20 mm`.

IEC idea: enforce extra spacing between noisy switching/clock nets and sensitive analog/sensor nets.

### 7.4 Differential pair rule (High Speed → Differential Pairs Routing)

- Rule `Diff_USB_FS` – `InNetClass('USB_FS')`  
  - **Width & Gap:** from `D90_USB` profile (≈ 90 Ω diff).  
  - Optional max uncoupled length: `2–3 mm`.

USB pair defined via **Differential Pairs Editor** (`USB_FS_R_P` / `_N`).

---

## 8. Block 1 – USB-C + Protection Island (Placement Strategy)

**Components:**  
`J2`, `F101`, `D101`, `FL101`, `D102`, `ESD_CC1`, `ESD_CC2`, `R1`, `R104`, nearby caps.

**Role:** primary disturbance port for IEC 61000-4-2/-4/-5/-6.

### 8.1 VBUS chain

Place on **RIGHT edge, lower half**:

1. **J2** on the edge; shield & GND pins via’d heavily into L2.
2. **F101 PPTC** directly behind VBUS pins (inline).
3. **D101 TVS** just behind F101:
   - VBUS connected at the F101/BQ side.
   - GND pad with 2–3 vias straight into L2 within <0.5 mm.
4. First **input cap(s)** for BQ21061 at the VIN pin, forming a tiny loop with D101 path and GND.

Goal: smallest possible **VBUS+GND loop** at the connector → ESD/surge current dumped locally into L2.

### 8.2 D+ / D− path

Order on each line:

```text
J2 → FL101 CMC → D102 ESD array → series Rs (if used) → MCU pins
```
# USB-C Layout & Protection Guidelines

## Differential Pair Routing
- All on L1, tightly-coupled diff pair (USB_FS class, D90_USB rule).
- FL101 placed immediately behind J2.
- D102 just after FL101, with GND pins via’d directly into L2.
- Series resistors (if any) as a matched pair, close to MCU.

## 8.3 CC & SBU
- R1/R104 (5k1) right at CC pads.
- ESD_CC1/2 even closer to connector pins if possible:
  - Pad → ESD → short trace to GND via.

## 8.4 Grounding & Copper
- L2 solid GND under whole island; no splits.
- L1 GND pour around J2, D101, D102, FL101, ESD_CCx, stitched abundantly to L2.
- Avoid running sensor nets through this area.
- **IEC view:** This creates a compact, well-referenced ESD/surge sink right at the port, reducing stress on BQ21061/STM32 and lowering emissions on the USB cable.

## 9. Next Steps
- Verify all rules in AD25 (Width, Clearance, Diff Pair) are using the net classes and impedance profiles described above.
- Complete placement of Block 1 (USB-C + protection island) per Section 8 and run DRC to confirm widths/clearances.
- Move on to Block 2: Charger + LDO island (BQ21061 + TPS7A02) with the same IEC-aware pattern:
  - Tiny switching loops.
  - Short, fat power traces in PWR_MAIN.
  - Good separation from RF and sensors.
- This plan is the anchor for further placement/routing playbooks for each circuit block.

