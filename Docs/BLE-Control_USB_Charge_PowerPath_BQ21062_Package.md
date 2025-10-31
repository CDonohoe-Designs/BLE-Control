# BLE‑Control — USB Charge & Power‑Path (BQ21062) Package

*Last updated:* 2025-10-31 13:35 UTC  
*Scope:* Consolidated design notes, BOM, sheet‑port net map, layout/bring‑up for **BQ21062** power‑path charger with **USB‑C (charge‑only)** front‑end and external **TPS7A02‑3.3 V** system LDO for STM32WB BLE wearable.

---

## 0) Primary Datasheets / References (clickable)
- **TI BQ21062** — 1‑cell linear charger with power path, LS/LDO, push‑button: [Product page](https://www.ti.com/product/BQ21062) · [Datasheet PDF](https://www.ti.com/lit/gpn/BQ21062)
- **TI BQ21061** — sibling device (internal LDO option discussed below): [Product page](https://www.ti.com/product/BQ21061) · [Datasheet PDF](https://www.ti.com/lit/gpn/bq21061)
- **TI TPS7A02‑3.3 V** — 200 mA, ultra‑low‑IQ LDO: [Product page](https://www.ti.com/product/TPS7A02) · [Datasheet PDF](https://www.ti.com/lit/ds/symlink/tps7a02.pdf)
- **GCT USB4105‑GF‑A** — USB‑C receptacle (16‑pin, top‑mount): [Product page](https://gct.co/connector/usb4105)
- **ST USBLC6‑2SC6** — 2‑line, very‑low‑C ESD for USB/CC: [Datasheet PDF](https://www.st.com/resource/en/datasheet/usblc6-2.pdf)
- **Littelfuse SMF5.0A** — 5 V TVS, SOD‑123FL: [Product page](https://www.littelfuse.com/products/overvoltage-protection/tvs-diodes/surface-mount/smf/smf5-0a)
- **Bourns MF‑PSMF050X‑2** — 0.5 A‑hold PPTC, 0805: [Datasheet PDF](https://www.bourns.com/docs/product-datasheets/mfpsmf.pdf)
- **Bourns MF‑MSMF050/16** — 0.5 A‑hold PPTC, 1206 (alt): [Datasheet PDF](https://www.bourns.com/docs/product-datasheets/mf-msmf.pdf)
- **Murata NCP15XH103F03RC** — 10 kΩ NTC, 0402: (Search on Murata site)  

> *Note:* Passive capacitors/resistors intentionally **not** linked per your preference. Use your AVL/DBLib for final selections.

---

## 1) Schematic Recipe (ready‑to‑implement)

### Core connections (minimum viable charger + power‑path)
- **IN (from protected VBUS)** → **4.7–10 µF, 25 V X7R** at **IN–GND**. Prefer 0603 for DC‑bias margin.
- **PMID (regulated system output)** → **22 µF, 10 V X7R** close to **PMID–GND**. This node feeds your 3V3 LDO/buck.
- **BAT** → battery +; add **≥ 1 µF** X7R at **BAT–GND** near IC; route to battery connector; include **TS** (thermistor) path.
- **VDD** (internal logic LDO) → **2.2 µF** to GND (mandatory).
- **VINLS** (input to LS/LDO block) → **≥ 1 µF** to GND.
- **LS/LDO** (aux LDO or load‑switch out) → **2.2 µF** to GND; optional 1.8 V/3.0 V rail ≤ 150 mA or leave unused.
- **GND** → solid plane under device; shortest loops for IN/PMID/VDD/LS caps.

**Operating heads‑up**  
**VIN:** typ. 3.4–5.5 V (20 V tolerant). Ensure the adapter path supports the input/charge limits you set.

### USB‑C “charge‑only” front‑end
`VBUS (J1)` → **PPTC (F1)** → **TVS (D1, SMF5.0A)** → *(optional)* **EMI bead (FB1)** → **BQ21062 IN**.  
- **CC1/CC2:** 5.1 kΩ **Rd** to GND (advertise UFP/sink).  
- **ESD:** **USBLC6‑2SC6** on CC and D± pins **right at the connector**.  
- If D± are unused, keep **ESD + guarded stubs**, mark nets `USB_D+_NC`, `USB_D-_NC`, **DNP** any series parts.

### Thermistor / TS pin
- **Preferred:** **10 kΩ NTC** to GND (e.g., 103AT curve) **and** **10 kΩ** fixed to GND (parallel) near the IC ground return for a ~25 °C center.
- **No NTC (lab only):** single **5 kΩ** to GND to spoof “temperature OK”.

### I²C & logic pins
- **VIO** → tie to **+3V3** (or to **VDD** if 3V3 not available on first boot).  
  Pull‑ups: **10 kΩ** on **SCL/SDA** to VIO.
- **CE** (charge enable): **LOW = enabled**. Internal pulldown → **leave NC** for charge‑enabled default or route to MCU.
- **LP** (battery‑only I²C enable): must be **HIGH** to allow I²C when VIN is absent (internal pulldown). Add **~100 kΩ** pull‑up to VIO and/or drive from MCU.
- **PG, INT**: open‑drain → **100 kΩ** pull‑ups to VIO; route to MCU (PG can also drive an LED via transistor if desired).
- **MR** (push‑button): momentary to GND; internal ≈125 kΩ pull‑up to **BAT**. Add ESD clamp near the switch.

### System power strategy (with **TPS7A02‑3V3**)
- Use **PMID** as the **system source** (stable regulated node) and feed an external **TPS7A02‑3.3 V** for MCU/BLE.
- The BQ2106x **LS/LDO** is convenient but **limited to ≈150 mA** and shares thermals with the charger path. The external LDO gives:
  - Higher/better **transient headroom** (200 mA class) and **fast response**
  - **Cleaner 3V3** for RF/MCU (independent PSRR & decoupling island)
  - **Thermal decoupling** during charging
  - More flexible **PMID mode** choices regardless of 3V3 stability
  - **Ultra‑low IQ** standby via TPS7A02 when the charger sleeps

### Bring‑up register starter (I²C after boot)
- **INLIM**: set input current limit for your source (e.g., 500 mA for a 5 V wall adapter; keep conservative on PC USB).
- **ICHG**: set charge current for the cell (e.g., C/2 if thermals allow).  
- **VREG**: set 4.20 V typical (or 4.35 V if the cell supports it).  
- **PMID mode**: select regulated voltage vs battery‑tracking vs pass‑through as needed.  
- **LS/LDO**: set voltage if used; otherwise leave disabled.

### Layout checklist (DSBGA‑20, 0.4 mm pitch)
- 4‑layer, laser microvias recommended. **Hug** caps to **IN, PMID, VDD, VINLS, LS/LDO** pins.
- Solid **GND** under the chip; shortest return paths; keep **IN/PMID/BAT** fat and short.
- Follow TI package **YFP0020** land pattern; avoid via‑in‑pad unless filled/capped.

---

## 2) BOM — USB‑Charge & Power‑Path (BQ21062 + TPS7A02)
> **DNP** = do not populate.

| RefDes | Qty | Value / Setting | Description | Suggested MPN (linked) | Package / Footprint | Notes |
|---|---:|---|---|---|---|---|
| **U1** | 1 | BQ21062 | 1‑cell Li‑ion charger w/ power‑path + LS/LDO | [TI **BQ21062YFPR**](https://www.ti.com/lit/gpn/BQ21062) | DSBGA‑20 (YFP0020, 0.4 mm) | Tight caps on IN/PMID/VDD/LS |
| **J1** | 1 | USB‑C Receptacle | USB connector (charge‑only) | [GCT **USB4105‑GF‑A**](https://gct.co/connector/usb4105) | USB‑C, 16‑pin | CC pull‑downs for UFP |
| **F1** | 1 | 0.5 A hold | PPTC resettable fuse | [Bourns **MF‑PSMF050X‑2**](https://www.bourns.com/docs/product-datasheets/mfpsmf.pdf) | 0805 | Choose one of F1/F1’ |
| **F1’** | 1 | 0.5 A hold | PPTC resettable fuse | [Bourns **MF‑MSMF050/16**](https://www.bourns.com/docs/product-datasheets/mf-msmf.pdf) | 1206 | Alt footprint; **DNP** if F1 fitted |
| **D1** | 1 | 5 V TVS | VBUS surge/ESD | [Littelfuse **SMF5.0A**](https://www.littelfuse.com/products/overvoltage-protection/tvs-diodes/surface-mount/smf/smf5-0a) | SOD‑123FL (SMAF) | Close to J1 VBUS |
| **U2** | 1 | 2‑line ESD | ESD for CC/D± | [ST **USBLC6‑2SC6**](https://www.st.com/resource/en/datasheet/usblc6-2.pdf) | SOT‑23‑6 | Place at connector |
| **FB1** | 1 | 120 Ω @100 MHz | EMI bead *(optional)* | — | 0402 | Between TVS and BQ21062 IN |
| **R1, R2** | 2 | 5.1 kΩ 1% | USB‑C **Rd** (CC1/CC2→GND) | — | 0402 | Advertise UFP/sink |
| **C1** | 1 | 4.7–10 µF, 25 V X7R | IN bulk | GRM188R61E106KA73 | 0603 | Right at **IN–GND** |
| **C2** | 1 | 22 µF, 10 V X7R | PMID bulk | GRM21BR61A226ME51 | 0805/0603 | As close as possible |
| **C3** | 1 | 1 µF, 10 V X7R | BAT decoupling | GRM155R71A105KE11 | 0402 | Near **BAT–GND** |
| **C4** | 1 | 2.2 µF, 10 V X7R | VDD decoupling | GRM155R71A225KE15 | 0402 | Mandatory |
| **C5** | 1 | 1–2.2 µF X7R | VINLS decoupling | — | 0402 | Near **VINLS** |
| **C6** | 1 | 2.2 µF X7R | LS/LDO output | — | 0402 | Near **LS/LDO** |
| **R3** | 1 | 10 kΩ | I²C pull‑up SCL→VIO | RC0402FR‑0710KL | 0402 | If not shared bus |
| **R4** | 1 | 10 kΩ | I²C pull‑up SDA→VIO | RC0402FR‑0710KL | 0402 | — |
| **R5** | 1 | 100 kΩ | LP pull‑up to VIO | RC0402FR‑07100KL | 0402 | I²C on battery‑only |
| **R6** | 1 | 100 kΩ | PG pull‑up to VIO | RC0402FR‑07100KL | 0402 | Open‑drain |
| **R7** | 1 | 100 kΩ | INT pull‑up to VIO | RC0402FR‑07100KL | 0402 | Open‑drain |
| **SW1** | 1 | Momentary NO | MR pushbutton to GND | EVQ‑PUA02K | SMD tact | ESD protect trace |
| **TH1** | 1 | 10 kΩ NTC | Battery thermistor | *Murata NCP15XH103F03RC* | 0402 | To **TS** (see R8) |
| **R8** | 1 | 10 kΩ | TS pull‑down (or divider) | RC0402FR‑0710KL | 0402 | 10 k∥10 k for 25 °C; or 5 k spoof |
| **U3** | 1 | 3.3 V LDO | System LDO from PMID → +3V3 | [TI **TPS7A02‑3.3**](https://www.ti.com/lit/ds/symlink/tps7a02.pdf) | SOT‑23‑5 / X2SON | Place close to load; add in/out caps |
| **C7, C8** | 2 | 1–4.7 µF X7R | TPS7A02 IN/OUT decoupling | — | 0402 | Check datasheet minimums |
| **TPx** | 5 | — | Test pads | — | — | TP_VBUS, TP_PMID, TP_BAT, TP_3V3, TP_GND |

---

## 3) Block‑Level Netname Map (Sheet Ports for AD25)
Use these **Sheet Ports** on `USB_Charge_PowerPath.SchDoc` so the sheet drops cleanly into TopLevel.

### Power Ports (Outputs from this sheet)
- **PMID_SYS** → (Output) From **PMID** (after C2). Feeds **TPS7A02‑3V3** (or buck).
- **BAT** → (Bidirectional/Power) Battery positive from **BAT** pin / JST.
- **VIO_3V3** → (Power) Logic pull‑up rail for charger I/O (tie to +3V3 system).
- **LDO_1V8_SENS** → (Output, optional) From **LS/LDO** if used to power sensors (≤150 mA).

### Power Ports (Inputs into this sheet)
- **USB_VBUS** → (Input) Raw VBUS from USB‑C J1.  
  Local nets: `VBUS_RAW` (J1), `VBUS_FUSED` (after F1/F1’), `VBUS_PROT` (after TVS/FB1) → **IN**.
- **GND** → (Power) Ground.

### I²C & Control (to MCU)
- **I2C1_SCL** ↔ U1 **SCL** (10 kΩ pull‑up to VIO_3V3).
- **I2C1_SDA** ↔ U1 **SDA** (10 kΩ pull‑up to VIO_3V3).
- **CHG_PG** ← U1 **PG** (100 kΩ pull‑up to VIO_3V3).
- **CHG_INT** ← U1 **INT** (100 kΩ pull‑up to VIO_3V3).
- **CHG_CE** → U1 **CE** (NC = enabled by default; or drive from MCU).
- **CHG_LP** → U1 **LP** (100 kΩ pull‑up to VIO_3V3 so I²C works on battery).
- **BTN_MR** → U1 **MR** (momentary to GND; ESD close to switch).

### Charger Pin → Net Quick Map
- **IN** → `VBUS_PROT` + C1 to GND  
- **PMID** → `PMID_SYS` + C2 to GND  
- **BAT** → `BAT` + C3 to GND + battery connector + TH1 to TS  
- **VDD** → C4 to GND (local only)  
- **VINLS** → C5 to GND (local only)  
- **LS/LDO** → `LDO_1V8_SENS` + C6 to GND (or NC)  
- **SCL/SDA** → `I2C1_SCL/I2C1_SDA` (R3/R4 to `VIO_3V3`)  
- **PG/INT** → `CHG_PG/CHG_INT` (R6/R7 to `VIO_3V3`)  
- **CE/LP** → `CHG_CE/CHG_LP` (LP also has R5→`VIO_3V3`)  
- **MR** → `BTN_MR` (switch to GND)  
- **TS** → `TH1` (10 k NTC) + `R8` (10 k to GND) *(or single 5 k→GND to spoof)*  
- **VIO** → `VIO_3V3`  
- **GND** → `GND`

### Quick “paste list” of sheet ports (for Altium)
```
# Inputs
USB_VBUS (Input)
GND (Power)

# Outputs
PMID_SYS (Power Output)
BAT (Power)
VIO_3V3 (Power)        ; tie to global +3V3
LDO_1V8_SENS (Power Output, optional)

# Control/I2C
I2C1_SCL (Bidirectional)
I2C1_SDA (Bidirectional)
CHG_PG (Output)
CHG_INT (Output)
CHG_CE (Input)
CHG_LP (Input)
BTN_MR (Input)
```

---

## 4) ERC / DFM Nudges
- Place **PWR_FLAG** on `PMID_SYS`, `BAT`, `VIO_3V3` if your ruleset needs explicit sources.
- Keep **C1/C2/C4/C5/C6** within **< 2–3 mm** of pins; give them a local GND island stitched to main GND.
- Fanout DSBGA with **microvias**; keep **IN/PMID/BAT** short & wide; avoid uncapped via‑in‑pad.
- For charge‑only builds, mark **D± series parts DNP** and guard stubs.
- Add **TP_VBUS, TP_PMID, TP_BAT, TP_3V3, TP_GND** for bring‑up and safety probing.

---

## 5) Why external TPS7A02‑3V3 vs. BQ21061 LS/LDO
**Use BQ2106x LS/LDO** when you need minimal BOM, small loads (<~100–150 mA peaks), and accept that regulation/thermals are coupled to the charger.

**Use TPS7A02‑3V3** (recommended here) when you want:
- **200 mA** headroom with **fast transients** for MCU/BLE bursts
- **Cleaner 3V3** (independent PSRR/decoupling from the charger domain)
- **Thermal decoupling** so charging dissipation doesn’t heat your 3V3 regulator
- Flexible **PMID** configuration (regulated/track/pass‑through) without risking 3V3 stability
- **Ultra‑low standby IQ** without depending on charger state

---

## 6) Notes for README integration
- Place at: `docs/Power/USB_Charge_PowerPath_BQ21062.md`  
- Cross‑link from README: “See **USB Charge & Power‑Path (BQ21062)** for schematic, BOM, and bring‑up.”
- Keep **datasheet PDFs** in `docs/Datasheets/` if you want to vendor‑pin versions; otherwise link out as above.
