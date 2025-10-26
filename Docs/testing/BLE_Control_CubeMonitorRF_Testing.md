# BLE-Control — RF & PER Testing with STM32CubeMonitor-RF

This guide shows how to test your **BLE-Control** board’s radio using **STM32CubeMonitor-RF (CubeMonRF)** with **STLINK-V3MINI VCP** over a **Tag-Connect** programming header. It covers wiring, firmware, quick tests, and PER (packet error rate).

---

## Why CubeMonitor-RF?
- Run **TX/RX/PER** RF tests and sweep **channels / TX power / packet length**.
- Send **HCI/ACI** commands (DTM/Transparent Mode) for controller-level checks.
- Scan/connect and poke your **GATT** quickly when doing functional bring-up.

---

## Hardware options (Tag-Connect)
Choose one:

**A) SWD only + tiny UART pads**
- Keep your **TC2030 (6-pin)** for SWD.
- Add a 3-pad **UART (TX, RX, GND)** test header for CubeMonRF.

**B) One-connector setup (recommended)**
- Use **TC2050 (10-pin)** footprint.
- Cable: **TC2050-IDC-050-STDC14** → plugs straight into **STLINK-V3MINI** (STDC14).
- You get **SWD + NRST + VCP UART** through one tag header.

---

## STLINK-V3MINI (STDC14) → Your Board (signals)
> Wire these to your Tag-Connect footprint nets (don’t rely on pad numbering; route by **signal name**).

| STDC14 Pin | Signal      | Connect to (MCU / Net)               | Notes                                     |
|------------|-------------|--------------------------------------|-------------------------------------------|
| 3          | T_VCC       | 3V3 (target Vref)                    | Powers the probe’s level sensing          |
| 4          | SWDIO       | SWDIO (e.g., PA13)                   | SWD                                       |
| 6          | SWCLK       | SWCLK (e.g., PA14)                   | SWD                                       |
| 12         | NRST        | NRST                                  | Target reset                              |
| 5 or 7     | GND         | GND                                   | Ground reference                          |
| 8 (opt)    | SWO         | SWO (e.g., PB3)                      | SWV trace (optional)                      |
| 13         | T_VCP_RX    | **MCU UART_RX** (ST-LINK TX → RX)    | VCP for CubeMonRF                         |
| 14         | T_VCP_TX    | **MCU UART_TX** (Target TX → ST-LINK RX) | VCP for CubeMonRF                      |

**Net name suggestions (Altium):** `SWDIO`, `SWCLK`, `NRST`, `VCP_TX` (MCU→STLINK), `VCP_RX` (STLINK→MCU), `SWO`, `GND`, `3V3`.

---

## Board design tips (Tag-Connect)
- **TC2030 (6-pin):** smallest SWD header; great for SWD-only workflows.
- **TC2050 (10-pin):** gives room for **SWD + VCP UART** (+ optional BOOT0).
- Use the **NL (no-legs)** version + retaining clip for the thinnest wearable boards.
- Keep pads free of solder-paste; respect mechanical keep-outs from the footprint datasheet.

---

## Firmware you’ll flash on STM32WB
To drive RF tests from the PC:
- Use **BLE Transparent / DTM** firmware (HCI over UART).  
  - Default UART is typically **115200 8-N-1**, no flow control (confirm in your project).
- For quick GATT checks only, a sample like **BLE_p2pServer** also works (limited RF control).

> Don’t forget the **Wireless Coprocessor** (BLE stack) must be present on the WB. Flash the current BLE HCI stack, then your application (Transparent or p2pServer).

---

## 5-minute bring-up (CubeMonRF)
1. Install **STM32CubeMonitor-RF** (Win/macOS/Linux).
2. Wire **STLINK-V3MINI** to your Tag-Connect; power the target.
3. Flash **Wireless Coprocessor (BLE HCI)** + your **Transparent/DTM** app.
4. Open CubeMonRF → **Bluetooth LE** → select the **ST-LINK VCP COM port** → **Connect**.
5. Use **RF Tests** to transmit/receive; verify counters increment.

---

## PER (Packet Error Rate) test
You need **two nodes**:
- **DUT:** your BLE-Control board (DTM/Transparent firmware).
- **Peer:** NUCLEO-WB55, WB5MMG-DK, or ST USB dongle running a matching RF test mode.

Steps:
1. Start **PER RX** on the DUT (CubeMonRF instance #1).
2. Start **PER TX** on the peer (CubeMonRF instance #2).
3. Sweep **channel**, **TX power**, **packet length**; record PER vs conditions.
4. Repeat in your **enclosure** to see detuning/attenuation impacts.

---

## Troubleshooting
- **No COM port in CubeMonRF:** Check that ST-LINK drivers are installed and VCP is enabled. Try another USB cable/port.
- **No UART traffic:** Verify TX↔RX aren’t swapped; confirm baud rate matches your firmware.
- **HCI errors:** Ensure you flashed the **matching** Wireless Coprocessor (BLE HCI variant) for your CubeWB version.
- **Stuck in reset:** Confirm **NRST** routing and target power (T_VCC must see 3V3).

---

## Nice add-ons for BLE-Control
- Add **BOOT0** to the tag header (or a pogo pad) for forced bootloader entry.
- Place a **3-pad aux UART** near the edge as a fallback console.
- Label test pads: `VCP_TX`, `VCP_RX`, `SWO`, `VBAT`, `3V3`, `GND`.

---

## Repository pointers
Suggested file location in this repo:
