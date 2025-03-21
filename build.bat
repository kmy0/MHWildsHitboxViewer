git pull --recurse-submodules
git submodule update --init --recursive
pushd deps\hb_draw
call build.bat
popd
md bin\reframework\plugins
md bin\reframework\autorun
robocopy src bin\reframework\autorun /mir
robocopy deps\hb_draw\bin bin\reframework\plugins hb_draw.dll
tar -a -cf HitboxViewer.zip -C bin reframework
