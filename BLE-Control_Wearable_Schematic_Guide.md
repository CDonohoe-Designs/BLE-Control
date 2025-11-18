# BLE-Control Wearable Schematic Guide

Small wearable, EMC-first, BLE on STM32WB55. This guide explains each schematic sheet and key design choices so layout and bring-up are predictable.

Target: 0402 passives (use 0603 only for bulk/ESD), 4-layer 0.8 mm, TC2030-NL SWD, chip antenna with DNP π-match.  
Power path (current revision): BQ21061 Li-ion charger + power-path, TPS7A02-3.3 as main +3V3_SYS LDO, and TPS22910A gating the 3V3_SENS sensor rail.

Update: USB-C VBUS protection now specifies a PPTC: Bourns MF-PSMF050X-2 (0805, I_hold = 0.5 A), sized for ILIM ≈ 500 mA. Keep a 0 Ω DNP bypass pad in parallel for bring-up.

----------------------------------------------------------------------
TABLE OF CONTENTS
----------------------------------------------------------------------

- TopLevel.SchDoc
- Power_Charge_USB.SchDoc
- MCU_RF.SchDoc
- Sensor_IO_Buttons_LED.SchDoc
- Testpoints_Assembly.SchDoc
- TC2030 (SWD) hook table
- EMC & layout rules (wearable)
- Values cheat-sheet (start points)
- Battery selection & connector
- Bring-up checklist (board-level)

======================================================================
TopLevel.SchDoc
======================================================================

Purpose: hierarchy and net connectivity only (no real circuitry).

What to include

- Sheet symbols for:
  Power_Charge_USB
  MCU_RF
  Sensor_IO_Buttons_LED
  Testpoints_Assembly

- Global power / net flags:
  VBATT_RAW
  VBAT_PROT
  PMID
  +3V3_SYS
  3V3_SENS
  USB_VBUS
  GND

- Bus / important nets:
  Charger I2C: I2C_CHG_SCL, I2C_CHG_SDA
  Sensor I2C: I2C3_SENS_SCL, I2C3_SENS_SDA
  Interrupts / control: BMI270_INT1, BMI270_INT2, TMP117_ALERT, BQ_INT, SENS_EN, CE_MCU, BTN1, LED_STAT_N

- RF nets:
  RF1 (from MCU) -> π-match -> RF1_FLT -> filter -> RF1_ANT (to antenna)

- SWD bundle:
  SWDIO, SWCLK, NRESET, SWO (optional), VTREF, GND

Project ordering (AD25)

In Project -> Project Options -> Documents, order:
TopLevel -> Power_Charge_USB -> MCU_RF -> Sensor_IO_Buttons_LED -> Testpoints_Assembly

TopLevel appears first for readability; ERC uses Validate Project in AD25.

======================================================================
Power_Charge_USB.SchDoc — BQ21061 + TPS7A02-3.3 + TPS22910A
======================================================================

POWER ARCHITECTURE OVERVIEW

USB-C (J2, USB4105-GF-A)
  |
  [TVS]    SMF5.0A -> GND at connector
  |
  [PPTC]   Bourns MF-PSMF050X-2 (0805, I_hold = 0.5 A)
  |
  USB_VBUS
  |
  (ESD + CMC on D+/D- & CC)
  |
  VIN_BQ_F
  |
  [FB101]  BLM15AG121 -> VIN_BQ
  |
  IN -> BQ21061 -> PMID ------------------------------+
                |                                     |
               BAT <-> VBAT_PROT <- Q101              |
                |                                     |
             VBATT_RAW (J1)                          |
                                                     |
                                                 IN -> TPS7A02-3.3 -> +3V3_SYS
                                                             |
                                                            FB2
                                                             |
                                                        TPS22910A -> 3V3_SENS

----------------------------------------------------------------------
BQ21061YFPR
----------------------------------------------------------------------

- Full power-path Li-ion charger.
- Handles VBATT_RAW (via PFET Q101) and creates PMID (system node).
- Manages battery charge while supplying system load from USB or battery.

----------------------------------------------------------------------
TPS7A02-3.3
----------------------------------------------------------------------

- Generates +3V3_SYS from PMID.
- EN is tied to IN (always on when PMID is valid).
- Ultra-low IQ and good PSRR.

Design intent: MCU cannot accidentally shut off its own 3V3 rail via firmware.

----------------------------------------------------------------------
TPS22910A
----------------------------------------------------------------------

