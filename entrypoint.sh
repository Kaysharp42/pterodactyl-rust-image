#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Rust Server
./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update 258550 +quit

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# OxideMod has been replaced with uMod
if [ -f OXIDE_FLAG ] || [ "${OXIDE}" = 1 ] || [ "${UMOD}" = 1 ]; then
    echo "Updating uMod..."
    curl -sSL "https://umod.org/games/rust/download/develop" > umod.zip
    unzip -o -q umod.zip
    rm umod.zip
    echo "Done updating uMod!"
fi

# Update Rust Edit
if [ "${RUSTEDIT}" = 1 ]; then
    echo "Updating Rust Edit..."
    curl -sL $(curl -sL https://api.github.com/repos/k1lly0u/Oxide.Ext.RustEdit/releases/latest | jq -r .zipball_url) > Oxide.Ext.RustEdit.zip
    unzip -o -q Oxide.Ext.RustEdit.zip
    rm README.md
    mv Oxide.Ext.RustEdit.dll /home/container/RustDedicated_Data/Managed/Oxide.Ext.RustEdit.dll
    echo "Done updating Rust Edit!"
fi

# Fix for Rust not starting
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)

# Run the Server
#node /wrapper.js "${MODIFIED_STARTUP}"