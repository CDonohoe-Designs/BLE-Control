
# BLE‑Control — Wearable BLE Control Board (Altium AD25)

**BLE‑Control** is a small, low‑power wearable control board built around the **STM32WB55** (BLE 5 + Cortex‑M4).  
It targets excellent battery life, a compact form factor, and strong EMC hygiene. The design includes USB‑C charging, a Li‑Po battery interface, an IMU, and a temperature+humidity sensor.

---

## Highlights
- **MCU:** STM32WB55CGU6 (BLE 5.0 + Cortex‑M4)
- **Power:** Single‑cell Li‑Po, **BQ24074** charger (USB‑C input), **TPS7A02‑3.3** LDO
- **Sensors:** **BMI270** (6‑axis IMU), **MAX17048** (fuel gauge, always‑on), **SHTC3** (temp+RH, switched)
- **Debug:** **Tag‑Connect TC2030‑NL** (solderless) for SWD
- **I/O:** 1x tactile button, 1x status LED, expansion pads (I²C/SPI/3V3/GND)
- **Form factor:** 4‑layer, 0.8 mm PCB, **0402 passives** (0603 only for bulk/ESD)

---

## Repository layout
```
BLE-Control/
├─ Hardware/
│  └─ Altium/
│     ├─ BLE_Control.PrjPcb
│     ├─ Schematic/
│     │  ├─ TopLevel.SchDoc
│     │  ├─ Power_Batt_Charge_LDO.SchDoc
│     │  ├─ MCU_RF.SchDoc
│     │  ├─ USB_Debug.SchDoc
│     │  ├─ IO_Buttons_LEDs.SchDoc
│     │  └─ Sensors.SchDoc
│     ├─ PCB/
│     │  └─ BLE_Control.PcbDoc
│     ├─ Libraries/
│     │  ├─ Schematic/BLE_Control.SchLib
│     │  ├─ PCB/BLE_Control.PcbLib
│     │  ├─ DBLib/BLE_Control.DBLib
│     │  ├─ Database/BLE_Control_Parts_DB.xlsx
│     │  └─ Integrated/(LibPkg + Project Outputs/*.IntLib)
│     ├─ OutputJobs/BLE_Control_Release.OutJob
│     ├─ Outputs/         # working outputs (temporary)
│     └─ Releases/        # versioned release packages (Gerbers, BOM, Pick&Place, PDFs)
├─ docs/
│  └─ BLE-Control_Wearable_Schematic_Guide_AD25.md  # per‑sheet design notes & values
├─ .gitattributes   # LFS for 3D/STEP/ZIP
└─ .gitignore
```

> **Note:** Some files are placeholders until you populate libraries and compile outputs. Keep paths **relative** so the project works on any machine.

---

## Documentation
- [Build Plan (AD25)](Docs/BLE-Control_Build_Plan_AD25.md)
- [One-Page Connection Checklist](Docs/BLE-Control_Connection_Checklist_OnePage.md)
- [Wearable Schematic Guide](Docs/BLE-Control_Wearable_Schematic_Guide_AD25.md)

---
## Datasheets
- [TI BQ24074 – Charger & PowerPath](Docs/Datasheets/TI_BQ24074_Datasheet.pdf)
- [TI TPS7A02-3V3 – Ultra-low-Iq LDO](Docs/Datasheets/TI_TPS7A02_Datasheet.pdf)
- [TI TPS22910A – Load switch (active-low)](Docs/Datasheets/TI_TPS22910A_Datasheet.pdf)
- [STM STM32WB55xx with BLE and ultra-low-power](Docs/Datasheets/stm32wb55ce.pdf)
- [STM STM32WB55xx HW Ref Des App Note AN5156](Docs/Datasheets/an5165_rf_hardware_STM32WB.pdf)
  
---
## EDA environment
- **Altium Designer 25.x** (tested with 25.3.3 build 18)
- Microsoft Access Database Engine 2016 (x64) – required by Altium to read Excel‑backed **DBLib**
- Git LFS for large binary assets (3D models, ZIP archives)

---

## Quick start
1. **Open** `Hardware/Altium/BLE_Control.PrjPcb` in Altium.
2. **Libraries**
   - **Integrated Library route (simple):** Open `Libraries/Integrated/*.LibPkg` → *Project → Compile Integrated Library* → install the generated `.IntLib` via **Components → (gear) File‑based Libraries → Installed → Install…**.
   - **Database Library route (param‑rich):** Open `Libraries/DBLib/BLE_Control.DBLib` (should show **Connected**). Field mappings must map **SchSymbolName→Library Ref**, **SchLibPath→Library Path**, **FootprintName→Footprint**. The Excel database lives at `Libraries/Database/BLE_Control_Parts_DB.xlsx`.
