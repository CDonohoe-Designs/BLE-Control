# BLE-Control Schematic Design Review — Applied Checklist

**Project:** BLE-Control Wearable  
**Review Type:** Schematic Design Review  
**Review Basis:** Uploaded schematic PDF + individual Altium `.SchDoc` files + `.PcbDoc` file  
**Reviewer:** Caoilte Donohoe / ChatGPT support review  
**Date:** 2026-05-27  
**Status:** First-pass engineering review. Final sign-off still requires Altium compile/ERC, BOM, library, footprint and manufacturer checks.

---

# 1. Documentation & Architecture

- [x] Reviewed  [ ] N/A — Schematic hierarchy is logical and easy to navigate  
  **Result:** Pass. The design is split into clear functional sheets: power/USB/charger, MCU/RF, and sensors/I/O.

- [x] Reviewed  [ ] N/A — Functional blocks are clearly separated  
  **Result:** Pass. Power, USB, charger, BLE RF, MCU, sensors, button and LED blocks are clearly grouped.

- [x] Reviewed  [ ] N/A — Design intent notes are included where appropriate  
  **Result:** Pass. Useful notes are included for BLE RF, USB protection, charger behaviour, BOOT0, SWD and sensor rail control.

- [x] Reviewed  [ ] N/A — Sheet titles and references are consistent  
  **Result:** Minor issue. Overall title structure is good, but the sensor sheet title/file text appears to contain a typo: `SchDDocrawn By`.  
  **Action:** Clean up title block text before release.

- [x] Reviewed  [ ] N/A — Interfaces between sheets are clearly defined  
  **Result:** Pass. Cross-sheet signal labels are present for USB, I²C, sensor enable, interrupts, button and LED.

- [x] Reviewed  [ ] N/A — External interfaces are documented  
  **Result:** Pass. USB-C, battery connector, SWD and RF antenna sections are identifiable.

---

# 2. Power Architecture

- [x] Reviewed  [ ] N/A — Power architecture is clearly defined  
  **Result:** Pass. Main rails and sensor rail are understandable.

- [x] Reviewed  [ ] N/A — All supply rails have identified sources  
  **Result:** Pass. USB/VIN charging path, battery path, main 3V3 and gated sensor 3V3 are shown.

- [x] Reviewed  [ ] N/A — Voltage levels are appropriate for all devices  
  **Result:** Pass with verification. 3V3 system rail appears appropriate for MCU and sensors.  
  **Action:** Confirm low-battery behaviour of the 3V3 LDO, as a single Li-ion cell may fall close to or below regulation headroom.

- [x] Reviewed  [ ] N/A — No missing power connections  
  **Result:** Preliminary pass. Power pins are shown on visible symbols.  
  **Action:** Confirm by Altium compile/ERC.

- [x] Reviewed  [ ] N/A — Input protection strategy reviewed  
  **Result:** Pass. USB input includes PPTC, TVS/ESD and filtering.

- [x] Reviewed  [ ] N/A — Regulator enable behaviour reviewed  
  **Result:** Pass. LDO enable is tied to input and documented as always-on.

- [x] Reviewed  [ ] N/A — Startup behaviour reviewed  
  **Result:** Pass with verification. BOOT0, reset and sensor enable defaults are documented.  
  **Action:** Confirm reset timing and firmware default states during bring-up.

---

# 3. Battery & Charging

- [x] Reviewed  [ ] N/A — Battery charging architecture reviewed  
  **Result:** Pass. Stand-alone Li-ion charger architecture is clear.

- [x] Reviewed  [ ] N/A — Charge current is appropriate  
  **Result:** Pass with verification. Charge current is documented as approximately 100 mA.  
  **Action:** Confirm this matches intended battery capacity and charge-time expectations.

- [x] Reviewed  [ ] N/A — Battery connector reviewed  
  **Result:** Pass. Battery connector and protected battery node are shown.

- [x] Reviewed  [ ] N/A — NTC / temperature monitoring reviewed  
  **Result:** Pass with verification. Battery NTC connection is shown.  
  **Action:** Confirm NTC divider/charger thermistor thresholds against battery pack datasheet.

