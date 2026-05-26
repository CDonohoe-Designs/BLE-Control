# BLE-Control Wearable: Schematic Review Checklist

Project: **BLE-Control Wearable**  
Classification: **Non-medical wearable / engineering prototype**  
Review Stage: **Schematic Freeze before PCB Layout**  
Tool: **Altium Designer AD25**  
Reviewer:  
Date:  
Revision:  

---

## Scope

BLE-Control is a **non-medical BLE wearable learning project**.

It is intended to demonstrate:

- STM32WB55 BLE control
- USB-C powered Li-Po charging
- 3.3 V system regulation
- Switched sensor power
- TMP117 temperature sensing
- BMI270 motion sensing
- Button / LED user I/O
- SWD programming/debug
- BLE RF layout awareness
- DFM/DFT and bring-up planning

This design is **not a medical device**, does **not claim clinical accuracy**, and is **not intended for diagnosis, treatment, therapy, or patient monitoring**.

---

## Review Decision

- [ ] Approved for PCB layout
- [ ] Approved with minor actions
- [ ] Rework required

Actions / notes:

- [ ] 
- [ ] 
- [ ] 

---

# 1. Project Documentation

- [ ] Project title is correct.
- [ ] Sheet titles are correct.
- [ ] Sheet numbers are correct.
- [ ] Revision is correct.
- [ ] Design notes match the current schematic.
- [ ] Design is clearly described as a non-medical wearable prototype.
- [ ] No medical, clinical, diagnostic, therapy, or patient-monitoring claims remain.
- [ ] Old or removed parts are not mentioned in notes.
- [ ] SHTC3 has been removed from schematic and documentation.
- [ ] Only intended sensors remain: TMP117 and BMI270.
- [ ] Schematic PDF has been exported after the latest changes.

---

# 2. Net Naming and Schematic Hygiene

- [ ] Project compiles with no errors.
- [ ] Remaining warnings are understood.
- [ ] No duplicate net names remain.
- [ ] No off-grid ports remain.
- [ ] No one-pin nets remain unless intentional.
- [ ] Power rails use Power Ports.
- [ ] Inter-sheet signals use Ports / Off-Sheet Connectors.
- [ ] `+3V3_SYS` is consistent across sheets.
- [ ] `3V3_SENS` is consistent across sheets.
- [ ] `VIN_CHG` is consistent.
- [ ] `VBAT_PROT` is consistent.
- [ ] `VBATT_RAW` is consistent.
- [ ] `I2C_SENS_SCL` is consistent.
- [ ] `I2C_SENS_SDA` is consistent.
- [ ] No mixed `I2C3_SENS_*` and `I2C_SENS_*` naming remains.
- [ ] No old BQ21061 charger I2C, `CE_MCU`, `BQ_INT`, or `PMID` nets remain.

---

# 3. Power Architecture

- [ ] USB-C VBUS enters through protection before the charger.
- [ ] `USB_VBUS` and `VIN_CHG` are clearly separated.
- [ ] MCP73833 VDD connects to `VIN_CHG`.
- [ ] MCP73833 VBAT connects to `VBAT_PROT`.
- [ ] Battery connector connects to `VBATT_RAW`.
- [ ] Reverse-protection PFET connects `VBATT_RAW` to `VBAT_PROT`.
- [ ] TPS7A02 input connects to `VBAT_PROT`.
- [ ] TPS7A02 output creates `+3V3_SYS`.
- [ ] TPS7A02 EN is tied to input for always-on 3.3 V.
- [ ] TPS7A02 is not controlled by an MCU GPIO.
- [ ] TPS22910A creates `3V3_SENS` from `+3V3_SYS`.
- [ ] No unintended short exists between `VIN_CHG`, `VBAT_PROT`, and `+3V3_SYS`.
- [ ] Test points exist for main rails: `VIN_CHG`, `VBAT_PROT`, `+3V3_SYS`, `3V3_SENS`, and GND.

---

# 4. USB-C and Input Protection