3. **Place** parts on `Schematic/*.SchDoc` from your `.IntLib` (or from the DBLib once symbols/footprints exist).
4. **Validate** the project and proceed to PCB layout (`BLE_Control.PcbDoc`).

For per‑sheet connectivity and starting values, see **`docs/BLE-Control_Wearable_Schematic_Guide_AD25.md`**.

---

## Schematic partition (what lives where)
- **TopLevel.SchDoc** — sheet symbols, global power flags, bus labels.
- **Power_Batt_Charge_LDO.SchDoc** — Li‑Po → **BQ24074** charger (USB‑C), **TPS22910A** gated sensor rail (**VDD_SENS**), **TPS7A02‑3V3** LDO, thermistor input, test pads.
- **MCU_RF.SchDoc** — **STM32WB55**, HSE 32 MHz & LSE 32.768 kHz crystals, decoupling, RF π‑match (DNP) to a **chip antenna**, SWD pins.
- **USB_Debug.SchDoc** — USB‑C receptacle, **5.1 kΩ Rd** on CC1/CC2 (sink‑only), ESD, optional USB‑FS to MCU, **Tag‑Connect TC2030‑NL** footprint (DNL).
- **IO_Buttons_LEDs.SchDoc** — 1× button, 1× green LED, small expansion pads.
- **Sensors.SchDoc** — **BMI270** (INT1/2 to EXTI pins), **MAX17048** (always‑on @VBAT), **SHTC3** (on **VDD_SENS**), I²C pull‑ups.

---

## Conventions & constraints
- **Passives:** 0402; 0603 only for bulk caps/ESD.
- **Stackup:** 4‑layer, 0.8 mm. L2 is **solid GND** (no splits). RF is CPWG on L1 with via fence.
- **Naming:** `VBAT`, `3V3`, `VDD_SENS`, `I2C_SCL/SDA`, `SENS_EN`, `BMI270_INT1/2`, `GAUGE_INT`.
- **SWD:** TC2030‑NL pinout (1=VTref, 2=SWDIO, 3=NRST, 4=SWCLK, 5=GND, 6=SWO opt.).
- **Antenna:** edge placement, ground keepout, π‑match **DNP** at bring‑up.

---

## BOM & releases
- **BOM source:** Excel‑backed DB (`Libraries/Database/BLE_Control_Parts_DB.xlsx`) with MPNs/parameters. Tie into OutJob or use Altium’s ActiveBOM.
- **Releases:** Use `OutputJobs/BLE_Control_Release.OutJob` to generate a package under `Releases/<rev>/` (schematic PDFs, PCB fab/assy files, XY, BOM). Keep `Outputs/` for intermediate builds only.

---

## Roadmap
- Populate full symbol/footprint libraries for all chosen parts.
- Route RF with final antenna footprint and keepout geometry per vendor DS.
- Add Draftsman templates for fab/assy drawings.
- Bring‑up checklist & test firmware stubs (USB DFU, I²C scan, IMU wake, fuel‑gauge read).

---
## STM32CubeIDE Firmware (STM32WB55CG, UFQFPN-48)

**Project path:** `Firmware/BLE_Control/` → **[Open Firmware README](Firmware/BLE_Control/README.md)**  
**Goal:** self-contained CubeIDE project that anyone can import and build.

**Toolchain (tested):** STM32CubeIDE 1.17.0 · STM32CubeWB (specify version) · STM32CubeProgrammer (specify)


**Wireless coprocessor (CPU2):**
- Use **STM32CubeProgrammer → Wireless/FUS** to flash the **BLE stack** (Full/Light/Concurrent).  
- Record the **stack version** in the Firmware README under *Toolchain / versions*.
---

### Bring-Up & Test
- **RF & PER Testing (STM32CubeMonitor-RF)** → [Docs/testing/BLE_Control_CubeMonitorRF_Testing.md](Docs/testing/BLE_Control_CubeMonitorRF_Testing.md)

---
## Links & Rescources

- [PCB Chip Antenna Hardware Design — Phil's Lab #139](https://www.youtube.com/watch?v=UQBMROv7Dy4)
- [STM32WB Getting Started Series](https://www.youtube.com/playlist?list=PLnMKNibPkDnG9JRe2fbOOpVpWY7E4WbJ-)
- [KiCad 7 STM32 Bluetooth Hardware Design (1/2 Schematic) — Phil's Lab #127](https://www.youtube.com/watch?v=nkHFoxe0mrU&t=623s)