- VINA: +3V3_SYS_RB (after bead FB2).
- VOUTA: 3V3_SENS.
- ON: SENS_EN from MCU.
- GND: solid plane.

Use TPS22910A to:

- Power-gate BMI270, SHTC3, TMP117 etc. on 3V3_SENS.
- Allow "sensors off" mode for EMC testing and low-power operation.

----------------------------------------------------------------------
USB-C (charge-only) rules
----------------------------------------------------------------------

- Receptacle: GCT USB4105-GF-A.
- CC1/CC2: 5.1 kΩ Rd to GND (sink/UFP role).
- D+ / D-:
  - Routed through ACM2012D-900-2P-T00 CMC.
  - Protected by USBLC6-2SC6 ESD array.
  - USB data not used initially, but hardware is present for future DFU.

PROTECTION CHAIN (VBUS)

- USB_VBUS TVS SMF5.0A -> GND at connector.
- Series PPTC MF-PSMF050X-2.
- Optional TP on USB_5V before bead (for scope probe).

Placement order (VBUS):

J2 VBUS -> SMF5.0A (to GND) -> MF-PSMF050X-2 -> TP_USB_5V -> FB101 -> BQ21061 IN (VIN_BQ)

Keep the VBUS loop tiny: connector -> TVS -> PPTC -> BQ IN -> BQ GND.

----------------------------------------------------------------------
BQ21061 I/O & logic domain
----------------------------------------------------------------------

- VIO: tied to +3V3_SYS
  - I2C: I2C_CHG_SCL, I2C_CHG_SDA
  - Control: CE_MCU, LP, MR, PG, INT

- VINLS: tied to PMID, decoupled per datasheet.
- LSLDO: output of internal LDO (decoupled only; taken to TP_LSLDO for debug).
- TS: BAT_NTC_10K from battery connector; NTC or bias network per datasheet.

I2C pull-ups (charger bus)

- I2C_CHG_SCL, I2C_CHG_SDA:
  4.7–10 kΩ pull-ups to +3V3_SYS (VIO domain).

Status / control

- BQ_INT: open-drain interrupt -> MCU GPIO with ~100 kΩ pull-up.
- CE_MCU: MCU-driven charger enable.
- PG (if used): charger power-good -> MCU GPIO with pull-up.
- LP, MR: ship-mode and wake/long-press control.

----------------------------------------------------------------------
TPS7A02-3.3 (system 3V3)
----------------------------------------------------------------------

- IN = PMID.
- EN = IN (always on when charger power-path is alive).
- OUT = +3V3_SYS.
- Decoupling per DS, e.g. 1 µF IN, 1 µF OUT very close to IC.

Design intent

- MCU cannot accidentally kill its own 3V3.
- System power shaped mainly by BQ21061 configuration plus sensor rail gating.

----------------------------------------------------------------------
TPS22910A (3V3_SENS gate)
----------------------------------------------------------------------

- VINA: +3V3_SYS_RB (after FB2).
- VOUTA: 3V3_SENS.
- ON: SENS_EN (MCU).
- Use to disconnect sensors for EMC testing and low-power.

----------------------------------------------------------------------
Schematic checklist — Power_Charge_USB
----------------------------------------------------------------------

USB-C J2

- Nets: USB_VBUS, USB_FS_CONN_P, USB_FS_CONN_N, USB_CC1, USB_CC2.
- CC resistors: 5.1 kΩ from each CC pin to GND.
- D+, D- routed as differential pair through CMC and ESD.

Protection in place

- SMF5.0A TVS on USB_VBUS at connector.
- MF-PSMF050X-2 PPTC in series with VBUS.
- USBLC6-2SC6 ESD array on D+, D-, CC1, CC2.
- ACM2012D-900-2P-T00 CMC on D+/D-.

Battery connector J1

- Nets: VBATT_RAW, BAT_NTC_10K, GND.
- Q101 PFET as reverse protection from VBATT_RAW to VBAT_PROT.

ICs and rails

- BQ21061:
  All required caps on IN, PMID, BAT, VDD, VINLS, LSLDO per datasheet.
- TPS7A02:
  IN/OUT caps per datasheet.
- TPS22910A:
  SENS_EN clearly labelled, 3V3_SENS exported to Sensor sheet.

Test pads

- TP_USB_5V
- TP_VBATT_RAW
- TP_VBAT_PROT
- TP_PMID
- TP_+3V3_SYS
- TP_VDD
- TP_LSLDO
- TP_VIN_BQ

