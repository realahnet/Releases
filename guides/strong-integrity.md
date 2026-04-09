# Passing Strong Integrity On Custom Roms
Custom roms have various methods to spoof stuff to play services which allow us to pass device integrity out of the box. Unfortunately this interferes with [TrickyStore](https://github.com/5ec1cff/TrickyStore) and we do not pass strong. _(VERY SIMPLIFIED EXPLANATION)_

## Requirements
- Root (KSU/APATCH/MAGISK)
- Working keybox (unrevoked)
- Rom supporting props to disable pihooks or PixelPropUtils overlay (AOSPA/YAAP supports it)
- brian
- bomb?

## ‼️ ON LATEST YAAP BUILDS, JUST GO TO DEVELOPER SETTINGS AND USE THE LOAD KEYBOX OPTION INSTEAD OF USING ROOT MODULES!!!! THIS IS A BETTER APPROACH.

## For AOSPA or Others
- Be on the latest Rom build released.
- Flash The latest [TrickyStore](https://github.com/5ec1cff/TrickyStore) Module in your root manager.
- Flash The latest [Play Integrity Fix](https://github.com/chiteroman/PlayIntegrityFix) Module in your root manager.
- Remember to put your working keybox at /data/adb/tricky_store. (No need to modify target.txt for broken tee. Latest version auto detects)
- Set the following props

```sh
setprop persist.sys.pihooks.disable.gms_props true
```
```sh
setprop persist.sys.pihooks.disable.gms_key_attestation_block true
```
### For YAAP 16
- Disable the option "Spoof certified properties" from Settings > System > Miscellaneous.

### For YAAP 15+
- To disable YAAP's fingerprint spoofing logic, You can download **[this overlay](https://raw.githubusercontent.com/ahnet-69/Releases/refs/heads/main/files/NoPropsOverlay.apk)** and install it as a normal app. then you can use Trickystore and pif normally.
- However incase the above APK does not work, Use the command below in **adb shell** to disable the overlay completely.

```sh
cmd overlay disable android.yaap.certifiedprops.overlay
```

- After a reboot you should be passing strong.

### NOTE
- Remember to add your apps in /data/adb/tricky_store/target.txt if they still detect root
- Additionally some apps check for weird dirs such as TWRP or manager apps like KernelSU or apatch ( Keep that in mind )
- To revert this set the props you set to false to true, For YAAP enable the overlay again using the command ( by replacing disable with enable DUH ) or find the overlay in app settings, click top right 3 dots and click uninstall updates.