- [x] Reviewed  [ ] N/A — Charger status signals reviewed  
  **Result:** Pass. PG/STAT signals are exposed and pulled up for debug.

- [x] Reviewed  [ ] N/A — Battery and charger test points included  
  **Result:** Pass. Charger status and power path test points are included.

---

# 4. MCU Review

- [x] Reviewed  [ ] N/A — MCU power pins connected correctly  
  **Result:** Preliminary pass. Multiple VDD domains, RF supply and USB supply are shown.  
  **Action:** Confirm against STM32WB55 reference design and ERC.

- [x] Reviewed  [ ] N/A — Decoupling strategy implemented  
  **Result:** Pass. Local 100 nF and bulk decoupling capacitors are included.

- [x] Reviewed  [ ] N/A — Reset circuit reviewed  
  **Result:** Pass. Pull-up and reset capacitor are shown.

- [x] Reviewed  [ ] N/A — Boot configuration reviewed  
  **Result:** Pass. BOOT0 is pulled down and documented.

- [x] Reviewed  [ ] N/A — Clock circuits reviewed  
  **Result:** Pass with issue. HSE and LSE circuits are shown.  
  **Action:** Fix apparent capacitor value text typo: `10Fp` should likely be `10pF`. Confirm all crystal load capacitors against the crystal datasheet and STM32WB reference design.

- [x] Reviewed  [ ] N/A — Debug/programming interface included  
  **Result:** Pass. SWD/Tag-Connect service port is included.

- [x] Reviewed  [ ] N/A — Unused pins strategy considered  
  **Result:** Pass. Note states unused GPIO configured as analog/no-pull in firmware.

---

# 5. USB Interface

- [x] Reviewed  [ ] N/A — USB-C configuration reviewed  
  **Result:** Pass for USB 2.0 device/sink style implementation.

- [x] Reviewed  [ ] N/A — CC pin configuration reviewed  
  **Result:** Pass. CC pull-down resistors are included.

- [x] Reviewed  [ ] N/A — USB ESD protection included  
  **Result:** Pass. USB data and CC ESD protection are included.

- [x] Reviewed  [ ] N/A — USB filtering reviewed  
  **Result:** Pass with verification. Common-mode choke is included.  
  **Action:** Confirm selected CMC is suitable for USB full-speed signalling and does not degrade eye margin.

- [x] Reviewed  [ ] N/A — VBUS protection reviewed  
  **Result:** Pass. VBUS includes fuse and TVS protection.

- [x] Reviewed  [ ] N/A — USB data path reviewed  
  **Result:** Pass with verification. Series resistors are included at MCU side.  
  **Action:** Confirm USB-C D+/D− A/B side connection symmetry and differential routing in PCB.

---

# 6. RF / BLE Review

- [x] Reviewed  [ ] N/A — RF signal path clearly defined  
  **Result:** Pass. STM32WB RF pin routes through matching/filtering to chip antenna.

- [x] Reviewed  [ ] N/A — Antenna selection reviewed  
  **Result:** Pass with verification. Chip antenna is included.  
  **Action:** Confirm board thickness, ground clearance and antenna keepout match antenna datasheet.

- [x] Reviewed  [ ] N/A — RF matching network included  
  **Result:** Pass. Matching/filter components are included.

- [x] Reviewed  [ ] N/A — RF ESD protection included  
  **Result:** Pass with verification. RF ESD footprint is included.  
  **Action:** Confirm RF ESD capacitance is low enough for 2.4 GHz operation and locate close to antenna/RF entry as intended.

- [x] Reviewed  [ ] N/A — Controlled impedance requirement documented  
  **Result:** Pass. RF path is labelled as 50 ohm / CPWG intent.

- [x] Reviewed  [ ] N/A — Antenna keepout requirement documented  
  **Result:** Pass with verification. RF notes exist.  
  **Action:** Confirm keepout in the PCB file against antenna datasheet.

- [x] Reviewed  [ ] N/A — RF grounding strategy considered  
  **Result:** Pass. Via fence / CPWG strategy is documented.

- [x] Reviewed  [ ] N/A — EMC / radiated emissions strategy considered  
  **Result:** Pass. RF and IEC 60601-1-2 intent notes are included.

---

# 7. Sensors & Interfaces

