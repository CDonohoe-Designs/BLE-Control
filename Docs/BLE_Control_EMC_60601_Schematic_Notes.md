# BLE-Control — EMC & IEC 60601 Schematic Notes (MCU_RF, Power_Charge_USB, Sensor_IO_ButtonsLED)

**Board:** BLE-Control — Wearable BLE Control Board (STM32WB55, Altium AD25)  
**Sheets covered:**  
- `MCU_RF.pdf`  
- `Power_Charge_USB.pdf`  
- `Sensor_IO_ButtonsLED.pdf`  

This document links specific schematic choices on the three key sheets to:

- **IEC 60601-1-2 Ed.4 (EMC, Class A focus)**  
- **IEC 60601-1 (basic safety & essential performance)**  
- **ISO 14971 (risk management)**

> ⚠️ Design-for-compliance showcase only — **not** a claim of certification.

---

## 1. Scope & assumptions

- BLE-Control is an **external wearable controller**, powered from:
  - Single-cell Li-Po, charged via **USB-C** (TI BQ21062 power path / charger), plus PPTC and TVS on VBUS.
  - Main rail **+3V3_SYS** feeding STM32WB55 and sensors. :contentReference[oaicite:3]{index=3}
- Intended environment: **professional healthcare / lab** (Class A behaviour for EMC). :contentReference[oaicite:4]{index=4}
- Only SELV levels on-board (≤ 5 V) and an assumed external, medically-approved PSU for wall power.

This note is about **“does the schematic enable EMC & safety?”**, not about final layout or test results.

---

## 2. Standards mapping (very short)

- **IEC 60601-1-2 (Ed.4)**  
  - Emissions: USB-C cable, RF section, SMPS loops, I/O lines.  
  - Immunity: ESD, RF fields, EFT/bursts, surges (within SELV context), conducted RF on cable shields.
- **IEC 60601-1**  
  - SELV only, creepage/clearance at low voltage, fault conditions (e.g., shorted ESD clamp, PPTC trip).  
  - “Essential performance” here is typically: *reliable BLE control / communication path* and safe behaviour under fault.
- **ISO 14971**  
  - Each protection block on the schematics can be mapped to a **risk control measure** (e.g., “ESD into button → TVS + series-R”).

The sections below are written so you can reference them directly in a risk file or test plan.

---

## 3. `MCU_RF.pdf` — STM32WB55 RF + core, EMC-aware schematic notes

### 3.1 RF front-end & antenna

**What this sheet likely contains:**

- STM32WB55 RF pins → **π-match (all DNP by default) → 2.4 GHz chip antenna**. :contentReference[oaicite:5]{index=5}  
- Coplanar waveguide (CPWG) intent + via-fence around RF trace. :contentReference[oaicite:6]{index=6}  
- Optional RF ESD (ultra-low-C TVS, DNP footprint) very close to the antenna feed. :contentReference[oaicite:7]{index=7}  

**EMC / 60601-1-2 rationale**

- **Emissions**:
  - Controlled 50 Ω RF path and π-match reduce reflections and stray radiation → fewer unwanted harmonics.
  - π-match DNP components give post-tune options without bodge-wires during pre-compliance EMC.
- **Immunity**:
  - RF TVS footprint (even if DNP initially) gives an easy path to harden against ESD or RF hits on the antenna.
  - Via-fence + controlled geometry help contain RF currents to the antenna region, reducing coupling into digital/power.

**Documentation hooks**

- Add a small schematic note:  
  `Note: π-match (C-L-C) left DNP for lab antenna tuning; may be populated per EMC/antenna test.`  
- In your EMC plan, reference this section as the “RF tuning and protection network” for IEC 60601-1-2 radiated tests.

---

### 3.2 STM32WB55 power decoupling, crystals & SMPS cell

**What this sheet likely contains:**

