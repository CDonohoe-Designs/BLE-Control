# BLE-Control PCB Layout Checklist (AD25, EMC-First)

Target board: **BLE-Control** – STM32WB55 BLE wearable controller  
EDA: **Altium Designer 25 (AD25)**  
Stackup target: **4-layer, 0.8 mm**, 0402 passives (0603 only where needed)

Use this file as a working checklist while taking the design from **EVT-A schematics** to the first routed PCB.

---

## 0. Scope & Sheet Map

Main schematic sheets (as of EVT-A):

- **Power_Charge_USB.SchDoc**  
  USB-C (VBUS), protection, BQ21061 charger, TPS7A02 LDO, battery connector, main 3V3_SYS rail.
- **MCU_RF.SchDoc**  
  STM32WB55, USB FS interface, RF π-match + SAW + chip antenna, SMPS network, crystals, SWD.
- **Sensor_IO_Buttons_LED.SchDoc**  
  TPS22910A 3V3_SENS switch, sensors (TMP117, BMI270, SHTC3), button and LED, sensor I²C, testpoints.

---

## 1. Pre-Layout Sanity (AD25)

Do this once before touching the PCB.

### 1.1 Compile the project

- In Altium: `Project → Compile PCB Project`.
- Fix **all Errors** and any surprising **Warnings**, especially:
  - Duplicated net labels
  - Unconnected ports
  - Components without footprints
  - Power pins not connected as intended

### 1.2 Push schematics to PCB

1. Make sure you have a PCB:
   - If needed: `File → New → PCB`, save as  
     `Hardware/Altium/BLE-Control.PcbDoc`.
2. Update PCB from schematics:
   - `Design → Update PCB Document "BLE-Control.PcbDoc"…`
   - In the ECO dialog:
     - Accept **Add/Update all components & nets**.
     - `Validate Changes` → `Execute Changes` → `Close`.

You should now see all components “dumped” on the PCB workspace.

### 1.3 Units & grids

- In PCB:
  - `Properties` panel → **Units: mm**
- Bottom right (status bar):
  - **Snap Grid:** `0.05 mm`  
  - **Visible Grid:** `0.50 mm`

These are comfortable for 0402 / QFN work on a small board.

---

## 2. Board Outline & Zones

### 2.1 Board shape

1. Draw a simple mechanical outline (Mechanical 1) or sketch the shape directly.
2. Set board shape:
   - `Design → Board Shape → Edit Board Shape` and draw  
     or  
   - `Design → Board Shape → Define From Selected Objects` if you drew a mech outline first.

Initial guess: ~**30 × 35 mm** rectangle (adjust later to suit mechanics/enclosure).

### 2.2 Functional zones

Pick edges and zones early:

- **RF edge:** one short edge reserved for the **chip antenna**.
- **USB edge:** opposite edge reserved for **USB-C connector**.
- **Battery edge:** choose a convenient edge for the battery connector (mechanics-dependent).
- **Sensor corner:** quieter quadrant for TMP117/BMI270/SHTC3 and 3V3_SENS island.

### 2.3 Keepouts & clearances

- Create an RF keepout under/around **ANT1**:
  - On **Mechanical 1** (or a dedicated layer), draw a rectangle extending several mm inside the board.
  - Use **keepout regions** on copper layers so there is:
    - No copper directly under the chip antenna
    - No signal/vias cutting through the antenna region
- In `Design → Rules… → Placement → Component Clearance`:
  - Global clearance: ~**0.2 mm**.
  - In practice: leave extra free space around:
    - ANT1 + RF π-match + SAW filter
    - USB-C & ESD/PPTC cluster

---

## 3. Layer Stack (4-Layer, 0.8 mm)

In AD25: `Design → Layer Stack Manager`.

Suggested stack:

- **L1 – Top:**  
  Components, RF, most signals
- **L2 – GND Plane:**  
  **Solid** ground (no splits)
- **L3 – Power / Slow Signals:**  
  3V3_SYS, 3V3_SENS regions, VBAT_PROT, slow control nets
- **L4 – Bottom:**  
  Secondary routing, testpoints, SWD header if needed

Guidelines:

- Keep **L2 as an unbroken ground plane**; only via barrels pass through it.
- Route **RF trace (MCU RF pin → SAW → π-match → ANT1)** on **L1 only** as a coplanar waveguide with ground (CPWG) over L2 GND.
- Add **ground stitching vias**:
  - Around RF area
  - Along board perimeter (~1–2 mm spacing)
  - Around any ground-referenced shields or island regions

---

## 4. Placement Order

Place in this order; don’t worry about routing until the big pieces are well-positioned.

### 4.1 RF & MCU Cluster (MCU_RF.SchDoc)

**Priority:** RF integrity, SMPS loop, decoupling, crystals, SWD.

1. **Chip antenna & RF chain**
   - Place **ANT1** on the designated RF edge, aligned per its datasheet.
   - Place RF parts in a straight line inward from the edge:
     - **ANT1** → π-match (C/L/C) → **SAW filter** → RF ESD → **RF pin on STM32WB**.
   - Keep this chain:
     - Very short (a few mm total route)
     - Straight (no sharp 90° corners; use 45° or gentle curves)
     - Surrounded by **plenty of GND vias** close to the trace.

2. **STM32WB55 (MCU)**
   - Place **IC3** so that:
     - RF pin faces the RF chain.
     - SMPS pins (VLXSMPS, VDDMPS, etc.) face their inductor/cap cluster.
     - HSE/LSE pins face their crystals.
   - Leave enough room around the QFN for:
     - Decoupling caps
     - SWD header routing
     - Stitching vias to L2

3. **Decoupling & SMPS network**
   - For **each** VDD/VDDA pin:
     - Place its **100 nF cap** immediately beside the pin.
     - Route **shortly** to the pin and directly into a GND via.
   - Place bulk caps (e.g. **4.7 µF**) near:
     - where 3V3_SYS enters the MCU region
     - key analog rails (VDDA) if used
   - SMPS:
     - SMPS inductor(s) + caps form a **tight local loop** with minimal area.
     - Keep SW node copper **small and contained**, away from crystals, RF, and sensitive lines.

4. **Crystals**
   - **HSE crystal + load caps + series resistor**:
     - Keep the crystal right beside the MCU HSE pins.
     - Short, symmetric traces.
     - Small local GND “island” tied via several vias to the GND plane.
   - **LSE crystal + caps**:
     - Same principles, but less critical on trace length.

