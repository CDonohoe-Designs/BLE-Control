# BLE-Control Wearable — Schematic Review Checklist

Project: **BLE-Control Wearable**  
Repository: `CDonohoe-Designs/BLE-Control`  
Review Stage: **Schematic Freeze / Pre-PCB Layout**  
Design Tool: **Altium Designer AD25**  
Reviewer:  
Date:  
Revision:  

---

## Scope

BLE-Control is a **generic BLE wearable sensor/control demonstrator** using:

- STM32WB55 BLE microcontroller
- MCP73833 single-cell Li-Po charger
- TPS7A02 3.3 V regulator
- TPS22910A switched sensor rail
- TMP117 temperature sensor
- BMI270 IMU
- USB-C power/charging input
- SWD/Tag-Connect service/debug access
- BLE RF antenna and matching network

This project is used as a **learning and portfolio template** for medical-style product engineering: schematic review, risk thinking, EMC-aware design, DFM/DFT, verification planning, and controlled design release.

This project is **not a certified medical device** and does **not claim clinical performance**.

---

## Medical / Regulatory Framing

Working assumption for this repository:

- BLE-Control is a **generic wearable prototype**.
- It is **not an implant controller**.
- It does **not deliver therapy**.
- It does **not directly influence implantable device operation**.
- It does **not make diagnostic or treatment decisions**.
- It is treated as a **medical-device-style learning template**, not as a released medical product.

If a future version is given a medical intended purpose, classification must be reassessed. For interview / learning purposes only, if it were used for non-critical physiological monitoring, treat it with a **Class IIa-style design-control mindset**. If it monitors vital physiological parameters where immediate patient danger could result, classification and risk controls would need to be reassessed.

---

## Review Decision

- [ ] Approved for PCB layout
- [ ] Approved with actions
- [ ] Rework required

Known issues / actions:

- [ ] 
- [ ] 
- [ ] 

---

# 1. Intended Use / Design Scope

- [ ] Intended use is written clearly as a generic wearable.
- [ ] Device is not described as an implant controller.
- [ ] Device is not described as delivering therapy.
- [ ] Device is not described as making clinical decisions.
- [ ] Device is not claimed as certified or clinically validated.
- [ ] User/operator is defined.
- [ ] Patient/user contact assumptions are defined.
- [ ] Device is described as external / wearable.
- [ ] Sensors are defined: TMP117 temperature and BMI270 motion/IMU.
- [ ] BLE function is defined as communication/control only.
- [ ] Medical-device framing is described as a learning/prototype exercise.
- [ ] No safety-critical decision relies on this prototype without validation.
- [ ] Essential performance is defined only if a medical intended purpose is later claimed.

---

# 2. Design Inputs / Requirements

- [ ] Main functional blocks are listed.
- [ ] Power source is defined: USB-C charging and single-cell Li-Po battery.
- [ ] Battery voltage range is defined.
- [ ] Charge current target is defined.
- [ ] `+3V3_SYS` rail requirement is defined.
- [ ] `3V3_SENS` switched rail requirement is defined.
- [ ] BLE function is defined.
- [ ] RF antenna requirement is defined.
- [ ] TMP117 function is defined.
- [ ] BMI270 function is defined.
- [ ] Button and LED function are defined.
- [ ] SWD/service access requirement is defined.
- [ ] Test-point requirement is defined.
- [ ] EMC expectation is defined.
- [ ] Manufacturing and assembly assumptions are defined.
- [ ] Environmental assumptions are defined.
- [ ] User-accessible interfaces are identified.
- [ ] Service-only interfaces are identified.

---

# 3. Medical-Style Risk Management Checks