- STM32WB55CGU6 core + IO supply pins with distributed **100 nF / 1 µF decoupling**, short loops to the EPAD.  
- Clean crystal “islands” (HSE and LSE) with local loading caps and guard GND. :contentReference[oaicite:8]{index=8}  
- On-chip SMPS cell pins (if enabled) with their inductor and caps placed as a tight loop.

**EMC / 60601-1-2 rationale**

- **Emissions**:
  - Close decoupling reduces current loop area → less HF energy on planes / cables.
  - Proper crystal layout reduces harmonic radiation and clock-related noise coupling into RF & I/O.
- **Immunity**:
  - Local decoupling and SMPS layout discipline help the MCU ride through conducted RF / EFT noise on 3V3_SYS.
  - Stable supply = more robust BLE link under IEC 60601-1-2 stress tests.

**Documentation hooks**

- Add schematic text near supply pins, e.g.:  
  `Decoupling placed adjacent to pins; refer to STM32WB AN for EMC layout.`  
- In your **Power & Ground Rules** doc you already describe this; cross-link this sheet to that doc for traceability. :contentReference[oaicite:9]{index=9}  

---

### 3.3 Digital I/O & debug (SWD / Tag-Connect)

**What this sheet likely contains:**

- SWDIO/SWCLK, NRST, SWO, etc. → **Tag-Connect TC2030-NL** header. :contentReference[oaicite:10]{index=10}  
- Optional series resistors / RCs on SWD lines to tame edges (if needed).

**EMC / 60601-1-2 rationale**

- **Emissions**:
  - Short, point-to-point SWD traces into a probe-only connector avoid flying long debug cables in use.
- **Immunity**:
  - During tests, SWD isn’t normally connected; keeping it off a large cable harness reduces RF injection paths.

**Documentation hooks**

- Note that SWD is for **service / development only**, not used in the end-user environment.
- In the risk file: “SWD exposed only when enclosure open; not accessible to patient / normal operator.”

---

## 4. `Power_Charge_USB.pdf` — USB-C, charger, main rails

### 4.1 USB-C receptacle, PPTC, TVS & shield

**What this sheet likely contains (per README highlights)**: :contentReference[oaicite:11]{index=11}

- USB-C receptacle (VBUS, CC1/CC2, D+/D−, shield).  
- **PPTC** (e.g. Bourns MF-PSMF050X-2) in series with VBUS.  
- **VBUS TVS** very close to the connector.  
- Low-C **ESD diodes on CC1/CC2** (and pads for D+/D− ESD if you keep symmetry).  
- **Shield bleed** network: 1 MΩ // 1 nF (C0G) shell → GND.

**EMC / 60601-1-2 rationale**

- **Emissions**:
  - Shield bleed avoids a hard chassis-GND tie but gives RF a return path, reducing cable-radiated noise.
- **Immunity**:
  - VBUS TVS + PPTC: front-line defence for IEC 61000-4-2/-4-4/-4-5 style insults on the USB cable.
  - CC/USB ESD parts protect digital pins from IEC 61000-4-2 ESD at the connector.

**IEC 60601-1 / basic safety**

- PPTC limits fault current from an external PSU into the board (SELV side).
- Risk control: “ESD/surge on USB cable” → mitigated by TVS, PPTC, shield bleed, and PCB creepage/clearance.

**Documentation hooks**

- Add a text box next to the connector:  
  `USB-C entry: PPTC + TVS + ESD are primary protections for IEC 60601-1-2 Class A pre-compliance.`  
- In the risk log, link hazard “Overvoltage / ESD via charging port” → this schematic block as the control.

---

### 4.2 Charger + power path (BQ21062) to +3V3_SYS

**What this sheet likely contains:**

- **BQ21062** charger / power-path controller managing Li-Po charge and 3V3_SYS regulation. :contentReference[oaicite:12]{index=12}  
- Li-Po cell connector / pads, reverse polarity protection (may be PMOS or series element).  
- Output rail **+3V3_SYS** feeding system and any intermediate enables (e.g., `VDD_SENS` switch).

