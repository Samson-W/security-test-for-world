#!/bin/bash
echo "Start check updata of security..............."
apt-get upgrade -s | grep -i security  | grep Inst > /tmp/updatasec
echo "Updata of security info :"
linec=`cat /tmp/updatasec | wc -l`
if [ $linec -gt 0 ]; then
	cat /tmp/updatasec
elif [ $linec -eq 0 ]; then
	echo "This system  is not need updata of security!"
fi
rm /tmp/updatasec
echo "End check updata of security................."
