# BLE-Control Wearable: Schematic Review Checklist

Project: **BLE-Control Wearable**  
Classification: **Non-medical wearable / engineering prototype**  
Review Stage: **Schematic Freeze before PCB Layout**  
Tool: **Altium Designer AD25**  
Reviewer:  
Date:  
Revision:  A0 (EVT)

---

## Scope

BLE-Control is a **non-medical BLE wearable learning project**.

It demonstrates a small embedded wearable design using:

- STM32WB55 BLE microcontroller
- USB-C input and Li-Po charging
- 3.3 V system rail and switched sensor rail
- TMP117 temperature sensor
- BMI270 IMU
- Button and status LED
- SWD programming/debug
- BLE antenna / RF matching
- DFM, DFT and bring-up planning

This design is **not a medical device**, does **not claim clinical accuracy**, and is **not intended for diagnosis, treatment, therapy, or patient monitoring**.

IEC 60601 / IEC 61000 references, if used, are for **design-awareness only**: low-voltage safety thinking, ESD, EMC robustness, and documentation discipline. No compliance or certification claim is made.

---

## Review Decision

- [ ] Approved for PCB layout
- [ ] Approved with minor actions
- [ ] Rework required

---

# 1. Documentation & Architecture

- [x] Reviewed  [ ] N/A — Schematic hierarchy is logical and easy to navigate
- [x] Reviewed  [ ] N/A — Functional blocks are clearly separated
- [x] Reviewed  [ ] N/A — Design intent notes are included where appropriate
- [x] Reviewed  [ ] N/A — Sheet titles and references are consistent
- [x] Reviewed  [ ] N/A — Interfaces between sheets are clearly defined
- [x] Reviewed  [ ] N/A — External interfaces are documented

---

# 2. Power Architecture

- [x] Reviewed  [ ] N/A — Power architecture is clearly defined
- [x] Reviewed  [ ] N/A — All supply rails have identified sources
- [x] Reviewed  [ ] N/A — Voltage levels are appropriate for all devices
- [x] Reviewed  [ ] N/A — No missing power connections
- [x] Reviewed  [ ] N/A — Input protection strategy reviewed
- [x] Reviewed  [ ] N/A — Regulator enable behaviour reviewed
- [x] Reviewed  [ ] N/A — Startup behaviour reviewed

---

# 3. Battery & Charging

- [x] Reviewed  [ ] N/A — Battery charging architecture reviewed
- [x] Reviewed  [ ] N/A — Charge current is appropriate
- [x] Reviewed  [ ] N/A — Battery connector reviewed
- [x] Reviewed  [ ] N/A — NTC / temperature monitoring reviewed
- [x] Reviewed  [ ] N/A — Charger status signals reviewed
- [x] Reviewed  [ ] N/A — Battery and charger test points included

---

# 4. MCU Review

- [x] Reviewed  [ ] N/A — MCU power pins connected correctly
- [x] Reviewed  [ ] N/A — Decoupling strategy implemented
- [x] Reviewed  [ ] N/A — Reset circuit reviewed
- [x] Reviewed  [ ] N/A — Boot configuration reviewed
- [x] Reviewed  [ ] N/A — Clock circuits reviewed
- [x] Reviewed  [ ] N/A — Debug/programming interface included
- [x] Reviewed  [ ] N/A — Unused pins strategy considered

---

# 5. USB Interface

- [x] Reviewed  [ ] N/A — USB-C configuration reviewed
- [x] Reviewed  [ ] N/A — CC pin configuration reviewed
- [x] Reviewed  [ ] N/A — USB ESD protection included
- [x] Reviewed  [ ] N/A — USB filtering reviewed
- [x] Reviewed  [ ] N/A — VBUS protection reviewed
- [x] Reviewed  [ ] N/A — USB data path reviewed

---

# 6. RF / BLE Review