5. **SWD header (Tag-Connect or 0.05" header)**
   - Place SWD header near an accessible edge (non-RF, non-USB).
   - Keep SWDIO/SWCLK relatively short and clear of aggressive switching areas.
   - Make sure there is physical clearance for the Tag-Connect plug or debug cable.

---

### 4.2 Power, USB & Battery (Power_Charge_USB.SchDoc)

**Priority:** robust VBUS path, compact charger region, clean 3V3_SYS.

1. **USB-C connector**
   - Place **USB-C receptacle** on the chosen USB edge.
   - Fan out:
     - VBUS → PPTC fuse → TVS → filter/beads → charger VIN.
     - D+/D- → common-mode choke / series resistors → MCU USB pins.
     - CC pins → 5.1 kΩ Rd resistors → ground.

2. **VBUS / high-current path**
   - Use **wide copper** on L1 for:
     - VBUS from connector through PPTC and protection to charger VIN.
   - Keep this loop short and away from RF side.
   - Provide **GND return path** under it on L2.

3. **USB D+/D- differential pair**
   - Treat as a **differential pair** from connector to MCU:
     - Keep them length-matched.
     - Constant spacing, same layer.
     - Minimise via count (ideally no layer changes).
   - Avoid routing under/through noisy regions (SMPS, RF, etc.).

4. **Charger (BQ21061) + LDO (TPS7A02-3.3)**
   - Place charger IC close to:
     - VBUS entry point
     - Battery connector (VBAT_PROT)
   - Place LDO close to where 3V3_SYS will fan out.
   - For each IC:
     - Place input/output caps right at the pins.
     - Keep NTC / TS network physically close to battery connector (if used for pack NTC).
   - Plan a **3V3_SYS polygon** on L3 feeding:
     - MCU area
     - Sensor island (through TPS22910A)
     - Other loads

5. **Power testpoints**
   - Add TPs where you will probe early in bring-up:
     - USB_VBUS
     - VBATT_RAW / VBAT_PROT
     - 3V3_SYS
     - Charger STAT pin / /INT pin
     - LDO output if separate

---

### 4.3 Sensors, Button & LED (Sensor_IO_Buttons_LED.SchDoc)

**Priority:** quiet I²C corner, clean 3V3_SENS island, good UX placement.

1. **TPS22910A and 3V3_SENS island**
   - Place **TPS22910A** near the MCU / 3V3_SYS area.
   - The bead and caps form a **clean “sensor power” island**:
     - 3V3_SYS → bead → 3V3_SENS decouplers → sensor quadrant.
   - On L3, dedicate a local copper region for **3V3_SENS** in the sensor corner.

2. **Sensor placement**
   - Group **TMP117**, **BMI270**, **SHTC3** fairly close together.
   - Route I²C lines (SCL/SDA) short and without unnecessary vias.
   - Place each sensor’s 100 nF decoupler right at its VDD pin.

3. **Button & LED**
   - Place **button** near a user-reachable edge.
   - Keep:
     - ESD protection device right next to button pad.
     - Series resistor, filter, and pull-ups close together.
   - Place **LED** where it will be visible, with its series resistor nearby.

4. **Debug / sensor testpoints**
   - Add/keep TPs for:
     - 3V3_SENS
     - SENS_EN or load-switch gate
     - Sensor INT / ALERT lines
     - BTN1 node

---

## 5. Design Rules (Set Before Routing)

In PCB: `Design → Rules…`

### 5.1 General rules

- **Clearance**
  - Global: **0.2 mm**
  - Create specific rules if needed for:
    - RF nets (extra clearance to noisy nets)
    - USB diff pair region

- **Width**
  - Regular signals: **0.10–0.125 mm**
  - 3V3_SYS: **0.25 mm+** traces or polygons
  - 3V3_SENS: similar to 3V3_SYS but confined to sensor region
  - VBUS / battery: **0.30–0.40 mm+**

- **Vias**
  - General via: drill **0.25–0.30 mm**, pad **0.55–0.60 mm** (check with fab capabilities).
  - Use extra GND stitching vias around:
    - RF trace and antenna region
    - Board perimeter
    - Between noisy and quiet regions

### 5.2 Differential pairs (USB FS)

- `Design → Rules → Electrical → Differential Pairs Routing`
- Create a rule for the **USB_FS** pair:
  - Assign to nets `USB_FS_R_P` / `USB_FS_R_N` (or equivalent).
  - Set width/gap per your stack (start with a typical 90 Ω diff guess; refine later with fab calculator).
- Keep pair on the **Top layer** from connector to MCU if possible.

### 5.3 RF & SMPS special handling

- **RF nets** (MCU RF pin, SAW, π-match, ANT1):
  - Restrict to **Top layer only**.
  - Use a dedicated routing rule for:
    - Specific width (for 50 Ω CPWG)
    - Tighter clearance where needed.
- **SMPS nets**:
  - Create a rule for the SMPS switch node:
    - Wider copper (current-capable)
    - Minimise layer changes (ideally Top only).
  - Keep SMPS loop area small and contained.

---

## 6. Routing Strategy (High-Level)

1. **Finish placement first** (especially MCU/RF/SMPS and USB/charger).
2. **Route RF section**:
   - Short, clean RF chain.
   - Add GND fencing vias.
3. **Route power rails**:
   - VBUS, VBAT, 3V3_SYS, 3V3_SENS.
   - Pour polygons for GND (L2 plane, plus top/bottom pours tied with vias).
4. **Route USB diff pair**:
   - Connector → filter → MCU.
5. **Route MCU high-priority nets**:
   - Crystals, SWD, key interrupts.
6. **Route sensors & I²C**:
   - Keep lengths modest and avoid crossing noisy regions.
7. **Tidy up and repour all polygons**:
   - Check for split ground, islands, or unintended voids.

---

## 7. Git & Repo Notes

### 7.1 Ignore staging libraries

Add this to `.gitignore` so local staging libs don’t pollute the repo:

```gitignore
###############################################################################
# Altium staging libraries (not for source control)
###############################################################################
Hardware/Altium/Libraries/_staging/
