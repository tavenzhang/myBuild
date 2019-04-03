#ipa 资源替换
scriptPath=$(cd `dirname $0`; pwd)
outPut=${scriptPath}/ipa/outPut
srcIpa=${scriptPath}/ipa/src.ipa
targetIpa=new.ipa
replaceDir=replace
resRoot=$outPut/Payload/JD.app


mkdir -p $outPut

rm  -rf $outPut/*

unzip -q $srcIpa -d $outPut
cp -rf  $replaceDir/  $resRoot
#xcrun -sdk iphoneos PackageApplication -v "${resRoot}" -o  "${outPut}/new.ipa"
#dg deploy ${outPutDir}/${ipaName}
cd  $outPut
zip -qr $targetIpa   *
#dg deploy $targetIpa
open .






