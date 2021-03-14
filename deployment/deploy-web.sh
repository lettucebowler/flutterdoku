flutter build web
mkdir build/web/icons
cp assets/icon/icon.png build/web/favicon.png
cp assets/icon/Icon-192.png build/web/icons
cp assets/icon/Icon-512.png build/web/icons
cd build/web
scp -r * rusondia.net:/home/lettucebowler/sites/sudoku
