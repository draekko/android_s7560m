#!/bin/bash

# Quick Deodex script by mbc07 @ XDA
# Last updated in 2014-06-09 (v1.0.2)



function quit {
    echo;
    echo "Press any key to exit..."
    read -n 1 -s
    exit
}

function deodex {
    tmp="$(ls $1 | grep .odex)"
    if [ ! "$tmp" ]; then
    echo "No ${2^^}s to deodex in $1, skipping..."
    else
    for i in $1/*.$2; do
        if [ -f ${i%.$2}.odex ]; then
        rm -r ${i%.$2} &> /dev/null
        echo -n "Deodexing $(basename ${i%.$2}).$2 "
        java -jar ./tools/baksmali.jar -d ./files/framework -x ${i%.$2}.odex -o ${i%.$2} &> /dev/null
        java -jar ./tools/smali.jar ${i%.$2} -o ${i%.$2}/classes.dex &> /dev/null
        if [ ! -f ${i%.$2}/classes.dex ]; then
            echo "[ERROR]"
            rm -r ${i%.$2} &> /dev/null
        else
            ./tools/7za.elf a -tzip $i ${i%.$2}/classes.dex &> /dev/null
            ./tools/zipalign.elf -f 4 $i $i.aligned &> /dev/null
            #rm $i &> /dev/null
            mv $i.aligned $i &> /dev/null
            #rm -r ${i%.$2} &> /dev/null
            #rm ${i%.$2}.odex &> /dev/null
            echo "[DONE]"
        fi
        fi
    done
    fi
}

if [ ! -d ./files ]; then
    mkdir ./files
fi

chmod 755 ./tools/7za.elf &> /dev/null
chmod 755 ./tools/zipalign.elf &> /dev/null
echo -ne "\033]2;Quick Deodex v1.0.2\007"

tmp="$(ls ./files/framework | grep .jar)"
if [ ! "$tmp" ]; then
    echo "ERROR: framework not found."
    quit
fi

deodex ./files/app apk
if [ -d ./files/priv-app ]; then deodex ./files/priv-app apk; fi
deodex ./files/framework apk
deodex ./files/framework jar

echo "Finished."
quit
