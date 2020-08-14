flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true
cp assets/icon/icon.png build/web/favicon.png
cp assets/icon/Icon-192.png build/web/icons
cp assets/icon/Icon-512.png build/web/icons
cd build/web
scp -r * rusondia.net:/home/lettucebowler/sites/sudoku
