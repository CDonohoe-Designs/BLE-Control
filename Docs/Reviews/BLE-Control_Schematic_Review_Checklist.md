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

- [ ] Schematic hierarchy is logical and easy to navigate
- [ ] Functional blocks are clearly separated
- [ ] Design intent notes are included where appropriate
- [ ] Sheet titles and references are consistent
- [ ] No duplicated or ambiguous functionality
- [ ] Interfaces between sheets are clearly defined
- [ ] External interfaces are documented

---

# 2. Power Architecture

## Power Tree

- [ ] Power architecture is clearly defined
- [ ] All supply rails have identified sources
- [ ] Rail sequencing requirements reviewed
- [ ] Voltage levels are appropriate for all devices
- [ ] No missing power connections

## Protection

- [ ] Reverse polarity protection reviewed
- [ ] Overcurrent protection reviewed
- [ ] ESD protection included where required
- [ ] Input protection suitable for intended environment
- [ ] Battery protection strategy reviewed

## Regulation

- [ ] Regulator selection appropriate
- [ ] Input/output capacitor requirements checked
- [ ] Enable pins configured correctly
- [ ] Startup behaviour reviewed
- [ ] Power dissipation considered

---

# 3. Battery & Charging

- [ ] Battery charging architecture reviewed
- [ ] Charger configuration verified
- [ ] Charge current appropriate
- [ ] Battery connector reviewed
- [ ] NTC / temperature monitoring reviewed
- [ ] Battery test points provided
- [ ] Charger status signals reviewed
- [ ] Fault conditions considered

---

# 4. MCU Review

## General

- [ ] MCU selection appropriate
- [ ] Supply pins connected correctly
- [ ] Decoupling strategy implemented
- [ ] Reset circuit reviewed
- [ ] Boot configuration reviewed

## Clocking

- [ ] High-speed clock reviewed
- [ ] Low-speed clock reviewed
- [ ] Crystal loading network reviewed
- [ ] Startup recommendations checked

## Debug

- [ ] Programming interface included
- [ ] Debug interface accessible
- [ ] Debug signals clearly identified
- [ ] Recovery strategy available

---

# 5. USB Interface

## USB-C

- [ ] USB-C configuration reviewed
- [ ] CC configuration reviewed
- [ ] Connector orientation handled correctly
- [ ] USB operating mode confirmed

## Protection

- [ ] USB ESD protection included
- [ ] Common mode filtering reviewed
- [ ] Surge protection reviewed
- [ ] VBUS protection reviewed

## Data Path

- [ ] Differential pair architecture reviewed
- [ ] Series termination reviewed
- [ ] Signal routing intent documented

---

# 6. RF / BLE Review

## RF Architecture

- [ ] RF signal path clearly defined
- [ ] Antenna selection reviewed
- [ ] RF matching network included
- [ ] RF design follows vendor recommendations

## RF Protection

- [ ] RF ESD protection included
- [ ] RF protection placement considered

## RF Layout Requirements

- [ ] Controlled impedance requirements documented
- [ ] RF keepout requirements documented
- [ ] Via fence requirements documented
- [ ] Grounding strategy documented
- [ ] Antenna placement requirements documented

## Regulatory

- [ ] RF compliance requirements identified
- [ ] EMC requirements identified
- [ ] Radiated emissions strategy considered
- [ ] Immunity strategy considered

---

# 7. Sensors & Interfaces

## I²C

- [ ] Bus architecture reviewed
- [ ] Pull-up strategy reviewed
- [ ] Address conflicts checked
- [ ] Bus voltage compatibility verified

## Sensors

- [ ] Sensor power requirements reviewed
- [ ] Sensor enable strategy reviewed
- [ ] Interrupt handling reviewed
- [ ] Startup conditions reviewed

---

# 8. User Interface

## Buttons

- [ ] Button default states defined
- [ ] Debounce strategy reviewed
- [ ] ESD protection included
- [ ] Fault behaviour considered

## LEDs

- [ ] LED current limiting reviewed
- [ ] LED drive method reviewed
- [ ] Default states reviewed

---

# 9. EMC / ESD Review

## EMC

- [ ] EMC strategy documented
- [ ] Noise-sensitive circuits identified
- [ ] Switching current paths considered
- [ ] Grounding philosophy documented
- [ ] Filtering strategy reviewed

## ESD

- [ ] External interfaces protected
- [ ] Human-accessible interfaces protected
- [ ] RF interface protected
- [ ] USB interface protected

---

# 10. Grounding Strategy

- [ ] Grounding philosophy documented
- [ ] Analog and digital returns reviewed
- [ ] RF grounding reviewed
- [ ] Shielding requirements identified
- [ ] Chassis/functional ground considerations reviewed
- [ ] No unintended ground loops identified

---

# 11. Testability (DFT)

## Bring-Up

- [ ] Power rail test points available
- [ ] Ground test points available
- [ ] Debug access available
- [ ] Key signals accessible

## Production

- [ ] Functional test strategy considered
- [ ] Programming method defined
- [ ] Manufacturing test access reviewed
- [ ] Critical measurements identified

---

# 12. Reliability & Robustness

- [ ] Safe startup behaviour reviewed
- [ ] Safe shutdown behaviour reviewed
- [ ] Fault conditions reviewed
- [ ] Brownout conditions reviewed
- [ ] Recovery behaviour reviewed
- [ ] Watchdog strategy considered

---

# 13. Manufacturing Readiness

- [ ] Components available from approved suppliers
- [ ] Lifecycle status reviewed
- [ ] Footprints verified
- [ ] Assembly risks identified
- [ ] Special manufacturing requirements identified

---

# 14. Review Outcome

## Major Issues

- [ ]

## Minor Issues

- [ ]

## Recommendations

- [ ]