- [ ] A simple hazard/risk log exists or is planned.
- [ ] Battery overcharge hazard is considered.
- [ ] Battery reverse-polarity hazard is considered.
- [ ] USB overvoltage/surge hazard is considered.
- [ ] ESD hazard is considered.
- [ ] Charger thermal hazard is considered.
- [ ] Regulator dropout/brownout hazard is considered.
- [ ] MCU lock-up hazard is considered.
- [ ] BLE loss-of-link behaviour is considered.
- [ ] Unauthorized BLE access risk is considered.
- [ ] Incorrect sensor reading risk is considered.
- [ ] Button false-trigger risk is considered.
- [ ] EMC immunity failure risk is considered.
- [ ] RF coexistence/interference risk is considered.
- [ ] Firmware safe-state behaviour is considered.
- [ ] Debug/service port misuse is considered.
- [ ] Each major risk has at least one design control or verification action.
- [ ] Residual risks are listed for later review.

---

# 4. Basic Safety / Low-Voltage Electrical Checks

- [ ] All electrical rails are low voltage / SELV-level.
- [ ] No mains voltage exists on the PCB.
- [ ] USB-C input is treated as a SELV power input.
- [ ] Battery pack protection is assumed or specified.
- [ ] Charger safety depends on charger IC plus protected battery pack.
- [ ] No direct patient-applied electrical connection is claimed.
- [ ] User-accessible metal or conductive parts are identified.
- [ ] Creepage/clearance is adequate for low-voltage circuits.
- [ ] Service/debug port is not user-accessible during normal use.
- [ ] Single-fault conditions are considered at schematic level.
- [ ] Reverse battery condition is considered.
- [ ] Shorted output rail condition is considered.
- [ ] Failed charger status output is considered.
- [ ] Stuck sensor rail enable is considered.
- [ ] MCU reset/default states are safe.

---

# 5. EMC / Immunity / ESD Checks

- [ ] USB-C VBUS has TVS protection.
- [ ] USB-C VBUS has PPTC/fuse protection.
- [ ] USB data lines have ESD protection if used.
- [ ] USB CC pins have correct termination and protection strategy.
- [ ] Button input has ESD/RC/series protection.
- [ ] SWD/service connector is documented as service-only.
- [ ] RF section has antenna keepout note.
- [ ] RF section has 50 ohm CPWG note.
- [ ] RF section has solid ground / via fence note.
- [ ] BLE intentional radiator risk is documented.
- [ ] Sensor rail can be disabled during fault or EMC testing.
- [ ] `SENS_EN` default-low behaviour is implemented.
- [ ] External/user-accessible traces have ESD considered.
- [ ] Ground return paths are considered.
- [ ] Decoupling strategy is documented.
- [ ] EMC-sensitive nets are identified.
- [ ] Fast digital nets are identified.
- [ ] RF, USB, crystal and reset nets are treated as sensitive.

---

# 6. Documentation / Drawing Checks

- [ ] All sheet titles are correct.
- [ ] All sheet numbers are correct.
- [ ] Revision is correct.
- [ ] Author/date fields are correct.
- [ ] Old BQ21061 references are removed.
- [ ] MCP73833 architecture is documented.
- [ ] TMP117 and BMI270 are the only fitted sensors.
- [ ] Optional/removed sensors are removed or clearly DNP/variant marked.
- [ ] Design notes match the current schematic.
- [ ] Medical notes do not overclaim clinical use.
- [ ] Service/debug note is present.
- [ ] RF intentional radiator note is present.
- [ ] USB-C SELV/protection note is present.
- [ ] Battery safety note is present.
- [ ] All components have designators.
- [ ] All components have values/comments.
- [ ] All components have footprints assigned.

---

# 7. Net Naming / Connectivity

- [ ] Power rails use Power Ports.
- [ ] Signal connections between sheets use Ports / Off-Sheet Connectors.
- [ ] No duplicate net-name warnings remain.
- [ ] No off-grid ports remain.
- [ ] No mixed naming exists on the same wire.
- [ ] `+3V3_SYS` is named consistently.
- [ ] `3V3_SENS` is named consistently.
- [ ] `VIN_CHG` is named consistently.
- [ ] `VIN_CHG_F` is named consistently if used.
- [ ] `VBAT_PROT` is named consistently.
- [ ] `VBATT_RAW` is named consistently.
- [ ] `GND` is named consistently.
- [ ] `I2C_SENS_SCL` is named consistently.
- [ ] `I2C_SENS_SDA` is named consistently.
- [ ] No mixed `I2C3_SENS_*` / `I2C_SENS_*` naming remains.
- [ ] No old charger I2C nets remain.
- [ ] No old `CE_MCU` net remains.
- [ ] No old `BQ_INT` net remains.
- [ ] No old `PMID` net remains unless clearly marked obsolete.

