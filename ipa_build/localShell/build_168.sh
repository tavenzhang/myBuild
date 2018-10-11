#!/bin/sh


#工程根目录 需要替换成自己本机的工程根目录

tagetPath="/Users/taven/Desktop/cp_build/cp_168/ios"
#工程名
tagetName="TC168"
#时间
buildTime=`date "+%Y%m%d"`

configDir="/Users/taven/Desktop/cp_build/TC168_Config"

cd ${configDir}

git checkout -f develop
git pull

#scriptPath=$(cd `dirname $0`; pwd)
outPutDir="/Users/taven/Desktop/cp_build/cp_release"


rm -rf ${tagetPath}/build/Applications/*
# allAppBranch=(038 106 118 306 c6 cp12 qq 666 709 tz kb wf d8 105 933 998 8yi 0500 xk 01 lcw 1233 168 cp77 awcp 779)
allAppBranch=($1)
for app in ${allAppBranch[@]}
do
   ipaName=${app}.ipa
   echo ipa = ${app}
   rm -rf ${outPutDir}/${ipaName}
   cd ${tagetPath} && cd ..
   git fetch
   git checkout -f feature/release/${app}_release
   git pull
   cp -rf ${configDir}/${app}_config/ios/*   ${tagetPath}/TC168
   cp -rf ${configDir}/${app}_config/resouce  ./src/Page/resouce
   cd ${tagetPath}

  xcodebuild clean -configuratioan Distribution

  xcodebuild -scheme ${tagetName} -destination generic/platform=iOS archive DSTROOT="build" -workspace ${tagetName}.xcworkspace

   if [ $? -eq 0 ];then
     echo '编译成功'
   else
     echo '打包失败' exit;
   fi
  xcrun -sdk iphoneos PackageApplication -v "${tagetPath}/build/Applications/${tagetName}.app" -o "${outPutDir}/${ipaName}"
  dg deploy ${outPutDir}/${ipaName}

if [ $? -eq 0 ];then	
    echo '打包签名成功'
else
    echo "打包失败 签名错误" 
    exit -1;
fi

echo "ipa包在 ${outPutDir} 目录下,上传 deploy成功！";

done

