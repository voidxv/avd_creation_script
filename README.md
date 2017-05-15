# avd_creation_script
A demonstration of how to create a Skinned Android Virtual Device using a bash script that invokes the `avdmanager` command.

# Pre-requisites
In order for the bash script to properly work you will need the following to be set-up and installed.
* The $ANDROID_HOME Environment variable should be set to your machines Android SDK Installation
* SDK Manager Package : "system-images;android-25;google_apis;x86"

# Goal
The goal of this script is to create a Skinned Android Virtual Device using the `avdmanager` command line tool.

# Usage
`create_avd.bash skin_name sdk_version`  
  
The skin_name argument should match the name of a folder inside the skins directory. You will need an x86 System-Image for the sdk_version that you pass into the script. You can check if you have any installed system-images by running the following command: `sdkmanager --list`. Or you can have `sdkmanager` install the required package by running `sdkmanager 'system-images;android-{SDK_VERSION};google_apis;x86'`.

# Code Explanation
I created this script because the new `avdmanager` tool does not come with an option to specify a device skin. Therefore I took the skin files that come bundled with Android Studio and stuck them into the skins folder that you can find in this repo.

### STEP 1: Creating the AVD
The first step should seem pretty straight forward if you have figured out how to use the new `avdmanager` command. If not then this should help you out quite a bit. Probably the trickiest part of creating the AVD is the `--package` option that you have to exactly specify. The option is wanting the exact system-image package that `sdkmanager` has installed onto your machine. E.G `system-images;android-25;google_apis;x86` for SDK 25.
```
# CREATE THE TEST DEVICE USING THE
# AVDMANAGER COMMAND.
echo "creating $DEVICE_NAME"
$AVD_CMD create avd \
--force \
--name $DEVICE_NAME \
--package "system-images;android-$DEVICE_SDK;google_apis;x86" \
--tag "google_apis" \
--device $(getAvdDeviceId $1) \
--path $DEVICE_DIRECTORY
```
### STEP 2: Putting the skin into the SDK's skins folder
In this step, the script is putting the specified device skin into the SDK's skins folder, so that we can tell the emulator to look in that specific location for the skin when launching the created AVD.
```
# COPY THE DEVICE'S SKIN INTO THE ANDROID SKINS DIRECTORY IF
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
The script replaces the {{skin_name}} and {{skin_path}} to the specfied skins name and path respectively. The `gpu.enabled=yes` and `gpu.mode=auto` configuration's are added to speed up interaction with the device.  
  
And that is honestly it. Please feel free to ask questions or submit pull requests if you find an issue that you would like to fix.  
Cheers!
