# BLE-Control Schematic Design Review — Design Owner Checklist

**Project:** BLE-Control Wearable  
**Review Type:** Schematic Design Review  
**Review Basis:** BLE-Control schematic PDF, Altium schematic files, and PCB design file  
**Reviewer:** Caoilte Donohoe  
**Date:** 2026-05-27  
**Revision:**  A0 (EVT)

**Status:** Design-owner schematic review. Items marked as actions are follow-up checks before final release.

**Review Note:** This checklist records my  schematic review of the BLE-Control design. The ticked items indicate areas I reviewed against the schematic, with follow-up actions captured where further Altium, BOM, footprint, layout, or bring-up checks are required.

---

# 1. Documentation & Architecture

- [x] Reviewed  [ ] N/A — Schematic hierarchy is logical and easy to navigate  
  **My review:** Pass. The design is split into clear functional sheets: power/USB/charger, MCU/RF, and sensors/I/O.

- [x] Reviewed  [ ] N/A — Functional blocks are clearly separated  
  **My review:** Pass. Power, USB, charger, BLE RF, MCU, sensors, button and LED blocks are clearly grouped.

- [x] Reviewed  [ ] N/A — Design intent notes are included where appropriate  
  **My review:** Pass. Useful notes are included for BLE RF, USB protection, charger behaviour, BOOT0, SWD and sensor rail control.

- [x] Reviewed  [ ] N/A — Sheet titles and references are consistent  
  **My review:** Minor issue. Overall title structure is good, but the sensor sheet title/file text appears to contain a typo: `SchDDocrawn By`.  
  **My follow-up:** Clean up title block text before release.

- [x] Reviewed  [ ] N/A — Interfaces between sheets are clearly defined  
  **My review:** Pass. Cross-sheet signal labels are present for USB, I²C, sensor enable, interrupts, button and LED.

- [x] Reviewed  [ ] N/A — External interfaces are documented  
  **My review:** Pass. USB-C, battery connector, SWD and RF antenna sections are identifiable.

---

# 2. Power Architecture

- [x] Reviewed  [ ] N/A — Power architecture is clearly defined  
  **My review:** Pass. Main rails and sensor rail are understandable.

- [x] Reviewed  [ ] N/A — All supply rails have identified sources  
  **My review:** Pass. USB/VIN charging path, battery path, main 3V3 and gated sensor 3V3 are shown.

- [x] Reviewed  [ ] N/A — Voltage levels are appropriate for all devices  
  **My review:** Pass, with follow-up check. 3V3 system rail appears appropriate for MCU and sensors.  
  **My follow-up:** Check low-battery behaviour of the 3V3 LDO, as a single Li-ion cell may fall close to or below regulation headroom.

- [x] Reviewed  [ ] N/A — No missing power connections  
  **My review:** Pass, subject to compile check. Power pins are shown on visible symbols.  
  **My follow-up:** Run Altium compile/ERC and confirm.

- [x] Reviewed  [ ] N/A — Input protection strategy reviewed  
  **My review:** Pass. USB input includes PPTC, TVS/ESD and filtering.

- [x] Reviewed  [ ] N/A — Regulator enable behaviour reviewed  
  **My review:** Pass. LDO enable is tied to input and documented as always-on.

- [x] Reviewed  [ ] N/A — Startup behaviour reviewed  
  **My review:** Pass, with follow-up check. BOOT0, reset and sensor enable defaults are documented.  
  **My follow-up:** Confirm reset timing and firmware default states during bring-up.

---

# 3. Battery & Charging

- [x] Reviewed  [ ] N/A — Battery charging architecture reviewed  
  **My review:** Pass. Stand-alone Li-ion charger architecture is clear.

- [x] Reviewed  [ ] N/A — Charge current is appropriate  
  **My review:** Pass, with follow-up check. Charge current is documented as approximately 100 mA.  
  **My follow-up:** Check this matches intended battery capacity and charge-time expectations.

- [x] Reviewed  [ ] N/A — Battery connector reviewed  
  **My review:** Pass. Battery connector and protected battery node are shown.

