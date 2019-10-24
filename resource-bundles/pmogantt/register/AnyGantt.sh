#!/bin/bash
echo "Registering AnyChart SWF Folder in FlashPlayer Security Trust Folder..."
if [ -d $HOME/.macromedia/Flash_Player/#Security ]
then
	echo "..."
else
	mkdir $HOME/.macromedia/Flash_Player/#Security
fi
if [ -d $HOME/.macromedia/Flash_Player/#Security/FlashPlayerTrust ]
then
	echo "..."
else
	mkdir $HOME/.macromedia/Flash_Player/#Security/FlashPlayerTrust
fi
FP_SEC=$HOME/.macromedia/Flash_Player/#Security/FlashPlayerTrust
FL_ANYCHART="$PWD"
REGISTER_FILE=$FP_SEC/anychart$RANDOM.cfg
echo $FL_ANYCHART> $REGISTER_FILE
echo $FL_ANYCHART/swf>> $REGISTER_FILE
echo "Done. Please restart your Browser if it launched."
exit 
