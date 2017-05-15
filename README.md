# avd_creation_script
A demonstration of how to create a Pixel Test Device with Android SDK 25 using a bash script that invokes the `avdmanager` command. The resulting AVD will be fully skinned to the Device's Specifications.

# Pre-requisites
In order for the bash script to properly work you will need the following to be set-up and installed.
* The $ANDROID_HOME Environment variable should be set to your machines Android SDK Installation
* SDK Manager Package : "system-images;android-25;google_apis;x86"

# Goal
The goal of this script is to create a Skinned Android Virtual Device using the `avdmanager` command line tool.

# Usage
By modifying the `DEVICE` and `DEVICE_SDK` Variable from within the script you can specify which device and SDK Version you want the script to create. The resulting device will be named `DEVICE`_`DEVICE_SDK` Example: 'pixel' Device with SDK Version '25' will be named pixel_25. The `DEVICE` variable should match the name of a skin folder.

### Note:
When changing the SDK version, You will need to have an x86 system image for that SDK Version.  
Consider this line of code: `--package "system-images;android-$DEVICE_SDK;google_apis;x86"`  
  
If you do not have the required system-image installed to your system you can run `sdkmanager --list` to list the packages that you do have installed on your machine, or you can have `sdkmanager` install the required package by running `sdkmanager 'system-images;android-REQUIRED_SDK_VERSION;google_apis;x86'`.

# Code Explanation
I created this script because the new `avdmanager` tool does not come with an option to specify a device skin. Therefore I took the skin files that come bundled with Android Studio and stuck them into my a skins folder that you can find in this repo.

### STEP 1: Creating the AVD
The first step should seem pretty straight forward if you have figured out how to use the new `avdmanager` command. If not then this should help you out quite a bit. Probably the trickiest part of creating the AVD is the `--package` option that you have to exactly specify. The option is wanting the exact system-image package that `sdkmanager` has installed onto your machine. E.G `system-images;android-25;google_apis;x86` for SDK 25. I am hardcoding the `--device` option to `pixel` because the name of the devices do not exactly match the name of the skin folders. I did not feel like creating a large function to convert the Skin Folder name to the device's names in `avdmanager`.  
  
```
# CREATE THE TEST DEVICE USING THE
# AVDMANAGER COMMAND.
echo "creating $DEVICE_NAME"
$AVD_CMD create avd \
--force \
--name $DEVICE_NAME \
--package "system-images;android-$DEVICE_SDK;google_apis;x86" \
--tag "google_apis" \
--device pixel \
--path $DEVICE_DIRECTORY
```

### STEP 2: Putting the skin into the SDK's skins folder
In this step of the code. The script is putting the specific device skin into the SDK's skins folder, so that we can tell the emulator to look in that specific location for the skin when launching our AVD.
  
```
# COPY THE DEVICE SKIN INTO THE ANDROID SKINS DIRECTORY IF
# IT IS NOT ALREADY PRESENT
if [ ! -d "$DEVICE_SKINS_DIRECTORY" ]; then
  echo "copying $DEVICE skin"
  cp -r $SOURCE_SKINS_DIRECTORY/ $ANDROID_SKINS_DIRECTORY/
fi
  ```
  
### STEP 3: Appending the rest of the config.ini to the device's config.ini
But simply putting the skin files into the machines sdk directory is not enough for the emulator to know which skin to use when starting the AVD. For that we need to modify the `config.ini` that the `avdmanager create avd` command creates when creating the device. In the scripts root folder there is a device.template file that is used to construct the rest of the `config.ini` that the `avdmanager` tool doesn't create at this time. This is the key to making sure that the emulator will be able to use the skin that we copied in the previous step.  
  
Here is the `device.template` file that gets appended to the created devices `config.ini`  
  
```
showDeviceFrame=yes
skin.dynamic=yes
skin.name={{skin_name}}
skin.path={{skin_path}}
hw.gpu.enabled=yes
hw.gpu.mode=auto
hw.ramSize=1536
```  
  
The script replaces the {{skin_name}} and {{skin_path}} the specfied skins name and path respectively. The `gpu.enabled=yes` and `gpu.mode=auto` configuration's are added to greatly speed up interaction with the device if you're machine has HAXM installed.  
  
And that is honestly it. Please feel free to ask questions or submit pull requests if you see an issue that you would like to fix.  
Cheers!
