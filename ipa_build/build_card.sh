#!/bin/sh
scriptPath=$(cd `dirname $0`; pwd)
#工程根目录 需要替换成自己本机的工程根目录
workRoot=${scriptPath}/card/work
outPutDir=${scriptPath}/card/out

tagetPath=${workRoot}/ios
#工程名
targetName="JD"
#时间
buildTime=`date "+%Y%m%d"`

#config工程目录 第一步先更新所有config
configDir=${scriptPath}/config 

cd ${configDir}

git checkout -f develop
git pull

# allAppBranch=(234 yycp 709 xy kb)
allAppBranch=($@)
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
    #避免 xasset存在本地多余文件
   rm -rf ${workRoot}/ios/JD/Images.xcassets
   cp -rf ${configDir}/${app}_config/card/ios/* ${workRoot}/ios/JD/

    git merge  origin/CardGame/develop_card -m 'autoMerge develop'
    if [ $? -eq 0 ];then
      echo ${app} merge成功
   else
      echo ${app} merge 失败 
    exit;
    fi

  cd ${tagetPath}
   xcodebuild clean -configuration Release
   rm -rf build/${targetName}.xcarchive 
  xcodebuild archive -scheme ${targetName} -archivePath build/${targetName}.xcarchive   -project JD.xcodeproj -configuration Release
   if [ $? -eq 0 ];then
     echo '编译成功'
   else
     echo '打包失败'
     exit -1;
   fi
   xcodebuild -exportArchive  -archivePath build/${targetName}.xcarchive -exportOptionsPlist build/exportOptions.plist -exportPath ${outPutDir}/${app} -allowProvisioningUpdates -allowProvisioningDeviceRegistration
   #如果打包成功  push 最新修改 到cardRelease
   cd ${workRoot}
    git add ./
    git commit -m 'autoMerge|cardGame'
    git push
    dg deploy ${outPutDir}/${app}/${targetName}.ipa
if [ $? -eq 0 ];then	
    echo '打包签名成功'
else
    echo "打包失败 签名错误" 
    exit -1;
fi

echo ipa包在 ${outPutDir}/${app}/${targetName}.ipa 目录下,上传 deploy成功！

done