---

# 8. Power Architecture

- [ ] USB-C VBUS enters through protection before charger input.
- [ ] `USB_VBUS` remains separate from `VIN_CHG`.
- [ ] `VIN_CHG` feeds MCP73833 VDD.
- [ ] MCP73833 VBAT feeds `VBAT_PROT`.
- [ ] Battery connector positive connects to `VBATT_RAW`.
- [ ] Reverse-protection PFET connects `VBATT_RAW` to `VBAT_PROT`.
- [ ] PFET orientation allows battery discharge into the system.
- [ ] PFET orientation allows charge current into the battery.
- [ ] `VBAT_PROT` feeds TPS7A02 input.
- [ ] TPS7A02 output creates `+3V3_SYS`.
- [ ] TPS7A02 EN is tied to input.
- [ ] TPS7A02 is not controlled by MCU GPIO.
- [ ] `3V3_SENS` is generated from `+3V3_SYS`.
- [ ] No unintended short exists between `VIN_CHG`, `VBAT_PROT`, and `+3V3_SYS`.
- [ ] Power test points exist for `VIN_CHG`, `VBAT_PROT`, `+3V3_SYS`, `3V3_SENS`, and GND.

---

# 9. USB-C / Protection

- [ ] USB-C connector pinout is checked.
- [ ] CC1 has 5.1 kΩ Rd to GND.
- [ ] CC2 has 5.1 kΩ Rd to GND.
- [ ] VBUS TVS is fitted close to the USB input path.
- [ ] PPTC/fuse is in series with VBUS.
- [ ] Ferrite bead is included or DNP as intended.
- [ ] USB ESD protection is fitted.
- [ ] USB data nets are named consistently.
- [ ] USB D+/D- routing path is clear.
- [ ] USB differential pair passes through intended CMC/filtering if fitted.
- [ ] USB shield/mounting pins are treated correctly.
- [ ] USB-C area has a compliance/protection note.

---

# 10. MCP73833 Charger Block

- [ ] MCP73833 part number is `MCP73833T-FCI/UN`.
- [ ] Footprint is MSOP-10.
- [ ] Pins 1 and 2 VDD connect to `VIN_CHG`.
- [ ] Pins 9 and 10 VBAT connect to `VBAT_PROT`.
- [ ] Pin 5 VSS connects to GND.
- [ ] Pin 6 PROG connects to 10 kΩ resistor to GND.
- [ ] Charge current note is present: `RPROG = 10 kΩ -> I_CHG approx. 100 mA`.
- [ ] Input capacitor is close to MCP73833 VDD.
- [ ] Battery/output capacitor is close to MCP73833 VBAT.
- [ ] THERM connects to `BAT_NTC_10K`.
- [ ] Optional 10 kΩ dummy THERM resistor is included or considered for bring-up.
- [ ] STAT1 routes to `CHG_STAT1` test point.
- [ ] STAT2 routes to `CHG_STAT2` test point.
- [ ] PG routes to `CHG_PG` test point.
- [ ] STAT1/STAT2/PG have pull-ups.
- [ ] Pull-ups are to `VIN_CHG` only if test-point-only.
- [ ] Note states charger status nets must not connect directly to MCU if pulled up to `VIN_CHG`.
- [ ] No I2C, CE, ship-mode, or power-path functions are implied for MCP73833.
- [ ] Schematic note explains this is a simplified stand-alone charger design.

---

# 11. TPS7A02 3V3 Regulator

- [ ] Input is `VBAT_PROT`.
- [ ] Output is `+3V3_SYS`.
- [ ] EN is tied to input.
- [ ] Input capacitor is close to regulator.
- [ ] Output capacitor is close to regulator.
- [ ] 100 nF local output capacitor is included if required.
- [ ] Test point exists on `+3V3_SYS`.
- [ ] Always-on 3V3 policy is documented.
- [ ] Low-battery/dropout behaviour is considered.
- [ ] System behaviour at low battery is documented for firmware bring-up.

---

# 12. STM32WB55 MCU

- [ ] All VDD pins connect to `+3V3_SYS`.
- [ ] VDDRF connects to `+3V3_SYS`.
- [ ] VDDSMPS connects as intended.
- [ ] VDDUSB connects as intended.
- [ ] VDDA/VREF treatment is checked.
- [ ] VBAT pin is not connected directly to LiPo voltage.
- [ ] Each power pin has local decoupling.
- [ ] Bulk capacitance exists near MCU.
- [ ] NRST has pull-up and reset capacitor if intended.
- [ ] BOOT0 has 100 kΩ pulldown.
- [ ] BOOT0 test option is present if required.
- [ ] Unused MCU pins are documented.
- [ ] Firmware note states unused pins are configured analog/no-pull.
- [ ] MCU sheet has no old charger-control nets.
- [ ] MCU reset/default state is safe.
- [ ] MCU cannot unintentionally enable sensor rail at reset.

---

# 13. SWD / Debug / Service Port

- [ ] TC2030 / SWD connector is present.
- [ ] VTREF connects to `+3V3_SYS`.
- [ ] SWDIO connects to correct MCU pin.
- [ ] SWCLK connects to correct MCU pin.
- [ ] NRST connects to connector.
- [ ] SWO is connected or intentionally NC.
- [ ] GND is connected.
- [ ] SWD connector note says service/debug only.
- [ ] SWD connector is not user-accessible during normal use.
- [ ] Debug access does not power the board unintentionally.
- [ ] Debug interface is considered in service/cybersecurity notes.

---

# 14. Sensor Power Gate

- [ ] TPS22910A input is `+3V3_SYS`.
- [ ] TPS22910A output is `3V3_SENS`.
- [ ] `SENS_EN` controls TPS22910A ON pin.
- [ ] `SENS_EN` has pulldown to GND.
- [ ] Default reset state keeps sensors OFF.
- [ ] Input capacitor is fitted near TPS22910A.
- [ ] Output capacitor is fitted near TPS22910A.
- [ ] `3V3_SENS` test point is present.
- [ ] `SENS_EN` test point is present.
- [ ] Sensor rail note explains gated sensor domain.
- [ ] Sensor rail can be disabled for fault/EMC testing.

---

# 15. I2C Sensor Bus

- [ ] MCU PB6/PB7 or chosen pins are assigned correctly.
- [ ] MCU-side nets before series resistors are clearly named.
- [ ] 22 Ω series resistors are fitted near MCU side.
- [ ] Sheet-level I2C ports are `I2C_SENS_SCL` and `I2C_SENS_SDA`.
- [ ] I2C ports are set to Bidirectional.
- [ ] Pull-ups are on the sensor page.
- [ ] Pull-ups connect to `3V3_SENS`.
- [ ] Pull-ups do not connect to `+3V3_SYS`.
- [ ] TMP117 connects to `I2C_SENS_SCL` and `I2C_SENS_SDA`.
- [ ] BMI270 connects to `I2C_SENS_SCL` and `I2C_SENS_SDA`.
- [ ] No duplicate I2C labels exist on the same wire.
- [ ] Bus scan addresses are documented.
- [ ] I2C failure state is considered.
- [ ] I2C lines are not pulled high when `3V3_SENS` is disabled.

---

# 16. TMP117 Temperature Sensor