**EMC / 60601-1-2 rationale**

- SMPS / charger switching currents are confined locally with decoupling caps → less injection into planes and cables.
- Clear separation between noisy power path and sensitive RF / sensors regions helps pass conducted & radiated tests.

**IEC 60601-1 / safety**

- Single battery cell, SELV.  
- Reverse battery / fault handling: if included on this sheet, explicitly note its safety role.
- Over-charge, over-current, under-voltage are handled by the charger IC functions + PPTC.

**Documentation hooks**

- Add a note near BQ21062:  
  `Charger & power-path: see risk file section "Battery hazards" and IEC 60601-1 clause references.`  

---

## 5. `Sensor_IO_ButtonsLED.pdf` — human interface & sensor rails

### 5.1 Tactile button with TVS + series resistor

**What this sheet likely contains (per README):** :contentReference[oaicite:13]{index=13}  

- Single tactile button connected to an MCU GPIO.  
- **SOD882 TVS** diode placed at the button pad.  
- ~**100 Ω series resistor** between pad and MCU pin.

**EMC / 60601-1-2 rationale**

- **ESD immunity**:
  - TVS at the pad clamps IEC 61000-4-2 pulses before they reach the MCU.
  - 100 Ω series limits surge current into the micro and slows the edge of any injected transients.
- **Conducted RF / bursts**:
  - Series resistor and input capacitance form an RC that attenuates fast bursts/susceptibility on the line.

**IEC 60601-1 / safety**

- Front-panel / touch interface is SELV, and ESD protection reduces risk of latent damage that could undermine essential performance (button used, e.g., for mode change).

**Documentation hooks**

- Label this network on the schematic as:  
  `Button ESD + EMI network (TVS + 100R): see IEC 60601-1-2 ESD test plan.`  

---

### 5.2 Status LED and any sensor supply / I/O filtering

**What this sheet likely contains:**

- One small status LED + series resistor off 3V3_SYS.  
- (Possibly) sensor enable rail `VDD_SENS`, local decoupling, and headers/footprints for BMI270, BME280, TMP117 / MAX30208 etc. :contentReference[oaicite:14]{index=14}  

**EMC / 60601-1-2 rationale**

- **Emissions**:
  - Low-current LED drive (and optional RC) avoids large dI/dt on visible outputs.
- **Immunity**:
  - Local decoupling on `VDD_SENS`, short I²C lines, and optional series resistors/RC near sensors help ride through conducted RF and ESD on sensor pads.

**Documentation hooks**

- Tag `VDD_SENS` block as:  
  `Sensor rail decoupled and optionally switchable; see immunity test for sensor-functional performance.`  

---

## 6. Traceability & “how to use this doc”

This file should be used alongside:

- **`BLE-Control_Wearable_Schematic_Guide_AD25_v4.md`** — functional explanation per sheet. :contentReference[oaicite:15]{index=15}  
- **`Docs/BLE-Control_Power_Ground_Rails_v2.md`** — deeper layout / plane rules. :contentReference[oaicite:16]{index=16}  
- Your ISO 14971-style risk log and any IEC 60601-1/-1-2 oriented test plans.

For each **hazard / test item**, link back to:

- **Sheet name + figure number** in the schematic PDF, and  
- The relevant bullet in this file (EMC/safety rationale).

This gives reviewers and recruiters a clear view that:

1. The schematics reflect EMC / safety thinking.  
2. There is a paper trail from **requirement → schematic block → test**.

---

## 7. Open TODOs (fill in as you refine)

- [ ] Confirm refdes & footprints for:
  - USB-C TVS, PPTC, CC ESD, shield R//C.
  - RF TVS, π-match parts.
  - Button TVS & series resistor.
- [ ] Add small “EMC note” text boxes on each of the three schematic sheets pointing to this document.
- [ ] Cross-link this doc in `README.md` under:
  - “Medical-minded protection & EMC (Class A focus)”
  - “How this repo aligns with medical standards”.