----------------------------------------------------------------------
Bring-up plan — Power sheet
----------------------------------------------------------------------

No battery, no USB

- Confirm no rails are unexpectedly present.
- Measure TP points for 0 V except maybe leakage microvolts.

Battery only

- Connect known-good Li-Po to J1.
- Verify VBAT_PROT ≈ VBATT_RAW minus PFET drop.
- Confirm PMID ≈ battery voltage.
- Confirm +3V3_SYS present and stable.

USB only (no battery)

- Apply 5 V current-limited supply (~0.5–1 A).
- Check USB_VBUS, VIN_BQ_F, VIN_BQ, PMID, +3V3_SYS.
- Confirm BQ21061 enumerates on I2C_CHG_SCL/SDA.

USB + battery

- Confirm charge current ≈ configured ICHG.
- Check BQ21061 temperature under worst case charge.

Sensor rail

- Toggle SENS_EN from MCU.
- Observe 3V3_SENS appearing/disappearing cleanly.
- Verify no large dips on +3V3_SYS when sensors turn on.

----------------------------------------------------------------------
BOM highlights — Power path & protection
----------------------------------------------------------------------

- Charger: TI BQ21061YFPR — 1-cell Li-ion charger + power-path.
- Main LDO: TI TPS7A0233PDBVR — 3.3 V ultra-low IQ LDO (+3V3_SYS).
- Sensor load switch: TI TPS22910AYZVR — 3V3_SENS gating.
- USB-C receptacle: GCT USB4105-GF-A.
- TVS (VBUS): Littelfuse SMF5.0A (SOD-123FL).
- ESD array: ST USBLC6-2SC6.
- PPTC: Bourns MF-PSMF050X-2 (0805, I_hold 0.5 A).
- CMC: ACM2012D-900-2P-T00 (USB D+/D-).
- Ferrite beads: Murata BLM15AG121SN1D (120 Ω @ 100 MHz) on VIN_BQ and 3V3_SENS.

----------------------------------------------------------------------
Initial BQ21061 I2C bring-up (pseudo)
----------------------------------------------------------------------

Symbolic register names — use actual TI register map.

Pseudo-code:

// helper
bq_write(uint8_t reg, uint8_t val);

// 1) Charge & input limits
bq_write(REG_ICHG,  ICHG_150mA);   // ~150 mA (~0.5C for 300 mAh)
bq_write(REG_ILIM,  ILIM_500mA);   // USB input limit ~500 mA

// 2) LDO / LS modes (we use external TPS7A02 for main 3V3)
bq_write(REG_LDOCTL, LDO_CFG_DEFAULT);

// 3) TS config (NTC vs disabled)
bq_write(REG_TSCTL,  TS_CFG_NTC_EN);   // or TS_CFG_DISABLED for dev

// 4) Ship / wake behaviour
bq_write(REG_SHIP,   SHIP_CFG_DEFAULT);

----------------------------------------------------------------------
Thermal sanity — linear stages
----------------------------------------------------------------------

Charger dissipation:

P ≈ (V_USB − V_BAT) × I_CHG

Example:

- 5.0 V -> 4.2 V @ 100 mA  ≈ 0.08 W
- 5.0 V -> 4.2 V @ 300 mA  ≈ 0.24 W

TPS7A02-3.3:

P ≈ (V_PMID − 3.3 V) × I_load

Use copper under QFN/DFN devices and short thermal spokes to GND plane. Keep high-di/dt loops tight.

======================================================================
MCU_RF.SchDoc — STM32WB55 + RF
======================================================================

Power & ground strategy

Goal: map all MCU rails cleanly to +3V3_SYS with correct decoupling and a solid GND plane.

Rail map

- Digital rails:
  VDDx (e.g. VDD20, VDD35, VDD48) -> +3V3_SYS
  0.1 µF per pin + one 4.7–10 µF bulk nearby.

- RF rail:
  VDDRF -> +3V3_SYS
  0.1 µF close to RF block.

- SMPS input:
  VDDMPS -> +3V3_SYS
  4.7 µF + 0.1 µF local.

- SMPS loop (if used):
  SMPSLX / SMPSLXL / SMPSFB -> external L(s) + 4.7 µF as per ST app note.
  Keep this loop very small and over solid GND.

