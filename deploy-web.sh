flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true
cp icon/icon.png icon/favicon.png
mv icon/favicon.png build/web
cp icon/Icon-192.png build/web/icons
cp icon/Icon-512.png build/web/icons
cd build/web
scp -r * rusondia.net:/home/lettucebowler/sites/sudoku
