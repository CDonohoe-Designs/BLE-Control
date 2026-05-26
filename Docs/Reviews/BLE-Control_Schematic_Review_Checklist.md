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
- [ ] Design is clearly described as a non-medical wearable prototype.
- [ ] Any IEC 60601 / IEC 61000 wording is clearly marked as design-awareness only.
- [ ] No clinical, diagnostic, therapy, or patient-monitoring claims remain.
- [ ] Old or removed parts are not mentioned in notes.
- [ ] SHTC3 has been removed from schematic and documentation.
- [ ] Only intended sensors remain: TMP117 and BMI270.
- [ ] Updated schematic PDF has been exported.

---

# 2. Compile, Net Naming and Schematic Hygiene

- [ ] Project compiles with no errors.
- [ ] Remaining warnings are understood and documented.
- [ ] No duplicate net names.
- [ ] No off-grid ports.
- [ ] No unintended one-pin nets.
- [ ] Power rails use Power Ports.
- [ ] Inter-sheet signals use Ports / Off-Sheet Connectors.
- [ ] Main power nets are consistent: `VIN_CHG`, `VBAT_PROT`, `VBATT_RAW`, `+3V3_SYS`, `3V3_SENS`.
- [ ] Main signal nets are consistent: `I2C_SENS_SCL`, `I2C_SENS_SDA`, `SENS_EN`, `BTN1`, `LED_STAT_N`.
- [ ] Removed/old nets are gone or clearly marked obsolete.

---

# 3. Power, USB-C and Charger

## Design snapshot

USB-C provides low-voltage input power. The MCP73833 charges a single-cell Li-Po battery. The TPS7A02 generates the always-on `+3V3_SYS` rail. The TPS22910A generates the switched `3V3_SENS` rail.

## Checks

- [ ] USB-C connector pinout is checked.
- [ ] CC1 and CC2 have correct Rd pull-downs.
- [ ] USB-C VBUS has input protection: TVS, PPTC/fuse, and filtering as required.
- [ ] `USB_VBUS` and `VIN_CHG` are clearly separated.
- [ ] MCP73833 input connects to `VIN_CHG`.
- [ ] MCP73833 battery output connects to `VBAT_PROT`.
- [ ] MCP73833 charge-current setting is documented.
- [ ] MCP73833 THERM connection is defined.
- [ ] MCP73833 STAT/PG outputs are test/debug only unless level-shifted.
- [ ] Battery connector polarity and net naming are clear.
- [ ] Reverse-protection PFET path is checked.
- [ ] TPS7A02 input/output/enable connections are correct.
- [ ] No unintended short exists between `VIN_CHG`, `VBAT_PROT`, and `+3V3_SYS`.
- [ ] Power test points exist for bring-up.

---

# 4. MCU, Clocks and Debug

## Design snapshot

STM32WB55 provides BLE, USB FS, I2C sensor control, GPIO, debug and system control.

## Checks

- [ ] All MCU power pins connect to the correct rail.
- [ ] MCU decoupling is present on each supply domain.
- [ ] Bulk capacitance is present near the MCU.
- [ ] VBAT pin treatment is intentional and safe.
- [ ] HSE/LSE crystal circuits are checked.
- [ ] NRST circuit has defined reset behaviour.
- [ ] BOOT0 has a defined default state.
- [ ] SWDIO, SWCLK, NRST, VTREF and GND are connected to the debug connector.
- [ ] SWD/Tag-Connect is documented as service/debug only.
- [ ] Unused MCU pins are documented or handled in firmware.

---

# 5. Sensor Power and I2C Bus

## Design snapshot

Sensors are powered from a switched `3V3_SENS` rail. The sensor rail is enabled by `SENS_EN`. TMP117 and BMI270 share the `I2C_SENS_SCL` / `I2C_SENS_SDA` bus.

## Checks