- [x] Reviewed  [ ] N/A — I²C bus architecture reviewed  
  **Result:** Pass. I²C bus connects MCU, temperature sensor and IMU.

- [x] Reviewed  [ ] N/A — Pull-up strategy reviewed  
  **Result:** Pass. Pull-ups are connected to gated sensor rail.

- [x] Reviewed  [ ] N/A — Address conflicts checked  
  **Result:** Needs verification. Address pins are visible, but full address review requires datasheets.  
  **Action:** Confirm TMP117 and BMI270 I²C addresses do not conflict.

- [x] Reviewed  [ ] N/A — Sensor power requirements reviewed  
  **Result:** Pass. Sensors are powered from gated 3V3 sensor rail.

- [x] Reviewed  [ ] N/A — Sensor enable strategy reviewed  
  **Result:** Pass. Sensor rail is controlled through load switch.

- [x] Reviewed  [ ] N/A — Interrupt handling reviewed  
  **Result:** Pass with verification. Interrupt lines are shown.  
  **Action:** Confirm required pull-ups/pull-downs and firmware configuration.

---

# 8. User Interface

- [x] Reviewed  [ ] N/A — Button default states defined  
  **Result:** Pass. Pull network and default state are documented.

- [x] Reviewed  [ ] N/A — Button debounce strategy reviewed  
  **Result:** Pass. RC filtering is included.

- [x] Reviewed  [ ] N/A — Button ESD protection included  
  **Result:** Pass. TVS/ESD diode is included.

- [x] Reviewed  [ ] N/A — LED current limiting reviewed  
  **Result:** Pass. LED resistor is included.

- [x] Reviewed  [ ] N/A — LED drive method reviewed  
  **Result:** Pass. LED is MCU-controlled.

- [x] Reviewed  [ ] N/A — LED default state reviewed  
  **Result:** Pass with verification.  
  **Action:** Confirm firmware default GPIO state prevents unwanted LED current during reset.

---

# 9. EMC / ESD Review

- [x] Reviewed  [ ] N/A — External interfaces protected  
  **Result:** Pass. USB, button and RF interfaces include protection.

- [x] Reviewed  [ ] N/A — Human-accessible interfaces protected  
  **Result:** Pass. USB and button include ESD protection.

- [x] Reviewed  [ ] N/A — RF interface protected  
  **Result:** Pass with verification. RF ESD is included.

- [x] Reviewed  [ ] N/A — USB interface protected  
  **Result:** Pass. USB ESD/TVS/fuse/CMC are present.

- [x] Reviewed  [ ] N/A — Filtering strategy reviewed  
  **Result:** Pass. USB filtering, ferrite beads and RF filtering are included.

- [x] Reviewed  [ ] N/A — Noise-sensitive circuits identified  
  **Result:** Pass. RF, crystal and sensor sections are identifiable.  
  **Action:** Confirm layout keeps RF/crystal loops short and away from noisy USB/power paths.

---

# 10. Grounding Strategy

- [x] Reviewed  [ ] N/A — Grounding philosophy documented  
  **Result:** Pass. Notes refer to RF grounding, CPWG and via fence.

- [x] Reviewed  [ ] N/A — Digital return paths considered  
  **Result:** Needs PCB review.  
  **Action:** Confirm solid L2 ground plane and no routing across return path gaps.

- [x] Reviewed  [ ] N/A — RF grounding considered  
  **Result:** Pass with PCB verification required.  
  **Action:** Confirm RF via fence, antenna keepout and matching network grounding in layout.

- [x] Reviewed  [ ] N/A — Shielding requirements identified  
  **Result:** N/A for this simple BLE-Control prototype unless enclosure/system shielding is later required.

- [x] Reviewed  [ ] N/A — No obvious unintended ground issues identified  
  **Result:** Preliminary pass.  
  **Action:** Confirm with compiled project/net connectivity.

---

# 11. Testability

- [x] Reviewed  [ ] N/A — Power rail test points available  
  **Result:** Pass. Main rails and charger nodes have test points.

- [x] Reviewed  [ ] N/A — Ground test points available  
  **Result:** Pass. Ground test point is included.

- [x] Reviewed  [ ] N/A — Debug access available  
  **Result:** Pass. SWD connector is included.