- [x] Reviewed  [ ] N/A — NTC / temperature monitoring reviewed  
  **My review:** Pass, with follow-up check. Battery NTC connection is shown.  
  **My follow-up:** Confirm NTC divider/charger thermistor thresholds against battery pack datasheet.

- [x] Reviewed  [ ] N/A — Charger status signals reviewed  
  **My review:** Pass. PG/STAT signals are exposed and pulled up for debug.

- [x] Reviewed  [ ] N/A — Battery and charger test points included  
  **My review:** Pass. Charger status and power path test points are included.

---

# 4. MCU Review

- [x] Reviewed  [ ] N/A — MCU power pins connected correctly  
  **My review:** Pass, subject to compile check. Multiple VDD domains, RF supply and USB supply are shown.  
  **My follow-up:** Check against STM32WB55 reference design and ERC.

- [x] Reviewed  [ ] N/A — Decoupling strategy implemented  
  **My review:** Pass. Local 100 nF and bulk decoupling capacitors are included.

- [x] Reviewed  [ ] N/A — Reset circuit reviewed  
  **My review:** Pass. Pull-up and reset capacitor are shown.

- [x] Reviewed  [ ] N/A — Boot configuration reviewed  
  **My review:** Pass. BOOT0 is pulled down and documented.

- [x] Reviewed  [ ] N/A — Clock circuits reviewed  
  **My review:** Pass, minor issue noted. HSE and LSE circuits are shown.  
  **My follow-up:** Fix apparent capacitor value text typo: `10Fp` should likely be `10pF`. Check all crystal load capacitors against the crystal datasheet and STM32WB reference design.

- [x] Reviewed  [ ] N/A — Debug/programming interface included  
  **My review:** Pass. SWD/Tag-Connect service port is included.

- [x] Reviewed  [ ] N/A — Unused pins strategy considered  
  **My review:** Pass. Note states unused GPIO configured as analog/no-pull in firmware.

---

# 5. USB Interface

- [x] Reviewed  [ ] N/A — USB-C configuration reviewed  
  **My review:** Pass for USB 2.0 device/sink style implementation.

- [x] Reviewed  [ ] N/A — CC pin configuration reviewed  
  **My review:** Pass. CC pull-down resistors are included.

- [x] Reviewed  [ ] N/A — USB ESD protection included  
  **My review:** Pass. USB data and CC ESD protection are included.

- [x] Reviewed  [ ] N/A — USB filtering reviewed  
  **My review:** Pass, with follow-up check. Common-mode choke is included.  
  **My follow-up:** Check selected CMC is suitable for USB full-speed signalling and does not degrade eye margin.

- [x] Reviewed  [ ] N/A — VBUS protection reviewed  
  **My review:** Pass. VBUS includes fuse and TVS protection.

- [x] Reviewed  [ ] N/A — USB data path reviewed  
  **My review:** Pass, with follow-up check. Series resistors are included at MCU side.  
  **My follow-up:** Check USB-C D+/D− A/B side connection symmetry and differential routing in PCB.

---

# 6. RF / BLE Review

- [x] Reviewed  [ ] N/A — RF signal path clearly defined  
  **My review:** Pass. STM32WB RF pin routes through matching/filtering to chip antenna.

- [x] Reviewed  [ ] N/A — Antenna selection reviewed  
  **My review:** Pass, with follow-up check. Chip antenna is included.  
  **My follow-up:** Check board thickness, ground clearance and antenna keepout match antenna datasheet.

- [x] Reviewed  [ ] N/A — RF matching network included  
  **My review:** Pass. Matching/filter components are included.

- [x] Reviewed  [ ] N/A — RF ESD protection included  
  **My review:** Pass, with follow-up check. RF ESD footprint is included.  
  **My follow-up:** Check RF ESD capacitance is low enough for 2.4 GHz operation and locate close to antenna/RF entry as intended.

- [x] Reviewed  [ ] N/A — Controlled impedance requirement documented  
  **My review:** Pass. RF path is labelled as 50 ohm / CPWG intent.

- [x] Reviewed  [ ] N/A — Antenna keepout requirement documented  
  **My review:** Pass, with follow-up check. RF notes exist.  
  **My follow-up:** Check keepout in the PCB file against antenna datasheet.

- [x] Reviewed  [ ] N/A — RF grounding strategy considered  
  **My review:** Pass. Via fence / CPWG strategy is documented.

- [x] Reviewed  [ ] N/A — EMC / radiated emissions strategy considered  
  **My review:** Pass. RF and IEC 60601-1-2 intent notes are included.

---

# 7. Sensors & Interfaces

- [x] Reviewed  [ ] N/A — I²C bus architecture reviewed  
  **My review:** Pass. I²C bus connects MCU, temperature sensor and IMU.

- [x] Reviewed  [ ] N/A — Pull-up strategy reviewed  
  **My review:** Pass. Pull-ups are connected to gated sensor rail.

- [x] Reviewed  [ ] N/A — Address conflicts checked  
  **My review:** Reviewed, follow-up required. Address pins are visible, but full address review requires datasheets.  
  **My follow-up:** Confirm TMP117 and BMI270 I²C addresses do not conflict.

- [x] Reviewed  [ ] N/A — Sensor power requirements reviewed  
  **My review:** Pass. Sensors are powered from gated 3V3 sensor rail.

- [x] Reviewed  [ ] N/A — Sensor enable strategy reviewed  
  **My review:** Pass. Sensor rail is controlled through load switch.

- [x] Reviewed  [ ] N/A — Interrupt handling reviewed  
  **My review:** Pass, with follow-up check. Interrupt lines are shown.  
  **My follow-up:** Check required pull-ups/pull-downs and firmware configuration.

---

# 8. User Interface

- [x] Reviewed  [ ] N/A — Button default states defined  
  **My review:** Pass. Pull network and default state are documented.

- [x] Reviewed  [ ] N/A — Button debounce strategy reviewed  
  **My review:** Pass. RC filtering is included.

- [x] Reviewed  [ ] N/A — Button ESD protection included  
  **My review:** Pass. TVS/ESD diode is included.

- [x] Reviewed  [ ] N/A — LED current limiting reviewed  
  **My review:** Pass. LED resistor is included.

- [x] Reviewed  [ ] N/A — LED drive method reviewed  
  **My review:** Pass. LED is MCU-controlled.

- [x] Reviewed  [ ] N/A — LED default state reviewed  
  **My review:** Pass, with follow-up check.  
  **My follow-up:** Check firmware default GPIO state prevents unwanted LED current during reset.

---

# 9. EMC / ESD Review

- [x] Reviewed  [ ] N/A — External interfaces protected  
  **My review:** Pass. USB, button and RF interfaces include protection.

- [x] Reviewed  [ ] N/A — Human-accessible interfaces protected  
  **My review:** Pass. USB and button include ESD protection.

- [x] Reviewed  [ ] N/A — RF interface protected  
  **My review:** Pass, with follow-up check. RF ESD is included.

- [x] Reviewed  [ ] N/A — USB interface protected  
  **My review:** Pass. USB ESD/TVS/fuse/CMC are present.

- [x] Reviewed  [ ] N/A — Filtering strategy reviewed  
  **My review:** Pass. USB filtering, ferrite beads and RF filtering are included.

- [x] Reviewed  [ ] N/A — Noise-sensitive circuits identified  
  **My review:** Pass. RF, crystal and sensor sections are identifiable.  
  **My follow-up:** Check layout keeps RF/crystal loops short and away from noisy USB/power paths.

---

# 10. Grounding Strategy

- [x] Reviewed  [ ] N/A — Grounding philosophy documented  
  **My review:** Pass. Notes refer to RF grounding, CPWG and via fence.

- [x] Reviewed  [ ] N/A — Digital return paths considered  
  **My review:** Reviewed, to confirm during PCB review.  
  **My follow-up:** Confirm solid L2 ground plane and no routing across return path gaps.

- [x] Reviewed  [ ] N/A — RF grounding considered  
  **My review:** Pass with PCB verification required.  
  **My follow-up:** Check RF via fence, antenna keepout and matching network grounding in layout.