- [ ] USB-C connector pinout is checked.
- [ ] CC1 has 5.1 kΩ Rd to GND.
- [ ] CC2 has 5.1 kΩ Rd to GND.
- [ ] VBUS TVS is included.
- [ ] PPTC/fuse is included in the VBUS path.
- [ ] USB data ESD protection is included if USB data is used.
- [ ] USB D+ and D- nets are named consistently.
- [ ] USB common-mode choke/filtering is included or intentionally DNP.
- [ ] USB shield/mounting pins are handled correctly.
- [ ] USB protection parts are placed close to the connector in the intended layout.

---

# 5. MCP73833 Charger

- [ ] MCP73833 part number is correct.
- [ ] MSOP-10 footprint is assigned.
- [ ] VDD pins connect to `VIN_CHG`.
- [ ] VBAT pins connect to `VBAT_PROT`.
- [ ] VSS connects to GND.
- [ ] PROG resistor is fitted.
- [ ] Charge current note is present.
- [ ] Input capacitor is fitted.
- [ ] Battery/output capacitor is fitted.
- [ ] THERM connection is correct.
- [ ] STAT1 goes to test point only.
- [ ] STAT2 goes to test point only.
- [ ] PG goes to test point only.
- [ ] STAT1/STAT2/PG pull-ups are correct.
- [ ] Charger status pins are not connected directly to MCU if pulled up to `VIN_CHG`.
- [ ] No I2C, CE, ship-mode, or power-path behaviour is implied for MCP73833.

---

# 6. STM32WB55 MCU

- [ ] All MCU power pins connect to `+3V3_SYS`.
- [ ] MCU VBAT pin is not connected directly to Li-Po voltage.
- [ ] Each MCU power pin has local decoupling.
- [ ] Bulk capacitance is present near the MCU.
- [ ] NRST circuit is correct.
- [ ] BOOT0 has a defined default state.
- [ ] SWDIO is connected correctly.
- [ ] SWCLK is connected correctly.
- [ ] NRST is available on SWD connector.
- [ ] VTREF connects to `+3V3_SYS`.
- [ ] SWD connector is accessible for programming.
- [ ] Unused MCU pins are documented or marked intentionally unused.
- [ ] Firmware note states unused pins should be configured safely.

---

# 7. Sensor Power and I2C

- [ ] TPS22910A input is `+3V3_SYS`.
- [ ] TPS22910A output is `3V3_SENS`.
- [ ] `SENS_EN` controls the TPS22910A ON pin.
- [ ] `SENS_EN` has a pulldown to GND.
- [ ] Sensors are OFF by default during MCU reset.
- [ ] `3V3_SENS` has local capacitance.
- [ ] I2C pull-ups connect to `3V3_SENS`.
- [ ] I2C pull-ups do not connect to `+3V3_SYS`.
- [ ] `I2C_SENS_SCL` and `I2C_SENS_SDA` use bidirectional ports.
- [ ] 22 Ω series resistors are included near MCU side if used.
- [ ] TMP117 and BMI270 are on the same sensor I2C bus.
- [ ] I2C bus can be checked with a firmware I2C scan.

---

# 8. TMP117 Temperature Sensor

- [ ] TMP117 V+ connects to `3V3_SENS`.
- [ ] TMP117 GND connects to GND.
- [ ] TMP117 SCL connects to `I2C_SENS_SCL`.
- [ ] TMP117 SDA connects to `I2C_SENS_SDA`.
- [ ] ADD0 address strap is correct.
- [ ] ALERT connection is correct or intentionally unused.
- [ ] ALERT pull-up is fitted if ALERT is used.
- [ ] Decoupling capacitor is close to TMP117.
- [ ] Temperature reading is described as prototype/engineering data only, not clinical data.

---

# 9. BMI270 IMU