- [x] Reviewed  [ ] N/A — Key signals accessible  
  **Result:** Pass. Charger status, boot, sensor enable and rails are accessible.

- [x] Reviewed  [ ] N/A — Programming method defined  
  **Result:** Pass. SWD/Tag-Connect is documented as service port.

- [x] Reviewed  [ ] N/A — Manufacturing test access considered  
  **Result:** Pass for prototype.  
  **Action:** For production, define fixture access, programming flow and minimum functional test.

---

# 12. Reliability & Robustness

- [x] Reviewed  [ ] N/A — Safe startup behaviour reviewed  
  **Result:** Pass. BOOT0, reset and sensor enable behaviour are documented.

- [x] Reviewed  [ ] N/A — Safe shutdown behaviour reviewed  
  **Result:** Needs verification.  
  **Action:** Confirm firmware handles low battery and charger connection behaviour.

- [x] Reviewed  [ ] N/A — Brownout conditions considered  
  **Result:** Needs verification.  
  **Action:** Confirm STM32 brownout/reset configuration and low-battery behaviour.

- [x] Reviewed  [ ] N/A — Fault behaviour reviewed  
  **Result:** Pass at schematic level. Sensor rail can be disabled.

- [x] Reviewed  [ ] N/A — Recovery behaviour reviewed  
  **Result:** Pass with verification. SWD and BOOT0 recovery path are available.

---

# 13. Manufacturing Readiness

- [x] Reviewed  [ ] N/A — Components available from suitable suppliers  
  **Result:** Needs BOM check.  
  **Action:** Review lifecycle, lead time and alternates.

- [x] Reviewed  [ ] N/A — Lifecycle risk reviewed  
  **Result:** Needs BOM check.  
  **Action:** Add lifecycle and AVL review before release.

- [x] Reviewed  [ ] N/A — Footprints verified  
  **Result:** Needs Altium footprint/library check.  
  **Action:** Verify all footprints against datasheets, especially USB-C, antenna, STM32 package, charger, load switch and connectors.

- [x] Reviewed  [ ] N/A — Assembly risks identified  
  **Result:** Needs PCB/DFM review.  
  **Action:** Check small passives, USB-C solderability, antenna clearance and connector accessibility.

- [x] Reviewed  [ ] N/A — Special manufacturing requirements identified  
  **Result:** Partial. RF antenna/matching and USB-C assembly need specific DFM attention.

---

# 14. Key Review Findings

## Major Issues

- [x] None found from first-pass schematic/PDF review.
- [ ] Issue: _______________________________________

## Minor Issues / Fix Before Release

- [x] Fix apparent title block typo on sensor sheet.
- [x] Check apparent capacitor value text typo: `10Fp` should likely be `10pF`.
- [x] Confirm USB-C D+/D− A/B side connectivity and routing symmetry.
- [x] Confirm RF antenna keepout, ground clearance and antenna reference layout.
- [x] Confirm crystal load capacitors against crystal and STM32WB55 requirements.
- [x] Confirm LDO dropout/headroom at low battery voltage.
- [x] Run Altium compile/ERC and resolve all relevant warnings/errors.
- [x] Verify all footprints against component datasheets.
- [x] Generate BOM/lifecycle/AVL review.

## Recommendations

- [x] Add a short `Review Notes` section to the repository explaining that this is an EVT non-medical wearable prototype.
- [x] Export ERC report from Altium and store it with this checklist.
- [x] Export schematic PDF and PCB screenshots after each release tag.
- [x] Add a small production/bring-up checklist covering first power-up, SWD programming, BLE test, USB test, charger test and sensor I²C scan.

---

# Final Sign-Off

| Reviewer | Role | Status | Date |
|---|---|---|---|
| Caoilte Donohoe | Design Owner | [ ] Approved [x] Conditional [ ] Reject | 2026-05-27 |
| Reviewer 2 | Peer Reviewer | [ ] Approved [ ] Conditional [ ] Reject | __________ |

**Conditional Approval Note:**  
Schematic is suitable for prototype/EVT progression, subject to Altium compile/ERC, footprint verification, RF antenna layout check, USB-C connectivity check, and BOM/lifecycle review.
