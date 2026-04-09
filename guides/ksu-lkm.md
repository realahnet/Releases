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

### Step 1: Download KSU Patcher
- Download it from: [here](https://github.com/akuatech/KSUPatcher/releases/latest)
- Laucn the app

### Step 2: Change the Kernel Module Interface (KMI) version
> **⚠️ NOTE: THIS STEP IS VERY IMPORTANT! WITHOUT IT, THE DEVICE MAY NOT BOOT!!**

- Set it to `android14-6.1`

### Step 3: Download the Relevant kernelsu/kernelsu_next.ko Module from Releases
- They are provided with the ROM Release in github: [here](https://github.com/Releases/releases/)

### Step 4: Download the Relevant init_boot.img for Your Build Varaint
- Availible at the download link provided inside the `GMS/images` or `Vanilla/images` folder (depending on the variant you use).

### Step 5: In the App, Choose the Relevant KSU version
- For KernelSU-Next, tap KernelSU-Next
- For KernelSU, tap KernelSU
- Tap on the `Patch` under the Method

### Step 6: Select the init_boot.img You Downloaded in Step 4
- Under Action, inside the "Select boot.img"

### Step 7: Select the kernelsu.ko/kernelsu_next.ko Module File
- Under Action, inside the "Kernel Module"
- Start Patching

### Step 8: After the Patching is Done, a File Will Be Created in Downloads
- Usually named `kernelsu_patched_2026xxx_xxxx.img` or `kernelsu_next_patched_2026xxx_xxxx.img`, depending on what module you patched with.

### Step 9: Copy this File to Your Computer, and Flash it
- Using fastbootd

- For Example:
```sh
fastboot flash init_boot kernelsu_next_patched_2026xxx_xxxx.img
```
---

Congratulations! Enjoy KernelSU

## Persisting Root on OTA
- Give Root Permissions to the KSU Patcher app via KernelSU manager
- Go to the OTA tab.
- Select the correct variant for KernelSU
- Select the kernelsu.ko / kernelsu_next.ko file under Actions, inside "Kernel Module" *(Important, or it will flash with another ksu.ko)*
- Tap Flash OTA