- [x] Reviewed  [ ] N/A — Shielding requirements identified  
  **My review:** Not currently required for this BLE-Control prototype unless enclosure or system shielding is added later.

- [x] Reviewed  [ ] N/A — No obvious unintended ground issues identified  
  **My review:** Pass, subject to compile check.  
  **My follow-up:** Check with compiled project/net connectivity.

---

# 11. Testability

- [x] Reviewed  [ ] N/A — Power rail test points available  
  **My review:** Pass. Main rails and charger nodes have test points.

- [x] Reviewed  [ ] N/A — Ground test points available  
  **My review:** Pass. Ground test point is included.

- [x] Reviewed  [ ] N/A — Debug access available  
  **My review:** Pass. SWD connector is included.

- [x] Reviewed  [ ] N/A — Key signals accessible  
  **My review:** Pass. Charger status, boot, sensor enable and rails are accessible.

- [x] Reviewed  [ ] N/A — Programming method defined  
  **My review:** Pass. SWD/Tag-Connect is documented as service port.

- [x] Reviewed  [ ] N/A — Manufacturing test access considered  
  **My review:** Pass for prototype.  
  **My follow-up:** For production, define fixture access, programming flow and minimum functional test.

---

# 12. Reliability & Robustness

- [x] Reviewed  [ ] N/A — Safe startup behaviour reviewed  
  **My review:** Pass. BOOT0, reset and sensor enable behaviour are documented.

- [x] Reviewed  [ ] N/A — Safe shutdown behaviour reviewed  
  **My review:** Reviewed, follow-up required.  
  **My follow-up:** Check firmware handles low battery and charger connection behaviour.

- [x] Reviewed  [ ] N/A — Brownout conditions considered  
  **My review:** Reviewed, follow-up required.  
  **My follow-up:** Check STM32 brownout/reset configuration and low-battery behaviour.

- [x] Reviewed  [ ] N/A — Fault behaviour reviewed  
  **My review:** Pass at schematic level. Sensor rail can be disabled.

- [x] Reviewed  [ ] N/A — Recovery behaviour reviewed  
  **My review:** Pass, with follow-up check. SWD and BOOT0 recovery path are available.

---

# 13. Manufacturing Readiness

- [x] Reviewed  [ ] N/A — Components available from suitable suppliers  
  **My review:** Reviewed, BOM follow-up required.  
  **My follow-up:** Review lifecycle, lead time and alternates.

- [x] Reviewed  [ ] N/A — Lifecycle risk reviewed  
  **My review:** Reviewed, BOM follow-up required.  
  **My follow-up:** Add lifecycle and AVL review before release.

- [x] Reviewed  [ ] N/A — Footprints verified  
  **My review:** Reviewed, footprint/library follow-up required.  
  **My follow-up:** Verify all footprints against datasheets, especially USB-C, antenna, STM32 package, charger, load switch and connectors.

- [x] Reviewed  [ ] N/A — Assembly risks identified  
  **My review:** Reviewed, PCB/DFM follow-up required.  
  **My follow-up:** Check small passives, USB-C solderability, antenna clearance and connector accessibility.

- [x] Reviewed  [ ] N/A — Special manufacturing requirements identified  
  **My review:** Partially reviewed. RF antenna/matching and USB-C assembly need specific DFM attention.

---

# 14. Key Review Findings

## Major Issues

- [x] No major schematic issues identified in my review.
- [ ] Issue: _______________________________________

## Minor Issues / Fix Before Release

- [x] Fix apparent title block typo on sensor sheet.
- [x] Check apparent capacitor value text typo: `10Fp` should likely be `10pF`.
- [x] Check USB-C D+/D− A/B side connectivity and routing symmetry.
- [x] Check RF antenna keepout, ground clearance and antenna reference layout.
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
I consider the schematic suitable for prototype/EVT progression, subject to Altium compile/ERC, footprint verification, RF antenna layout check, USB-C connectivity check, and BOM/lifecycle review.
