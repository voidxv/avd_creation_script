main(){
  # make sure the script runs in its directory
  cd -- "$(dirname "$BASH_SOURCE")"

  #################################################
  # CREATE AVD
  #################################################

  AVD_CMD=$ANDROID_HOME/tools/bin/avdmanager

  # ANDROID_VARIABLES
  ANDROID_DEVICE_DIRECTORY=$ANDROID_HOME/devices
  ANDROID_SKINS_DIRECTORY=$ANDROID_HOME/skins

  # DEVICE VARIABLES
  DEVICE=$1
  DEVICE_SDK=$2

  DEVICE_NAME=${DEVICE}_${DEVICE_SDK}
  DEVICE_DIRECTORY=$ANDROID_DEVICE_DIRECTORY/$DEVICE_NAME
  DEVICE_SKINS_DIRECTORY=$ANDROID_SKINS_DIRECTORY/$DEVICE

  # SKIN VARIABLES
  SOURCE_SKINS_DIRECTORY=skins

  # CONFIG VARIABLES
  CONFIG_TEMPLATE_FILE=device.template

  # SEE IF THE AVD HAS ALREADY BEEN CREATED BY THIS SCRIPT
  if [ ! -d "$DEVICE_DIRECTORY" ]; then

    # CREATE THE DEVICE USING THE
    # AVDMANAGER COMMAND.
    echo "creating $DEVICE_NAME"
    $AVD_CMD create avd \
    --force \
    --name $DEVICE_NAME \
    --package "system-images;android-$DEVICE_SDK;google_apis;x86" \
    --tag "google_apis" \
    --device $(getAvdDeviceId $1) \
    --path $DEVICE_DIRECTORY

    # COPY THE DEVICE'S SKIN INTO THE ANDROID SKINS DIRECTORY IF
    # IT IS NOT ALREADY PRESENT
    if [ ! -d "$DEVICE_SKINS_DIRECTORY" ]; then
      echo "copying $DEVICE skin"
      cp -r $SOURCE_SKINS_DIRECTORY/ $ANDROID_SKINS_DIRECTORY/
    fi

    # CREATE A TEMPORARY COPY OF THE TEMPLATE FILE
    # SO WE CAN MODIFY IT WITHOUT LOSING THE ORIGINAL
    cp $CONFIG_TEMPLATE_FILE $CONFIG_TEMPLATE_FILE.tmp

    # REPLACE THE MOUSTACHE TAGS WITH THE REQUIRED INFORMATION
    sed -i ".sed" "s|{{skin_name}}|$DEVICE|" $CONFIG_TEMPLATE_FILE.tmp
    sed -i ".sed" "s|{{skin_path}}|$ANDROID_SKINS_DIRECTORY/$DEVICE|" $CONFIG_TEMPLATE_FILE.tmp

    # APPEND THE TEMPLATE FILE TO THE END OF THE DEVICE'S CONFIG.INI
    cat $CONFIG_TEMPLATE_FILE.tmp >> $DEVICE_DIRECTORY/config.ini

    # DELETE THE TEMPORARY TEMPLATE &
    # DELETE THE TEMPORARY SED FILE
    rm $CONFIG_TEMPLATE_FILE.tmp
    rm $CONFIG_TEMPLATE_FILE.tmp.sed

  else
    echo "$DEVICE_NAME already created."
  fi
}

getAvdDeviceId() {
  case $1 in
    "AndroidWearRound") echo 2
    ;;
    "AndroidWearSquare") echo 4
    ;;
    "galaxy_nexus") echo 5
    ;;
    "nexus_4") echo 7
    ;;
    "nexus_5") echo 8
    ;;
    "nexus_5x") echo 9
    ;;
    "nexus_6") echo 10
    ;;
    "nexus_6p") echo 11
    ;;
    "nexus_7") echo 13
    ;;
    "nexus_7_2013") echo 12
    ;;
    "nexus_9") echo 14
    ;;
    "nexus_10") echo 6
    ;;
    "nexus_one") echo 15
    ;;
    "nexus_s") echo 16
    ;;
    "pixel") echo 17
    ;;
    "pixel_c") echo 18
    ;;
    "pixel_xl") echo 19
    ;;
    "tv_720p") echo 1
    ;;
    "tv_1080p") echo 0
    ;;
  esac
}

main "$@"
