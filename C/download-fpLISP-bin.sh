BIN=fpLISP-`uname -m`-`uname -s`
curl -sL -o $BIN https://github.com/ytaki0801/fpLISP/blob/master/C/$BIN?raw=true && chmod 755 $BIN && echo "$BIN has been downloaded."
