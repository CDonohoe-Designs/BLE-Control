
# BLE‑Control — One‑Page Connection Checklist

Keep this beside Altium while wiring. One line per logical connection. Sheet = where the connection is made.

---

## Power rails
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| USB_5V | USB‑C VBUS | BQ24074 VBUS (via polyfuse) | USB_Debug → Power | TVS to GND on USB_5V |
| VBAT | BQ24074 BAT | LDO IN, TPS22910A IN, MAX17048 VDD, Test Pad | Power_Batt_Charge_LDO | 10 µF at BAT pin |
| 3V3 | TPS7A02 OUT | MCU VDD, I²C pull‑ups, LED/button, Sensors (if not switched) | Power_Batt_Charge_LDO | 1 µF + 0.1 µF at LDO OUT |
| VDD_SENS | TPS22910A OUT | BMI270 VDD (opt), SHTC3 VDD, expansion header | Power_Batt_Charge_LDO | 1–4.7 µF bulk + 0.1 µF |
| GND | — | All GND pins/planes | All | L2 solid plane |

## Charger & battery
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| VBAT | J_BATT + | System VBAT net | Power_Batt_Charge_LDO | Mark polarity |
| GND | J_BATT − | System GND | Power_Batt_Charge_LDO |  |
| TS | NTC (10 k) | BQ24074 TS | Power_Batt_Charge_LDO | Or disable per DS |
| ICHG | R_ICHG | BQ24074 ICHG | Power_Batt_Charge_LDO | Set ≈ 0.5 C |
| ILIM | R_ILIM | BQ24074 ILIM | Power_Batt_Charge_LDO | Per datasheet |

## Regulators & switch
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| 3V3 | TPS7A02 OUT | MCU VDD pins | Power_Batt_Charge_LDO → MCU_RF | 0.1 µF at each VDD |
| SENS_EN | MCU PA8 | TPS22910A EN | MCU_RF → Power | Active high |

## I²C bus
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| I2C_SCL | MCU PB8 | BMI270 SCL, SHTC3 SCL, MAX17048 SCL | MCU_RF → Sensors | 4.7 kΩ pull‑up to 3V3 |
| I2C_SDA | MCU PB9 | BMI270 SDA, SHTC3 SDA, MAX17048 SDA | MCU_RF → Sensors | 4.7 kΩ pull‑up to 3V3 |

## Sensor interrupts
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| BMI270_INT1 | BMI270 INT1 | MCU PA0 | Sensors → MCU_RF | EXTI |
| BMI270_INT2 | BMI270 INT2 | MCU PA1 | Sensors → MCU_RF | EXTI |
| GAUGE_INT (opt) | MAX17048 ALRT | MCU PB2 | Sensors → MCU_RF | Optional |
| SHTC3_INT (opt) | SHTC3 INT | MCU (free EXTI) | Sensors → MCU_RF | Optional |

## USB & ESD
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| CC1 | USB‑C CC1 | 5.1 kΩ → GND | USB_Debug | Sink‑only |
| CC2 | USB‑C CC2 | 5.1 kΩ → GND | USB_Debug | Sink‑only |
| USB_DM | USB‑C D− | MCU PA11 (opt) | USB_Debug → MCU_RF | If DFU/CDC used |
| USB_DP | USB‑C D+ | MCU PA12 (opt) | USB_Debug → MCU_RF | If DFU/CDC used |
| VBUS_TVS | USB_5V | TVS → GND | USB_Debug | Protection |

## SWD (Tag‑Connect TC2030‑NL footprint)
| Pin | Signal | Net | MCU | Sheet | Notes |
|---|---|---|---|---|---|
| 1 | VTref | 3V3 | — | USB_Debug | Probe power sense |
| 2 | SWDIO | SWDIO | PA13 | MCU_RF |  |
| 3 | nRESET | NRST | NRST | MCU_RF | 10 k↑, 100 nF→GND |
| 4 | SWCLK | SWCLK | PA14 | MCU_RF |  |
| 5 | GND | GND | — | USB_Debug |  |
| 6 | SWO (opt) | SWO | PB3 | MCU_RF | Optional |

## Clocks
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| HSE_IN/OUT | 32 MHz XTAL | MCU pins | MCU_RF | 2× ~12 pF to GND + series 0 Ω |
| LSE_IN/OUT | 32.768 kHz XTAL | MCU pins | MCU_RF | 2× ~12 pF to GND |

## RF path
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| RF_OUT | MCU RF pin | π‑match C‑L‑C (DNP) | MCU_RF | 50 Ω CPWG |
| ANT_IN | π‑match | Chip antenna feed | MCU_RF | Edge, keepout, via fence |

## Indicators & IO
| Net | From | To | Sheet | Notes |
|---|---|---|---|---|
| BTN_IN | Button → GND | MCU PB1 | IO_Buttons_LEDs → MCU_RF | Use PU/PD/RC as chosen |
| GPIO_LED | MCU PB0 | LED → 1 kΩ → GND | MCU_RF → IO_Buttons_LEDs | ~1–2 mA |

## Test pads
| Pad | Net | Sheet |
|---|---|---|
| TP_VBAT | VBAT | Power_Batt_Charge_LDO |
| TP_3V3 | 3V3 | Power_Batt_Charge_LDO |
| TP_VDD_SENS | VDD_SENS | Power_Batt_Charge_LDO |
| TP_USB_5V | USB_5V | USB_Debug |
| TP_SWDIO | SWDIO | MCU_RF |
| TP_SWCLK | SWCLK | MCU_RF |
| TP_GND | GND | Any |