- [ ] TPS22910A input is `+3V3_SYS`.
- [ ] TPS22910A output is `3V3_SENS`.
- [ ] `SENS_EN` has a defined default state.
- [ ] Sensors remain off during MCU reset unless intentionally enabled.
- [ ] `3V3_SENS` has suitable local capacitance.
- [ ] I2C pull-ups connect to `3V3_SENS`, not `+3V3_SYS`.
- [ ] I2C sheet ports are bidirectional.
- [ ] Series resistors are included near the MCU if used.
- [ ] I2C bus can be verified with a firmware scan.

---

# 6. TMP117 Temperature Sensor

## Design snapshot

TMP117 is used as an engineering temperature sensor on the switched sensor rail.

## Checks

- [ ] TMP117 V+ connects to `3V3_SENS`.
- [ ] TMP117 SCL/SDA connect to the sensor I2C bus.
- [ ] TMP117 address strap is defined.
- [ ] ALERT pin is connected or intentionally unused.
- [ ] Decoupling capacitor is present.
- [ ] Temperature data is described as prototype/engineering data only.

---

# 7. BMI270 IMU

## Design snapshot

BMI270 is used as an engineering motion/IMU sensor on the switched sensor rail.

## Checks

- [ ] BMI270 VDD and VDDIO connect to `3V3_SENS`.
- [ ] BMI270 SCL/SDA pins connect to the sensor I2C bus.
- [ ] I2C mode strap pins are defined.
- [ ] I2C address strap is defined.
- [ ] INT1 and INT2 are routed or intentionally unused.
- [ ] Decoupling capacitors are present.
- [ ] IMU placement note considers board flex and mechanical stress.

---

# 8. Button and LED

## Design snapshot

The board has one user button and one status LED for basic interaction and bring-up.

## Checks

- [ ] Button net is clearly named.
- [ ] Button has a defined default state.
- [ ] Button pull-up/pull-down is on the correct rail.
- [ ] Button has series resistance, filtering, and ESD protection if user-accessible.
- [ ] LED net is clearly named.
- [ ] LED current-limit resistor is fitted.
- [ ] LED polarity and active state are documented.
- [ ] Button and LED can be tested in firmware.

---

# 9. BLE RF Section

## Design snapshot

STM32WB55 RF output feeds an RF matching/filter/ESD path and 2.4 GHz BLE antenna.

## Checks

- [ ] RF pin connects to the matching network.
- [ ] Pi-match / tuning footprints are present.
- [ ] RF filter footprint is correct.
- [ ] RF ESD footprint is included.
- [ ] Antenna part number and footprint are correct.
- [ ] Antenna keepout is documented.
- [ ] 50 ohm CPWG requirement is documented.
- [ ] Solid L2 GND under RF path is planned.
- [ ] RF via stitching / via fence is planned.
- [ ] RF match parts are marked DNP/tuneable if required.
- [ ] No copper or signals will be placed under the antenna keepout.

---

# 10. DFT / Bring-Up Access

- [ ] GND test point exists.
- [ ] `VIN_CHG` test point exists.
- [ ] `VBAT_PROT` test point exists.
- [ ] `+3V3_SYS` test point exists.
- [ ] `3V3_SENS` test point exists.
- [ ] Charger status test points exist.
- [ ] SWD programming access exists.
- [ ] I2C bus can be probed or verified in firmware.
- [ ] Button and LED can be tested in firmware.
- [ ] BLE advertising can be tested after programming.
- [ ] Test points are accessible and outside antenna keepout.

---

# 11. BOM, Libraries and Footprints

- [ ] Every schematic symbol has a footprint.
- [ ] Main IC footprints match exact packages.
- [ ] USB-C connector footprint matches the selected part.
- [ ] Battery connector footprint matches the selected part.
- [ ] SWD/Tag-Connect footprint is correct.
- [ ] Antenna footprint matches datasheet.
- [ ] Passive package sizes are practical for assembly.
- [ ] DNP/tuning parts are clearly marked.
- [ ] Manufacturer part numbers are added where useful.
- [ ] No downloaded/staging library files are accidentally included in the release.

---

# 12. Ready for PCB Layout

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
