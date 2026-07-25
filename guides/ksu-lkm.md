# Rooting with KernelSU / KernelSU-Next for OnePlus SM8650 Devices
Our kernel on YAAP is not complaint with ABI, hence we need to compile a module against our kernel manually. To help the users, we ship these compiled modules with our releases. They just have to patch their boot image with it. This guide shows you how to do so.

## Requirements
- Platform tools installed with drivers
- USB Cable
- Computer
- The OnePlus device (Duh)
- brian
- bomb?

## Steps 

### Step 1: Download John Galt's fork of KSU Patcher
- Download it from: [here](https://github.com/RealJohnGalt/ksupatcher/releases)
- Laucn the app

### Optional: Download the Relevant init_boot.img for Your Build Varaint (If you do not want to copy the rom zip to the device)
- Availible at the download link provided inside the `GMS/images` or `Vanilla/images` folder (depending on the variant you use).

### Step 2: Select the init_boot.img You Downloaded or the ROM Zip file
- Under Action, inside the "Select boot.img or rom.zip (full OTA)"

### Step 3: Hit "Start Patching"

### Step 4: After the Patching is Done, a File Will Be Created in Downloads
- Named `kernelsu_next_patched_2026xxx_xxxx.img`

### Step 5: Copy this File to Your Computer, and Flash it
- Using fastbootd

- For Example:
```sh
fastboot flash init_boot kernelsu_next_patched_2026xxx_xxxx.img
```
---

Congratulations! Enjoy KernelSU

## Persisting Root on OTA
- **Do not reboot** after it asks you to reboot after OTA is flashed.
- Give Root Permissions to the KSU Patcher app via KernelSU manager
- Go to the OTA tab.
- Tap Flash OTA then reboot