- [ ] TMP117 V+ connects to `3V3_SENS`.
- [ ] TMP117 GND connects to GND.
- [ ] TMP117 SCL connects to `I2C_SENS_SCL`.
- [ ] TMP117 SDA connects to `I2C_SENS_SDA`.
- [ ] ADD0 strap is correct for intended address.
- [ ] ALERT connects to `TMP117_ALERT` or is intentionally NC.
- [ ] ALERT pull-up exists if used.
- [ ] Decoupling capacitor is close to TMP117.
- [ ] EPAD treatment follows datasheet/library recommendation.
- [ ] Placement note considers charger/regulator heat.
- [ ] Temperature reading is not claimed as clinically accurate without validation.

---

# 17. BMI270 IMU

- [ ] BMI270 VDD connects to `3V3_SENS`.
- [ ] BMI270 VDDIO connects to `3V3_SENS`.
- [ ] BMI270 GND/GNDIO connect to GND.
- [ ] BMI270 SCX/SCL connects to `I2C_SENS_SCL`.
- [ ] BMI270 SDX/SDA connects to `I2C_SENS_SDA`.
- [ ] CSB is strapped correctly for I2C mode.
- [ ] SDO is strapped for intended I2C address.
- [ ] INT1 connects to `BMI270_INT1`.
- [ ] INT2 connects to `BMI270_INT2`.
- [ ] Interrupt pull-ups/pulldowns are defined if required.
- [ ] Decoupling capacitors are close to BMI270.
- [ ] IMU placement avoids board flex/high mechanical stress.
- [ ] Motion data is not used for safety decisions without validation.

---

# 18. Button / LED

- [ ] Button input net is `BTN1`.
- [ ] Button has defined default state.
- [ ] Button pull-up uses `+3V3_SYS`.
- [ ] Button does not depend on `3V3_SENS`.
- [ ] Button has series resistor.
- [ ] Button has RC debounce/filter if intended.
- [ ] Button has ESD protection if exposed/user accessible.
- [ ] Button false-trigger risk is considered.
- [ ] LED net is `LED_STAT_N`.
- [ ] LED current-limit resistor is fitted.
- [ ] LED rail choice is intentional.
- [ ] System LED uses `+3V3_SYS` unless deliberately tied to sensor rail.
- [ ] Active-low / active-high LED behaviour is documented.
- [ ] LED meaning is documented for bring-up.

---

# 19. RF / BLE Section

- [ ] STM32WB RF pin connects to RF matching path.
- [ ] RF path has pi-match / tuning component footprints.
- [ ] RF matching parts are DNP/tuneable as required.
- [ ] RF filter footprint is correct.
- [ ] Antenna part number is correct.
- [ ] RF ESD footprint is included.
- [ ] Antenna keepout note is present.
- [ ] 50 ohm CPWG requirement is documented.
- [ ] Solid L2 GND under RF path is documented.
- [ ] Via fence requirement is documented.
- [ ] RF coexistence risk is considered.
- [ ] BLE loss-of-link behaviour is considered.
- [ ] BLE data/control is not used for clinical decisions without validation.

---

# 20. Usability / Human Factors

- [ ] User controls are identified.
- [ ] Button behaviour is documented.
- [ ] LED meaning is documented.
- [ ] Ambiguous LED states are avoided.
- [ ] Service-only connector is not confused with user interface.
- [ ] Normal use vs service use is documented.
- [ ] Misuse cases are listed.
- [ ] Charging use error is considered.
- [ ] Battery connector orientation error is considered.
- [ ] BLE pairing/control use error is considered.

---

# 21. Cybersecurity / Wireless Control

- [ ] BLE function is identified.
- [ ] BLE pairing/bonding requirement is documented.
- [ ] Unauthorized command risk is identified.
- [ ] Loss-of-link behaviour is defined.
- [ ] Reconnection behaviour is defined.
- [ ] Firmware update/debug access risk is considered.
- [ ] Sensitive service/debug interfaces are not exposed in normal use.
- [ ] Wireless coexistence risk is considered.
- [ ] Sensor readings are not used for clinical decisions without validation.