- [ ] BMI270 VDD connects to `3V3_SENS`.
- [ ] BMI270 VDDIO connects to `3V3_SENS`.
- [ ] BMI270 GND/GNDIO connect to GND.
- [ ] BMI270 SCL/SCX connects to `I2C_SENS_SCL`.
- [ ] BMI270 SDA/SDX connects to `I2C_SENS_SDA`.
- [ ] CSB is strapped correctly for I2C mode.
- [ ] SDO is strapped for intended I2C address.
- [ ] INT1 connects to `BMI270_INT1`.
- [ ] INT2 connects to `BMI270_INT2`.
- [ ] Interrupt pull-up/pulldown/filtering is intentional.
- [ ] Decoupling capacitors are close to BMI270.
- [ ] IMU placement note considers board flex and mechanical stress.

---

# 10. Button and LED

- [ ] Button net is `BTN1`.
- [ ] Button has a defined default state.
- [ ] Button pull-up uses `+3V3_SYS`.
- [ ] Button does not depend on `3V3_SENS`.
- [ ] Button has series resistor.
- [ ] Button has RC debounce/filter if intended.
- [ ] Button has ESD protection if user-accessible.
- [ ] LED net is `LED_STAT_N`.
- [ ] LED current-limit resistor is fitted.
- [ ] LED rail choice is intentional.
- [ ] LED active-low or active-high behaviour is documented.

---

# 11. BLE RF Section

- [ ] STM32WB RF pin connects to RF matching network.
- [ ] Pi-match / tuning footprints are present.
- [ ] RF filter footprint is correct.
- [ ] Antenna part number is correct.
- [ ] RF ESD footprint is included.
- [ ] Antenna keepout is documented.
- [ ] 50 ohm CPWG requirement is documented.
- [ ] Solid L2 GND under RF path is planned.
- [ ] RF via fence is planned.
- [ ] No signal or copper will be placed under the antenna keepout.
- [ ] RF match parts are marked DNP/tuneable if required.

---

# 12. DFT / Bring-Up Access

- [ ] GND test point exists.
- [ ] `VIN_CHG` test point exists.
- [ ] `VBAT_PROT` test point exists.
- [ ] `+3V3_SYS` test point exists.
- [ ] `3V3_SENS` test point exists.
- [ ] Charger status test points exist.
- [ ] SWD programming access exists.
- [ ] Button and LED can be tested in firmware.
- [ ] TMP117 can be verified by I2C scan.
- [ ] BMI270 can be verified by I2C scan.
- [ ] BLE advertising can be tested after programming.
- [ ] Test points are accessible and not inside the antenna keepout.

---

# 13. BOM / Library / Footprints

- [ ] Every schematic symbol has a footprint.
- [ ] STM32WB55 footprint matches exact package.
- [ ] MCP73833 footprint matches MSOP-10 package.
- [ ] TPS7A02 footprint is correct.
- [ ] TPS22910A footprint is correct.
- [ ] TMP117 footprint is correct.
- [ ] BMI270 footprint is correct.
- [ ] USB-C connector footprint is correct.
- [ ] Battery connector footprint is correct.
- [ ] SWD/Tag-Connect footprint is correct.
- [ ] Antenna footprint matches datasheet.
- [ ] Passives are sensible package sizes.
- [ ] DNP parts are clearly marked.
- [ ] Manufacturer part numbers are added where useful.

---

# 14. Ready for PCB Layout

- [ ] Schematic compiles cleanly.
- [ ] Schematic checklist is complete.
- [ ] Updated schematic PDF is exported.
- [ ] Old PCB layout is ignored or cleared for redesign.
- [ ] Board outline target is defined.
- [ ] Stackup assumption is defined.
- [ ] Placement strategy is defined.
- [ ] RF keepout strategy is defined.
- [ ] Test access strategy is defined.
- [ ] Ready to update PCB from schematic.
- [ ] Ready to begin placement review.

---

# Sign-Off

Reviewer:  
Date:  

Decision:

- [ ] Approved for PCB layout
- [ ] Approved with minor actions
- [ ] Rework required

Notes:

- 
- 
- 
