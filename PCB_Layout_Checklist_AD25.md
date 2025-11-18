# PCB Layout Checklist (AD25, EMC-First for BLE-Control)

Target board: **BLE-Control** (STM32WB55 wearable controller)  
EDA: **Altium Designer 25 (AD25)**  
Stack-up target: **4-layer, 0.8 mm**, chip antenna, 0402 passives where possible.  
Standards mindset: **IEC 60601-1-2 Ed.4 (Class A), IEC 61000-4-2/-4-3** pre-compliance.

This checklist is written as if you are doing an **EVT Rev-A layout review**.  
Use it like a pre-flight list before you generate Gerbers / ODB++.

---

## 1. Layer stack & design rules

- [ ] **Layer count & thickness**
  - [ ] 4-layer stack defined in **Layer Stack Manager**.
  - [ ] Overall thickness ≈ **0.8 mm** (suitable for small wearables and chip antenna).
- [ ] **Layer naming / purpose**
  - [ ] `L1_Top` — High-density routing, MCU, RF, most components.
  - [ ] `L2_GND` — **Solid ground reference plane** (no big voids).
  - [ ] `L3_Power_Sig` — Power distribution + slower signals.
  - [ ] `L4_Bottom` — Non-critical routing, some discretes / testpoints.
- [ ] **Clearances & widths**
  - [ ] Default **clearance rule** set to suit fab (e.g. 4/4 or 5/5 mil).
  - [ ] Minimum track/space from fab capability, plus **tighter classes** only where needed.
  - [ ] **Solder mask expansion** checked (no slivers; comfortable for 0402).
- [ ] **Net classes**
  - [ ] Net classes defined for: `USB`, `RF_ANT`, `VBUS`, `+3V3_SYS`, high-current paths.
  - [ ] Power nets allowed **wider tracks** (e.g. 10–20 mil where space allows).
  - [ ] Critical nets kept out of “junk” rules by correct class assignment.

---

## 2. Grounding & return paths

- [ ] **Continuous GND plane (L2)**
  - [ ] No large **slots** or **islands** under:
    - STM32WB55
    - USB connector, ESD/TVS
    - Antenna feed & π-match
    - High-di/dt power loops (charger, load-switch, polyfuse).
- [ ] **Stitching vias**
  - [ ] GND stitching vias placed:
    - Around board edges (EMC “fence” where realistic).
    - Near any **layer transitions** for high-speed or noisy nets.
    - Around ESD parts and connectors.
- [ ] **Star / single-point where appropriate**
  - [ ] Battery and charger returns meet **close to charger IC**, not spread randomly.
  - [ ] High-current return paths **short and tight**, avoiding sensitive analog/RF areas.
- [ ] **Copper pours**
  - [ ] GND poured on **outer layers** where sensible but not fragmenting the plane.
  - [ ] No accidental “antenna stubs” of GND; poured regions are either meaningful or removed.

---

## 3. Power path (battery, charger, LDO, 3V3)

Applies to **BQ2106x**, LDO, load switch, fuel gauge and main 3V3 rail.

- [ ] **Source → load order**
  - [ ] `VBUS` → charger input kept short and wide (connector → polyfuse → TVS → charger).
  - [ ] Battery traces reasonably wide; charger **sense / PROG pins** kept short.
  - [ ] `+3V3_SYS` originates clearly at LDO / load switch output node.
- [ ] **Loop areas**
  - [ ] Input and output **decoupling caps hugging the IC pins** (charger, LDO).
  - [ ] Paths between IC and caps have **no detours or long jogs**.
- [ ] **Thermal & copper**
  - [ ] Power devices that dissipate heat (charger, load switch) have:
    - Small copper areas / thermal relief optimised per datasheet.
    - No giant heat-spreading copper that cuts up the GND plane unnecessarily.
- [ ] **Fuel gauge routing**
  - [ ] Sense lines for fuel gauge routed as **short, quiet traces**.
  - [ ] Gauge placed close to battery connector / cell pads (as per datasheet guidance).

---

## 4. Decoupling strategy

- [ ] **Per-pin decoupling on STM32WB55**
  - [ ] Each **VDD / VDDA / VDDRF** pin has its local cap as per ST guidelines.
  - [ ] Caps **as close as physically possible**: one pad-length away from the pin is ideal.
  - [ ] Vias from decaps into **L2_GND plane** placed immediately at cap pads.
- [ ] **Bulk vs high-frequency caps**
  - [ ] Bulk 4.7–10 µF caps at rail entry points (e.g. near LDO output, charger output).
  - [ ] 100 nF / 10 nF **small caps distributed** at loads (MCU, IMU, sensors, RF).
- [ ] **Return path awareness**
  - [ ] No decap connected through long ground tracks; always via directly to **plane**.
  - [ ] Avoid routing high-speed signals between decap and its IC pin.

---

## 5. USB + ESD + connector region

USB is both an **EMC trigger point** and **user touch point**.

- [ ] **Connector placement**
  - [ ] USB-C or micro-USB close to board edge; mechanical keep-outs respected.
  - [ ] VBUS and GND pins have **short, wide routes** to polyfuse and bulk caps.
- [ ] **ESD / TVS devices**
  - [ ] USB ESD diodes **immediately adjacent** to connector pins.
  - [ ] Return for TVS diodes goes **straight down into GND plane** via local via(s).
- [ ] **USB D+/D- routing**
  - [ ] D+/D- treated as a **differential pair** with controlled impedance (rule set).
  - [ ] Pair routed together (same length, same layer, no unnecessary stubs).
  - [ ] No split in the **reference plane** under the pair.
  - [ ] No via-hopping unless absolutely necessary; if used, both lines via together.

---

## 6. RF section (STM32WB55 → matching → antenna)

Chip antenna + π-match region is crucial.

- [ ] **Antenna location**
  - [ ] Antenna placed at board edge with **keep-out** under and around it (per datasheet).
  - [ ] No copper pours, ground planes, or tracks in antenna “no-go” volume.
- [ ] **Feed and π-match**
  - [ ] RF feed from STM32WB55’s RF pin to match network is **as straight and short as possible**.
  - [ ] Matching network (L/C pads) arranged in a **tight, clean line** with minimal parasitics.
  - [ ] RF line referenced to a **solid GND plane** (no gaps).
- [ ] **Grounding under RF**
  - [ ] Good GND under RF feed and match for consistent impedance.
  - [ ] Stitching vias around RF region tying top copper to L2_GND (but not under the antenna element).

---

## 7. Sensors, IO, buttons & LEDs

- [ ] **I²C sensors (IMU, baro, temp/RH, fuel gauge)**
  - [ ] SDA / SCL traces kept short and tidy; pull-ups located near the MCU or bus centre.
  - [ ] Sensors placed where routing is simple and **away from RF feed** where possible.
- [ ] **Interrupt / alert lines**
  - [ ] INT pins from sensors run to MCU with simple, direct traces.
  - [ ] Avoid long parallel runs next to RF or USB pairs.
- [ ] **Buttons & LEDs**
  - [ ] Button pads and LED series resistors located in a **logical cluster**.
  - [ ] Button ESD / TVS devices, if present, are near the edge / contact point with a tight return to GND.

---

## 8. EMC & ESD considerations (IEC 60601-1-2 / 61000-4-2/-4-3 mindset)

- [ ] **Small loop areas**
  - [ ] High-di/dt loops (charger input, switching nodes if any) kept very compact.
  - [ ] No large inadvertent current loops wandering across the board.
- [ ] **Segregation**
  - [ ] “Noisy” areas (USB, VBUS, charger) grouped together.
  - [ ] “Sensitive” areas (RF, reference nodes, sensor supplies) kept a small distance away.
- [ ] **Board edge stitching**
  - [ ] If space allows, GND “fence” vias around the perimeter, especially near connectors and antenna ground.
- [ ] **ESD hit paths**
  - [ ] For USB and any exposed metals: obvious path from user touch → ESD part → GND plane.
  - [ ] No thin, fragile GND traces in the likely ESD discharge path.

---

## 9. Testability & bring-up

- [ ] **Testpoints**
  - [ ] Key rails have testpoints: `VBUS`, `BAT`, `+3V3_SYS`, `GND`, `VBAT_MEAS`, `SWD_IO`, `SWD_CLK`.
  - [ ] Testpoints large enough for probe or pogo pins; not hidden under parts.
- [ ] **SWD / Tag-Connect**
  - [ ] Tag-Connect footprint placed with mechanical clearance and orientation markers.
  - [ ] SWD traces short and direct to MCU.
- [ ] **Power-up sequence sanity**
  - [ ] Can you safely power the board from:
    - USB only?
    - Battery only?
    - Both (no weird back-feeding)?
  - [ ] Test strategy recorded in docs (at least bullet-point level).

---

## 10. DRC, silkscreen & final checks

- [ ] **DRC**
  - [ ] All **Design Rule Checks (DRC)** run in AD25.
  - [ ] Only documented, understood waivers (if any) remain.
- [ ] **Silkscreen**
  - [ ] Refdes readable where possible (priority: connectors, power parts, debug interfaces).
  - [ ] Board orientation and polarity clearly marked (battery polarity, LEDs, connectors).
- [ ] **Fab outputs**
  - [ ] Layer set (Gerber or ODB++) matches the 4-layer stack with drills and mask.
  - [ ] Readme / notes for fab/assembly included in output pack (as needed).
- [ ] **Versioning**
  - [ ] Board clearly marked with **project name**, **Rev-A** (or similar), and **date** code.
  - [ ] Git tag / commit ID recorded somewhere in docs for traceability.

---

## Usage

- Use this checklist during:
  - Initial **floorplanning** (sections 1–4).
  - **Routing & tuning** (sections 5–8).
  - Final **EVT layout review** (sections 9–10).

- As the design evolves:
  - Add **board-specific items** (e.g. special keep-outs, mechanical features).
  - Cross-reference to ISO 13485 / 14971 docs where a layout choice mitigates a risk.

This is intentionally **practical and board-specific**, not a generic textbook list.
