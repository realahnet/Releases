# Getting Widevine L1 on Oneplus Ace 5 / 13R on AOSP ROM's
**THIS GUIDE DOES NOT WORK FOR OnePlus 12. It may work for OnePlus 13 and higher**

This was initially shipped rom side but after discovering that it does not fall back to L3 when users have not reprogrammed their TEE, it had to be dropped to ensure a fair out of box experience for everyone.

## Requirements
- Rooted via KernelSU or any other root solution which allows you to flash modules
- The OnePlus device (Duh)
- bomb?

## Steps 

### Step 1: Download the L1 module
- Download it from: [here](https://github.com/realahnet/Releases/blob/main/files/modules/OP-12-13R-Ace5-Widevine-L1.zip)

### Step 2: Flash the Module in your root manager

### Step 3: Reboot
---

Congratulations! Enjoy Widevine L1. the module will automatically reprogram your TEE.

Note: if you still want to do the reprogramming manually: [here](https://xdaforums.com/t/fix-widevine-l1-unlocked-bootloader.4731374/)

NOTE: on Ace 5 or other chinese devices not in Netflix's DB, you'll have to spoof it to any model supporting HDR or your global counterpart. e.g. for Ace 5 it'd be OnePlus 13R
