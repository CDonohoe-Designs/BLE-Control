# BLE-Control PCB Layout Plan (AD25, IEC 60601-1 / -1-2 minded)

Working design notes for the BLE-Control wearable PCB.  
Target: **4-layer, 0.8 mm**, STM32WB55 BLE, BQ21061 charger, sensors, USB-C.

This is a jump-off point for detailed block-by-block placement and routing.

---

## 1. Board & Stackup

**Tentative board outline (rev-A target)**  
- **PCB size:** ≈ **34 mm × 22 mm**, 4-layer, 0.8 mm  
- Long edge: left↔right (X), short edge: bottom↔top (Y).

**Layer stack (current AD25 stack)**

| Layer          | Type     | Cu   | Thick (mm) | Notes                    |
|----------------|----------|------|------------|--------------------------|
| Top Overlay    | Overlay  | —    | —          | Silkscreen               |
| Top Solder     | Solder   | —    | ~0.01      |                          |
| **L1_TOP**     | Signal   | 1 oz | 0.035      | All main components      |
| Dielectric 2   | Prepreg  | —    | 0.20       | Dk≈4.1                   |
| **L2_GND**     | Plane    | 1 oz | 0.018      | **Solid ground plane**   |
| Dielectric 1   | Core     | —    | 0.30       | Dk≈4.8                   |
| **L3_PWR_SIG** | Plane    | 1 oz | 0.018      | Power pours + some sigs  |
| Dielectric 3   | Prepreg  | —    | 0.20       | Dk≈4.1                   |
| **L4_BOTTOM**  | Signal   | 1 oz | 0.035      | Mostly GND / slow sigs   |
| Bot Solder     | Solder   | —    | ~0.01      |                          |
| Bot Overlay    | Overlay  | —    | —          | Silkscreen               |

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

Four conceptual zones:

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

These classes are generated into PCB **Net Classes** via Project Options → Class Generation.

---

## 6. Impedance Profiles

Defined in **Layer Stack Manager → Impedance**:

- **`S50`** – single-ended 50 Ω (RF feed)  
  - Layer: `L1_TOP`, Ref: `L2_GND`  
  - Calculated width: **0.36921 mm**  
  - Impedance: ~**49.98 Ω**  
  - Used by: `rf_50ohms` class and `Width_RF_50ohms` rule.

- **`D90_USB`** – differential 90 Ω (USB FS)  
  - Layer: `L1_TOP`, Ref: `L2_GND`  
  - Provides **Width (W1)** and **Gap** values used in diff-pair rule.  
  - Used by: `USB_FS` diff pair and `Diff_USB_FS` rule.

These profiles are the single source of truth for controlled-impedance routing.

---

## 7. PCB Rules – Summary

### 7.1 Global manufacturing limits

- **Default track width:**  
  - Pref `0.12 mm`, Min `0.10 mm`, Max `0.30 mm`.
- **Default clearance (`Clearance_Default`):** `0.10 mm`.
- **Standard via:**  
  - Pad `0.45 mm`, Hole `0.20 mm`.
- **Tight via (local, e.g. under BQ BGA):**  
  - Pad `0.35 mm`, Hole `0.15 mm` (used only in a defined Room).

### 7.2 Width rules by class (Routing → Width)

- `Width_RF_50ohms` – `InNetClass('rf_50ohms')`  
  - Min / Pref / Max: **`0.369 mm`** (locked to `S50` profile).

- `Width_USB_FS` – `InNetClass('USB_FS')`  
  - Min / Pref / Max: values from `D90_USB` profile (≈ USB FS 90 Ω leg width).

- `Width_PowerMain` – `InNetClass('PWR_MAIN')`  
  - Pref `0.25 mm`, Min `0.20 mm`, Max `0.40 mm`.

- Other classes (`DIG_FAST`, `SENS_DIG`, `SENS_ANALOG`) use default width or can have overrides as needed.

### 7.3 Clearance rules (Electrical → Clearance)

- **`Clearance_Default`** – `All`  
  - Clearance: `0.10 mm`.

- **`Clearance_PowerToAll`** – Between `Net Class = PWR_MAIN` and **Any Net**  
  - Clearance: `0.15 mm`.  
  - IEC-view: enforces extra distance between noisy power rails and everything else.

- **`Clearance_NoiseToAnalog`** – “Between” type  
  - First: `InNetClass('PWR_MAIN') or InNetClass('DIG_FAST')`  
  - Second: `InNetClass('SENS_ANALOG')`  
  - Clearance: `0.20 mm`.  
  - Protects sensor/analog nets from switching/fast nets.

- **`Clearance_IC3_Local`** – inside STM32WB only  
  - First: `InComponent('IC3')`  
  - Second: `InComponent('IC3')`  
  - Clearance: `≈0.09–0.10 mm`.  
  - Reason: package pin pitch is tighter than 0.15 mm; this rule avoids “false” DRC hits inside IC3 while still enforcing 0.15 mm once traces leave the package.

Rule priority (top→bottom):

1. `Clearance_IC3_Local`  
2. `Clearance_NoiseToAnalog`  
3. `Clearance_PowerToAll`  
4. `Clearance_Default`

### 7.4 Solder Mask Sliver rules (Manufacturing → Solder Mask Sliver)

- **Global rule – `MaskSliver_Default`**  
  - Scope: `All`, `All`.  
  - Minimum Solder Mask Sliver: **0.08 mm**.  
  - Chosen as a realistic but conservative manufacturing limit.

- **Local RF filter rule – `MaskSliver_FL2`**  
  - First: `InComponent('FL2')`  
  - Second: `InComponent('FL2')`  
  - Min sliver: **≈0.00–0.005 mm** (merged openings allowed).  
  - Reason: FL2 vendor footprint produces mask dams as small as 0.006 mm or zero; this rule tells DRC to accept that behaviour.

- **Local fine-pitch rule – `MaskSliver_IC5_IC7`**  
  - First: `InComponent('IC5') or InComponent('IC7')`  
  - Second: same  
  - Min sliver: **0.04 mm**.  
  - Reason: IC5/IC7 footprints give ~0.047–0.076 mm mask dams; 0.04 mm limit matches typical fine-pitch capability.

Priority (top→bottom):

1. `MaskSliver_FL2`  
2. `MaskSliver_IC5_IC7`  
3. `MaskSliver_Default`

### 7.5 Silkscreen rules

- **Silk to Solder Mask Clearance**  
  - Global rule set to **0.15 mm** (realistic for modern fabs; avoids the flood of violations from an over-strict 0.254 mm default).

- **Silk to Silk Clearance**  
  - Global rule set to **0.15 mm**.  
  - Remaining true overlaps (0 mm) are resolved manually by moving/hiding ref-des.

Silk strategy:

- Keep designators for **ICs, connectors, ESD parts, testpoints and key inductors/filters**.
- Hide designators on dense 0402 fields around MCU and charger to reduce clutter (done via Designator string visibility, not by deleting logical designators).

### 7.6 Differential pair rule (High Speed → Differential Pairs Routing)

- Rule **`Diff_USB_FS`**  
  - Scope: Differential Pair / Pair Class = `USB_FS`.  
  - **Use Impedance Profile:** enabled, profile `D90_USB`.  
  - Width/Gap on L1 set from `D90_USB`.  
  - Optional **Max Uncoupled Length:** ~`2–3 mm`.

Differential pair defined in **Design → Differential Pairs Editor**:

- Pair: `USB_FS`  
- Positive net: `USB_FS_R_P`  
- Negative net: `USB_FS_R_N`.

---

## 8. Block 1 – USB-C + Protection Island (Placement Strategy)

**Components:**  
`J2`, `F101`, `D101`, `FL101` / `FL2`, `D102`, `ESD_CC1`, `ESD_CC2`, `R1`, `R104`, nearby caps, TP1/TP13.

**Role:** primary disturbance port for IEC 61000-4-2/-4/-5/-6.

### 8.1 VBUS chain

Placed on **RIGHT edge, lower half**:

1. **J2** on the edge; shield & GND pins via’d heavily into L2_GND.
2. **F101 PPTC** directly behind VBUS pins (inline).
3. **D101 TVS** just behind F101:
   - VBUS connected at the F101/BQ side.
   - GND pad with 2–3 vias straight into L2 within <0.5 mm.
4. First **input cap(s)** for BQ21061 at the VIN pin, forming a tiny loop with D101 path and GND.

Goal: smallest possible **VBUS + GND loop** at the connector → ESD/surge current dumped locally into L2.

### 8.2 D+ / D− path

Order on each line:

```text
J2 → FL101 CMC → D102 ESD array → series Rs (if used) → MCU pins
```
# PCB Layout Notes

## USB Differential Pair
- All on **L1**, tightly-coupled diff pair (**USB_FS class**, **Diff_USB_FS rule**).
- **FL101** placed immediately behind **J2**.
- **D102** just after FL101, with **GND pins via’d directly into L2**.
- Series resistors (if used) routed as a **matched pair**, close to **MCU**.

## 8.3 CC & SBU
- **R1/R104 (5k1)** right at CC pads.
- **ESD_CC1/2** as close as possible to connector pins:
  - **Pad → ESD → short trace to GND via**

