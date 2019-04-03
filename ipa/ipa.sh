#ipa 资源替换
outPut=./outPut
srcIpa=./xy_card.ipa
targetIpa=new.ipa
resRoot=$outPut/Payload/JD.app


mkdir -p $outPut

rm  -rf $outPut/*

unzip -q $srcIpa -d $outPut
cp -rf  replace/  $resRoot
cd  $outPut
zip -qr $targetIpa   *
open .






