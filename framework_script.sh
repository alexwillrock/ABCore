set -e
set +u
# Avoid recursively calling this script.
if [[ $SF_MASTER_SCRIPT_RUNNING ]]
then
exit 0
fi
set -u
export SF_MASTER_SCRIPT_RUNNING=1

SF_TARGET_NAME=$1
SF_EXECUTABLE_PATH="lib${SF_TARGET_NAME}.a"
SF_WRAPPER_NAME="${SF_TARGET_NAME}.framework"
SF_BUILD_DIR="${TARGET_BUILD_DIR}"

echo `env`| tr ' ' '\n'

echo "SF_TARGET_NAME = ${SF_TARGET_NAME}"
echo "SF_EXECUTABLE_PATH = lib${SF_TARGET_NAME}.a"
echo "SF_WRAPPER_NAME = ${SF_TARGET_NAME}.framework"


echo "SF_BUILD_DIR=${SF_BUILD_DIR}"

mkdir -p "${SF_BUILD_DIR}/${SF_TARGET_NAME}.framework/Versions/A/Headers"

# Link the "Current" version to "A"
/bin/ln -sfh A "${SF_BUILD_DIR}/${SF_TARGET_NAME}.framework/Versions/Current"
/bin/ln -sfh Versions/Current/Headers "${SF_BUILD_DIR}/${SF_TARGET_NAME}.framework/Headers"
/bin/ln -sfh "Versions/Current/${SF_TARGET_NAME}" "${SF_BUILD_DIR}/${SF_TARGET_NAME}.framework/${SF_TARGET_NAME}"



if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
SF_SDK_PLATFORM=${BASH_REMATCH[1]}
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi

#Ищем директорию с библиотекой
SF_LIB_PATH="${SF_BUILD_DIR}/${SF_EXECUTABLE_PATH}"
SF_HEADERS_FOLDER_NAME="${SF_TARGET_NAME}Headers"
SF_FRAMEWORK_BUILDED_PATH="${SF_BUILD_DIR}/${SF_WRAPPER_NAME}"
SF_FRAMEWORK_DEST_PATH="${PROJECT_DIR}/${SF_WRAPPER_NAME}"

echo "SF_LIB_PATH=${SF_LIB_PATH}"
echo "SF_HEADERS_PATH=${SF_HEADERS_FOLDER_NAME}"
echo "SF_FRAMEWORK_BUILDED_PATH=${SF_BUILD_DIR}/${SF_WRAPPER_NAME}"
echo "SF_FRAMEWORK_DEST_PATH=${PROJECT_DIR}/${SF_WRAPPER_NAME}"

# The -a ensures that the headers maintain the source modification date so that we don't constantly
# cause propagating rebuilds of files that import these headers.
echo "1"
/bin/cp -a "${SF_BUILD_DIR}/${SF_HEADERS_FOLDER_NAME}/" "${SF_FRAMEWORK_BUILDED_PATH}/Versions/A/Headers"

echo "2"
/bin/cp -a "${SF_LIB_PATH}" "${SF_FRAMEWORK_BUILDED_PATH}/Versions/Current/${SF_TARGET_NAME}"

#copy framework to project directory
if [[ -d $SF_FRAMEWORK_BUILDED_PATH ]]; then

    if [[ -d $SF_FRAMEWORK_DEST_PATH ]]; then
    echo "Removing current framework dir from project: ${SF_FRAMEWORK_DEST_PATH}"
    rm -rf $SF_FRAMEWORK_DEST_PATH
    fi

    echo "Trying to copy ${SF_FRAMEWORK_BUILDED_PATH} to ${SF_FRAMEWORK_DEST_PATH}"
    ditto "${SF_FRAMEWORK_BUILDED_PATH}" "${SF_FRAMEWORK_DEST_PATH}"
fi