- Analog rails:
  VDDA, VREF+ -> +3V3_SYS (or +3V3_ANA via bead).
  0.1 µF + 1 µF to VSSA.

- USB rail:
  VDDUSB -> +3V3_SYS, 0.1 µF local.

Ground strategy

- L2 = solid GND plane under MCU and RF.
- Use via-in-pad on exposed pad (EPAD) and RF-related grounds.
- VSSA is a local analog node:
  Tie to main GND plane with a short, direct connection.
  Return VDDA / VREF+ decouplers to VSSA.

Power_Charge_USB ⇄ MCU_RF net mapping

From Power_Charge_USB   ->   In MCU_RF                 -> Notes
+3V3_SYS                 ->   VDDx, VDDRF, VDDMPS,
                               VDDUSB, VDDA             Main 3V3 rail.
GND                      ->   VSS, VSSRF, VSSSMPS,
                               VSSA, EPAD              Single GND plane.
BQ_INT                   ->   MCU EXTI                  Charger status.
CE_MCU                   ->   MCU GPIO                  Charger enable.
3V3_SENS                 ->   Sensor ref (docs only)    For reference.

USB FS & RF

USB FS nets:

- USB_FS_P, USB_FS_N to MCU.
- Series ~22 Ω resistors near MCU.
- Keep differential pair length-matched and referenced to GND plane (L2).

RF path:

- RF1 -> π-match (C-L-C) -> filter -> antenna feed.
- 50 Ω CPWG trace on L1 with GND plane on L2.
- Via fence along RF trace at ~1.5–2 mm pitch.
- π-match footprints 0402, all DNP initially.

SWD & local debug

- SWDIO, SWCLK, NRESET, SWO, plus +3V3_SYS and GND to TC2030 (see TC2030 section).
- Optional local UART / GPIO pads if desired.

======================================================================
Sensor_IO_Buttons_LED.SchDoc — Sensors + User I/O
======================================================================

Purpose

Gather IMU, environmental / skin temperature sensors, user button and LED on one sheet.

Power domain

3V3_SENS (switched) for sensors; LED can sit on 3V3_SENS or +3V3_SYS depending on noise / power trade-offs.

Rails & local decoupling

- Sheet rails: 3V3_SENS, +3V3_SYS, GND.
- BMI270 (IMU): 0.1 µF + 1 µF at VDD/VDDIO.
- SHTC3 (Temp/RH): 0.1 µF at VDD.
- TMP117 (Skin/board temp): 0.1 µF at V+.
- Add 1 µF bulk at entry of 3V3_SENS into sensor cluster.

I2C bus topology — sensor bus

- Nets: I2C3_SENS_SCL, I2C3_SENS_SDA.
- Pull-ups: R17, R18 = 4.7 kΩ -> 3V3_SENS.
- Optional series damping: R22 ~33–100 Ω in series near MCU (DNP initial).
- Test access:
  3V3_SENS at TP12, SENS_EN at TP14.

Start bus at 100 kHz; move to 400 kHz once stable.

Sensors & addresses

- BMI270 (IMU):
  I2C address set by SDO/CSB (0x68 / 0x69 typical).
  Interrupts: BMI270_INT1, BMI270_INT2 -> MCU EXTI (e.g. PA0/PA1).

- SHTC3 (Temp/RH):
  Fixed address 0x70.

- TMP117 (skin / board temperature):
  Default address 0x48.
  TMP117_ALERT -> MCU GPIO (optional).

Placement

- Put environmental / skin sensors away from RF tip and charger hot zone.
- Place TMP117 where temperature reading represents skin or board as intended.

User I/O

Button SW1 (BTN1)

- BTN1 -> MCU GPIO (e.g. PB1).
- Path:
  Pad -> TVS (PESD5V0S1UL) -> series R24 (~100 Ω) -> MCU pin.
  Plus RC (R21/C29 etc.) for debounce and defined idle state.
- Behaviour: active-low (press pulls input to GND).

Status LED (LED1, LED_STAT_N)

- LED_STAT_N -> MCU GPIO (e.g. PB0).
- Recommended active-low configuration:
  3V3_SENS (or +3V3_SYS) -> LED -> R20 (≈1 kΩ) -> LED_STAT_N.
- MCU drives low to turn LED on (~2–3 mA).

Sensor rail 3V3_SENS

- Generated in Power_Charge_USB:
  +3V3_SYS -> FB2 -> TPS22910A -> 3V3_SENS.