- [x] Reviewed  [ ] N/A — RF signal path clearly defined
- [x] Reviewed  [ ] N/A — Antenna selection reviewed
- [x] Reviewed  [ ] N/A — RF matching network included
- [x] Reviewed  [ ] N/A — RF ESD protection included
- [x] Reviewed  [ ] N/A — Controlled impedance requirement documented
- [x] Reviewed  [ ] N/A — Antenna keepout requirement documented
- [x] Reviewed  [ ] N/A — RF grounding strategy considered
- [x] Reviewed  [ ] N/A — EMC / radiated emissions strategy considered

---

# 7. Sensors & Interfaces

- [x] Reviewed  [ ] N/A — I²C bus architecture reviewed
- [x] Reviewed  [ ] N/A — Pull-up strategy reviewed
- [x] Reviewed  [ ] N/A — Address conflicts checked
- [x] Reviewed  [ ] N/A — Sensor power requirements reviewed
- [x] Reviewed  [ ] N/A — Sensor enable strategy reviewed
- [x] Reviewed  [ ] N/A — Interrupt handling reviewed

---

# 8. User Interface

- [x] Reviewed  [ ] N/A — Button default states defined
- [x] Reviewed  [ ] N/A — Button debounce strategy reviewed
- [x] Reviewed  [ ] N/A — Button ESD protection included
- [x] Reviewed  [ ] N/A — LED current limiting reviewed
- [x] Reviewed  [ ] N/A — LED drive method reviewed
- [x] Reviewed  [ ] N/A — LED default state reviewed

---

# 9. EMC / ESD Review

- [x] Reviewed  [ ] N/A — External interfaces protected
- [x] Reviewed  [ ] N/A — Human-accessible interfaces protected
- [x] Reviewed  [ ] N/A — RF interface protected
- [x] Reviewed  [ ] N/A — USB interface protected
- [x] Reviewed  [ ] N/A — Filtering strategy reviewed
- [x] Reviewed  [ ] N/A — Noise-sensitive circuits identified

---

# 10. Grounding Strategy

- [x] Reviewed  [ ] N/A — Grounding philosophy documented
- [x] Reviewed  [ ] N/A — Digital return paths considered
- [x] Reviewed  [ ] N/A — RF grounding considered
- [x] Reviewed  [ ] N/A — Shielding requirements identified
- [x] Reviewed  [ ] N/A — No obvious unintended ground issues identified

---

# 11. Testability

- [x] Reviewed  [ ] N/A — Power rail test points available
- [x] Reviewed  [ ] N/A — Ground test points available
- [x] Reviewed  [ ] N/A — Debug access available
- [x] Reviewed  [ ] N/A — Key signals accessible
- [x] Reviewed  [ ] N/A — Programming method defined
- [x] Reviewed  [ ] N/A — Manufacturing test access considered

---

# 12. Reliability & Robustness

- [x] Reviewed  [ ] N/A — Safe startup behaviour reviewed
- [x] Reviewed  [ ] N/A — Safe shutdown behaviour reviewed
- [x] Reviewed  [ ] N/A — Brownout conditions considered
- [x] Reviewed  [ ] N/A — Fault behaviour reviewed
- [x] Reviewed  [ ] N/A — Recovery behaviour reviewed

---

# 13. Manufacturing Readiness

- [x] Reviewed  [ ] N/A — Components available from suitable suppliers
- [x] Reviewed  [ ] N/A — Lifecycle risk reviewed
- [x] Reviewed  [ ] N/A — Footprints verified
- [x] Reviewed  [ ] N/A — Assembly risks identified
- [x] Reviewed  [ ] N/A — Special manufacturing requirements identified

---

# 14. Review Outcome

## Major Issues

- [ ] None recorded
- [ ] Issue: _______________________________________

## Minor Issues

- [ ] None recorded
- [ ] Issue: _______________________________________

## Recommendations

- [ ] Recommendation: ______________________________

---

# Final Sign-Off

| Reviewer | Role | Status | Date |
|---|---|---|---|
| __________ | __________ | [ ] Approved [ ] Conditional [ ] Reject | __________ |
| __________ | __________ | [ ] Approved [ ] Conditional [ ] Reject | __________ |