---

# 22. Test Points / DFT

- [ ] `VIN_CHG` test point present.
- [ ] `VBAT_PROT` test point present.
- [ ] `+3V3_SYS` test point present.
- [ ] `3V3_SENS` test point present.
- [ ] GND test point present.
- [ ] `CHG_STAT1` test point present.
- [ ] `CHG_STAT2` test point present.
- [ ] `CHG_PG` test point present.
- [ ] SWD programming access present.
- [ ] I2C test points considered.
- [ ] TMP117 can be verified by I2C scan.
- [ ] BMI270 can be verified by I2C scan.
- [ ] Button/LED can be tested in firmware.
- [ ] Test points are not inside antenna keepout.
- [ ] Test points are accessible after enclosure/assembly assumptions are considered.

---

# 23. Verification Planning

- [ ] Schematic requirements are linked to planned verification.
- [ ] Power rail verification planned.
- [ ] Battery charging verification planned.
- [ ] Charge current verification planned.
- [ ] USB input protection verification planned.
- [ ] SWD programming verification planned.
- [ ] BLE advertising/connection verification planned.
- [ ] I2C scan verification planned.
- [ ] TMP117 reading verification planned.
- [ ] BMI270 interrupt/data verification planned.
- [ ] Button/LED verification planned.
- [ ] Reset/boot behaviour verification planned.
- [ ] EMC pre-check plan drafted.
- [ ] Pass/fail criteria are defined for bring-up tests.

---

# 24. ERC / Compile Checks

- [ ] Project compiles with no errors.
- [ ] All remaining warnings are understood.
- [ ] No ERC markers hide real errors.
- [ ] ERC markers are only used for intentional analogue/passive nodes.
- [ ] No off-grid ports remain.
- [ ] No duplicate net names remain.
- [ ] No one-pin nets remain unless intentional.
- [ ] No floating MCU control pins remain.
- [ ] All power inputs have a valid source.
- [ ] All unused pins are documented.
- [ ] All NC pins are marked appropriately.
- [ ] ECO preview is reviewed before PCB update.

---

# 25. BOM / Library / Footprint Checks

- [ ] Every symbol has a footprint.
- [ ] MCP73833 footprint is MSOP-10.
- [ ] STM32WB55 footprint matches exact package.
- [ ] TMP117 footprint matches exact package.
- [ ] BMI270 footprint matches exact package.
- [ ] USB-C footprint matches selected connector.
- [ ] Battery connector footprint matches selected part.
- [ ] TC2030 footprint is correct.
- [ ] RF antenna footprint matches datasheet.
- [ ] All passives use intended package sizes.
- [ ] 0402/0603 choice is intentional.
- [ ] Manufacturer part numbers are added where useful.
- [ ] Critical DNP parts are clearly marked.
- [ ] Protection components are identifiable in BOM.
- [ ] Safety/protection components are not substituted without review.

---

# 26. Ready for PCB Layout Gate

- [ ] Schematic compiles cleanly.
- [ ] Schematic PDF exported.
- [ ] Checklist completed.
- [ ] Known issues listed.
- [ ] Medical-style assumptions documented.
- [ ] Risk controls documented.
- [ ] Board outline target defined.
- [ ] PCB stackup assumption defined.
- [ ] Placement strategy defined.
- [ ] Test access strategy defined.
- [ ] RF keepout strategy defined.
- [ ] Ready to delete old PCB traces and begin new placement.

---

# 27. Sign-Off

Reviewer:  
Date:  

Decision:

- [ ] Approved for PCB layout
- [ ] Approved with actions
- [ ] Rework required

Actions / Notes:

- 
- 
- 

---

## References / Frameworks Used for Learning Context

- EU MDR classification principles for active monitoring devices
- ISO 14971-style risk management thinking
- IEC 60601-1 basic safety and essential performance mindset
- IEC 60601-1-2 EMC/immunity mindset
- DFM/DFT and controlled design review practices