## 8.4 Grounding & Copper
- **L2 solid GND** under whole island; no splits.
- **L1 GND pour** around J2, D101, D102, FL101, ESD_CCx, stitched to L2.
- Avoid running sensor nets through this area.
- **IEC view:** compact, well-referenced ESD/surge sink right at the port, reducing stress on **BQ21061/STM32** and lowering emissions on the USB cable.

---

## 9. Next Planned Block – Charger + LDO Island
*(To be detailed as placement matures – initial intent)*

- **BQ21061 (IC1)** between J2 and J1, rotated so:
  - **VBUS/IN** faces Zone A (USB).
  - **VBAT pins** face the battery connector.
  - **SYS/+3V3_SYS** faces MCU / rest of board.

### Inner Ring of High-Current Caps
- **C_IN (VBUS→GND)**
- **C_SYS (+3V3_SYS→GND)**
- **C_BAT (VBAT→GND)**  
Placed tight around the **BGA**, each with short **GND vias to L2**.

### Outer Ring of Sense/Control Components
- **ISET / PROG resistors**
- **TS network**
- **/CHG LED resistor**
- **/CE pull-ups**  
Placed on the **quiet side** away from USB switching.

- Use **short dog-bones** and local tight vias to escape BGA pins while keeping L2 intact.

---

## 10. Current Layout Status (Rev-A, Work-in-Progress)

### Stackup & Board Geometry
- **4-layer, 0.8 mm stack** exactly as in Section 1, including **S50** and **D90_USB impedance profiles**.
- Rounded-corner board outline defined; **Mechanical 1** used for outline/courtyard copies.

### Classes & Rules Wired Up
- Net classes: `PWR_MAIN`, `USB_FS`, `rf_50ohms`, `DIG_FAST`, `SENS_DIG`, `SENS_ANALOG`.
- Width, clearance and differential-pair rules in Section 7 are created and active, with priorities set.
- Local clearance rule **Clearance_IC3_Local** added to suppress false **PWR_MAIN spacing errors** inside STM32 package.

### Manufacturing Rules Tuned
- Global **mask-sliver rule** set to **0.08 mm**.
- Local mask-sliver relaxations:
  - **FL2 RF filter** (`MaskSliver_FL2`, allowing merged/near-merged mask).
  - Fine-pitch ICs **IC5 and IC7** (`MaskSliver_IC5_IC7`, 0.04 mm).
- **Silk-to-mask** and **silk-to-silk clearances** reduced to ~**0.15 mm**.

### Silkscreen Clean-Up
- Blanket resize of **designators** on Top/Bottom Overlay using PCB Filter + Properties.
- Dense **0402 fields** selectively hidden; key ref-des (**ICs, connectors, ESD parts, testpoints, filter inductors/caps**) kept visible.

### Keep-Out and Unions
- Incorrect **Keep-Out regions** within connector footprint **J3** corrected in PcbLib.
- Accidental union of “off-board” components exploded; unions now used only where explicitly helpful.

### Placement Progress
- **Zone A USB/protection cluster** around J2 placed as in Section 8.
- Initial placement of **STM32WB55 (IC3)** and RF front-end area established.
- Preparing to place **BQ21061** and its cap/sense ring between USB and battery connector.

### DRC Status
- Full **DRC report** generated; major error classes reduced by:
  - Tuning global rules.
  - Introducing local exceptions only where driven by vendor footprints or package limits.
- Remaining violations:
  - **Mask-sliver exceptions** on tight parts (tracked in Section 7.4).
  - Some **silk-to-silk overlaps** still to be cleaned.
  - **Board-outline clearance** around connectors where local relaxation may be justified.

---

## 11. Immediate Next Steps

### Charger/LDO Island
- Finalise **BQ21061 placement** and place **C_IN, C_SYS, C_BAT** hugging the BGA with their GND vias.
- Place **ISET/TS/CHG/CE resistors** as an outer ring on the “quiet” side.
- Start **fan-out of BQ21061** using short dog-bones and L2/L3 escape.

### USB Routing
- Route **USB_FS differential pair** from J2 → FL101 → D102 → MCU, honouring **Diff_USB_FS width/gap** and avoiding vias.
- Finalise **VBUS trunk** from J2 → F101/D101 → BQ21061.

### Zones B/C/D Refinement
- Tighten placement around **STM32WB + RF network** and verify antenna keep-outs.
- Place **sensors in Zone C** with clear separation from Zone A copper.
- Place **SW1, LED1, testpoints** in Zone D with good ESD paths and probe access.

### DRC & Documentation Loop
- Re-run **DRC** after each major placement/routing step.
- Record intentional **rule overrides** in this document.
- Capture key **screenshots** (Zone A island, charger island, RF area) for repo README and IEC/ISO documentation packs.