- On Sensor sheet:
  All sensor VDD pins to 3V3_SENS.
  SENS_EN exported and labelled; TP optional.

Use cases

- Turn off sensors for EMC tests.
- Low-power modes with sensors fully powered-down.

Sheet-level bring-up

1) SENS_EN = Low:
   3V3_SENS = 0 V; I2C scan on I2C3_SENS finds no devices.

2) SENS_EN = High:
   3V3_SENS ≈ 3.3 V at TP12; I2C scan sees BMI270, SHTC3, TMP117.

3) Button:
   Verify EXTI on falling edge; confirm debounce.

4) LED:
   Blink via LED_STAT_N; verify polarity and current.

5) TMP117:
   Read at ~1 Hz; compare with ambient / board temperature; derive correction factors if needed.

======================================================================
Testpoints_Assembly.SchDoc
======================================================================

If you keep a dedicated test / assembly sheet:

Voltage test pads

- TP_USB_5V   (USB_VBUS)
- TP_VBATT_RAW
- TP_VBAT_PROT
- TP_PMID
- TP_+3V3_SYS
- TP_3V3_SENS

Digital / control pads

- TP_SWDIO, TP_SWCLK, TP_NRESET (if not only via TC2030)
- TP_SENS_EN, TP_BQ_INT
- Optional: TP_BTN1, TP_I2C_CHG_SCL, TP_I2C_CHG_SDA

Assembly notes

- Mark antenna keepout (no copper, no components).
- Mark TC2030-NL as "debug connector, DNP in production" if desired.
- Mark RF π-match parts and some beads as DNP by default.

======================================================================
TC2030 (SWD) hook table — STM32WB55
======================================================================

Cable: TC2030-CTX (Cortex/SWD)  
Pad layout (top view): 1-2-3 (top row), 4-5-6 (bottom row)

Pad  Signal  Net        STM32WB55 Pin   Required  Notes
---  ------  ---------  -------------   --------  -----------------------------------------
1    VTref   +3V3_SYS   —               Yes       Sense only; debugger does not power board
2    SWDIO   SWDIO      PA13            Yes       Keep short; no series R
3    GND     GND        —               Yes       Stitch via to L2 next to pad
4    SWCLK   SWCLK      PA14            Yes       Short, single via if possible
5    nRESET  NRESET     NRST            Yes       10 kΩ -> 3V3 + 100 nF -> GND near pin
6    SWO     SWO        PB3             Optional  For SWV trace if routed

Boot helper

- BOOT0:
  100 kΩ pulldown to GND.
  Test pad or small pad to pull high for ROM bootloader if ever needed.

Layout tips (AD25)

- Use TC2030-NL footprint (no legs):
  Three NPTH locator holes, pads with no paste.
- Place near board edge, away from antenna keepout.
- Keep SWD lines away from crystal islands and RF feed.

======================================================================
EMC & layout rules (wearable)
======================================================================

Stack-up (4-layer, 0.8 mm)

- L1: Components + signals + RF CPWG.
- L2: Solid GND plane.
- L3: Power pours (+3V3_SYS, 3V3_SENS, VBAT_PROT) + low-speed signals.
- L4: Signals, battery connections, logos / ID.

Grounding

- One continuous GND plane (no hard splits).
- Stitch vias around board edge, RF trace, and near ESD devices.

High-di/dt loops

- USB input: USB_VBUS -> TVS/PPTC -> BQ21061 IN -> BQ21061 GND.
- Battery: VBAT_PROT -> BQ BAT -> GND.
- LDO: PMID -> TPS7A02 -> +3V3_SYS -> GND.
- Sensor: +3V3_SYS -> FB2 -> TPS22910A -> 3V3_SENS -> GND.

Decoupling

- 100 nF caps as close as possible to supply pins with very short GND returns.
- Bulk caps just behind the small caps but still tight loops.
- For critical ICs, via-in-pad or very short traces to GND plane.

ESD / surge

- TVS diodes at all external interfaces (USB, button, RF, battery).
- Provide dedicated GND vias right next to TVS returns into L2.

RF

- Respect antenna keepout (no copper, vias, or components).
- CPWG sized for 50 Ω based on stack-up.
- π-match components DNP until tuned.

Clocks

- Keep HSE / LSE island compact with local GND moat / guard traces if needed.
- Avoid routing noisy signals under crystal region.

I2C

- Route SCL/SDA as a loosely coupled pair over solid GND.
- Place pull-ups near electrical centre of bus (sensor cluster).

