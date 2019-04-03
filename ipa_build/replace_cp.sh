#ipa 资源替换
scriptPath=$(cd `dirname $0`; pwd)
srcDir=${scriptPath}/168/out
tempDir=${scriptPath}/replace/temp
outPutDir=${scriptPath}/replace/out
resRoot=$outPutDir/Payload/TC168.app

#config工程目录 第一步先更新所有config
configDir=${scriptPath}/config 
cd ${configDir}

git checkout -f develop
git pull

appBranch=($@)
if [ "$@" = "all" ]; then
  appBranch=(01 038 0500 093 1000cc 105 106 118  1233 168 234 306 558 666 709 779 8yi 933 998 awcp c6 cp12 cp77 d8 kb lcw qq tz wf xk xxcp xy yycp)
fi 
for app in ${appBranch[@]}
do
    srcIpa=${srcDir}/${app}.ipa
    if [ -d ${srcIpa}]; then
      echo  ${srcIpa} 开始解压
    else
      echo  ${srcIpa} 目录不存在
      exit -1;
   fi
   mkdir -p $tempDir
   rm -rf $tempDir/*
   unzip -q $srcIpa -d $tempDir
   if [ -d ${configDir}/${app}_config]/ios/Info.plist; then
      echo 开始拷贝和替换 ${configDir}/${app}_config/ios/Info.plist  文件
      cp -rf ${configDir}/${app}_config/ios/Info.plist $tempDir
   else
      echo  ${configDir}/${app}_config/ios 目录不存在
      exit -1;
   fi

   cp -rf  $replaceDir/  $resRoot
	#xcrun -sdk iphoneos PackageApplication -v "${resRoot}" -o  "${outPut}/new.ipa"
	#dg deploy ${outPutDir}/${ipaName}
	cd  $tempDir
	zip -qr $targetIpa   *
	#dg deploy $targetIpa
	open .
fi	






