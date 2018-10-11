#!/bin/sh

#工程根目录 需要替换成自己本机的工程根目录
workRoot="/Users/taven/Desktop/cp_build/ios_qb/work"

tagetPath=${workRoot}/ios

#工程名
tagetName="JD"
#时间
buildTime=`date "+%Y%m%d"`

configDir="/Users/taven/Desktop/cp_build/TC168_Config"

cd ${configDir}

git checkout -f develop
git pull

#scriptPath=$(cd `dirname $0`; pwd)
outPutDir="/Users/taven/Desktop/cp_build/ios_qb/output"


rm -rf ${tagetPath}/build/Applications/*
# allAppBranch=(234 yycp 709 xy kb)
allAppBranch=($1)
for app in ${allAppBranch[@]}
do
   ipaName=${app}_qp.ipa
   echo ipa = ${app}
   rm -rf ${outPutDir}/${ipaName}
   cd ${workRoot}
   git fetch
   git checkout -f CardGame/${app}_release
   git pull
   #第一步先进行resouce 覆盖，调整基本资源配置
    cp -rf ${configDir}/${app}_config/resouce/* ${workRoot}/src/Page/resouce/
   #第二步 copy 覆盖游戏图片
    cp -rf ${configDir}/${app}_config/card/res/* ${workRoot}/src/Page/
    # 覆盖ios 配置
   cp -rf ${configDir}/${app}_config/card/ios/* ${workRoot}/ios/JD/
  cd ${tagetPath}
  xcodebuild clean -configuratioan Distribution
  xcodebuild -scheme ${tagetName} -destination generic/platform=iOS archive DSTROOT="build" -project JD.xcodeproj
   if [ $? -eq 0 ];then
     echo '编译成功'
   else
     echo '打包失败'
     exit -1;
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