LED / indicators

- Keep LED currents ≈ 2 mA to minimise EMI and power.

Test pads

- Do not place test pads inside RF keepout or too close to antenna GND edges.

======================================================================
Values cheat-sheet (start points)
======================================================================

- USB CC:
  5.1 kΩ -> GND on CC1 / CC2.

- PPTC:
  Bourns MF-PSMF050X-2, 0805, I_hold = 0.5 A.

- USB CMC:
  ACM2012D-900-2P-T00 on D+/D-.

- USB D+/D- series:
  22 Ω near MCU.

- BQ21061 caps (typical, check DS):
  IN   : 1 µF
  PMID : 22 µF
  BAT  : 10 µF
  VDD  : 2.2 µF
  VINLS / LSLDO : 1–2.2 µF

- TPS7A02:
  1 µF IN, 1 µF OUT (or datasheet recommendation).

- TPS22910A:
  1 µF bulk + 0.1 µF on 3V3_SENS entry, plus 0.1 µF at each sensor.

- I2C pull-ups:
  Charger bus: 4.7–10 kΩ -> +3V3_SYS.
  Sensor bus : 4.7 kΩ -> 3V3_SENS.

- I2C series (optional):
  33–100 Ω near MCU if edges too sharp.

- Button series:
  100 Ω; RC sized for desired debounce.

- LED series:
  1 kΩ (≈2–3 mA at 3.3 V).

- RF π-match:
  0402 C-L-C, all DNP initially; populate per antenna tuning.

- HSE/LSE load caps:
  ~10–12 pF each, tuned to crystal CL.

- TMP117:
  VDD 3.0–3.6 V, 0.1 µF at V+, I2C address 0x48.

======================================================================
Battery selection & connector (wearable)
======================================================================

Goal

Thin single-cell Li-Po pack with connector and NTC support, suitable for wearable.

Battery

- Type: Li-Po pouch, 3.7 V nominal, 4.2 V charge.
- Capacity: about 150–300 mAh.
- Thickness: target ≤ 4 mm.
- Protection: prefer packs with integrated PCM (over/under-voltage, over-current).

Runtime estimate

runtime_hours ≈ 0.8 × capacity_mAh / avg_current_mA

Connector

- J1: BM03B-GHS-TBT (3-pin JST-GH header)
  Pins: VBATT_RAW, GND, BAT_NTC_10K.
- Mating housing: GHR-03V-S with matching crimp contacts.

Tie-in

- VBATT_RAW:
  Through PFET Q101 to VBAT_PROT.
  VBAT_PROT then to BQ21061 BAT pin.

- BAT_NTC_10K:
  To BQ21061 TS input via 10 k NTC network per datasheet.

Mechanical

- Twist VBATT_RAW / GND leads.
- Use foam + tape or printed plastic features for strain relief.
- Keep battery metal away from antenna keepout.

======================================================================
Bring-up checklist (board-level)
======================================================================

Visual & continuity

- Check battery and USB polarity (silk + footprint).
- Check no short between USB_VBUS and GND, VBATT_RAW and GND.

Power path

- Battery only:
  VBAT_PROT ≈ VBATT_RAW − PFET drop.
  PMID ≈ battery voltage.
  +3V3_SYS present and stable at test pad.

- USB only:
  USB_VBUS ≈ 5 V.
  VIN_BQ, PMID, +3V3_SYS all as per design.

Charger I2C

- BQ21061 responds on I2C_CHG_SCL / I2C_CHG_SDA.
- Status bits change appropriately with:
  USB plug/unplug.
  Battery connect/disconnect.

Sensor rail

- SENS_EN low  -> 3V3_SENS off; no sensors found on I2C3_SENS.
- SENS_EN high -> 3V3_SENS ≈ 3.3 V; BMI270, SHTC3, TMP117 enumerate.

MCU & SWD

- ST-LINK connects via TC2030.
- NRESET and BOOT0 behaviour verified.
- Basic LED blink via LED_STAT_N.

USB FS

- If firmware supports it, USB FS enumerates when connected.
- D+/D- show no abnormal ringing with CMC + ESD in line.

RF smoke test

- BLE advertising visible in scanner / RF tool.
- No obvious detuning from battery or enclosure placement.

EMC hooks

- All key rails available at test pads for conducted / radiated testing.
- DNP π-match and beads ready for population during RF/EMC evaluation.
