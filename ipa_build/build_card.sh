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

remoteDir="/Volumes/jxshare2/APP/iOS/未签名-独立棋牌包"
deployDir="/Volumes/jxshare/deploy/apk"

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
   git checkout -f feature/release/${app}_release
  #如果输入分支不存在 退出报错
   if [ $? -eq 0 ];then
      echo $CardGame/${app}_release 分支切换成功
     else
      echo CardGame/${app}_release 分支不存在
   exit -1;
   fi

   git pull
    git merge -Xtheirs   origin/CardGame/develop_card -m 'autoMerge develop'
    if [ $? -eq 0 ];then
      echo ${app} merge成功
    else
      echo ${app} merge 失败 
    exit -1;
    fi
    #第0步判断 对应的config 分支是否存在 避免命令不一致的情况，早点发现
    if [ -d ${configDir}/${app}_config/ios ]; then
      echo 开始拷贝和替换 ${configDir}/${app}_config/ios 文件
    else
      echo  ${configDir}/${app}_config/ios 目录不存在
      exit -1;
   fi
    #第一步先进行resouce 覆盖，调整基本资源配置
    cp -rf ${configDir}/${app}_config/resouce/* ${workRoot}/src/Page/resouce/
    #第二步 copy 覆盖游戏图片
    cp -rf ${configDir}/${app}_config/card/res/* ${workRoot}/src/Page/
     #避免 xasset存在本地多余文件
   rm -rf ${workRoot}/ios/JD/Images.xcassets
   # 覆盖ios 配置
   cp -rf ${configDir}/${app}_config/card/ios/* ${workRoot}/ios/JD/

  cd ${tagetPath}
   #xcodebuild clean -configuration Release
  # xcodebuild archive -scheme ${targetName} -archivePath build/${targetName}.xcarchive   -project JD.xcodeproj -configuration Release -allowProvisioningUpdates -allowProvisioningDeviceRegistration
   if [ $? -eq 0 ];then
     echo '编译成功'
   else
     echo '打包失败'
     exit -1;
   fi
   xcodebuild -exportArchive  -archivePath build/${targetName}.xcarchive -exportOptionsPlist build/exportOptions.plist -exportPath ${outPutDir}/${app} -allowProvisioningUpdates -allowProvisioningDeviceRegistration

   if [ $? -eq 0 ];then  
        echo '打包签名成功'
         #如果打包成功  push 最新修改 到cardRelease
        cd ${workRoot}
        git add ./
        git commit -m 'autoMerge|cardGame'
       # git push
       #echo ipa====== ${outPutDir}/${app}/${targetName}.ipa
         mv ${outPutDir}/${app}/${targetName}.ipa   ${outPutDir}/${app}/${app}_card.ipa 
         dg deploy ${outPutDir}/${app}/${app}_card.ipa 
        # -d 参数判断 $remoteDir 是否存在
       if [ -d $remoteDir ]; then
          cp -rf ${outPutDir}/${app}/${app}_card.ipa  ${remoteDir}/${app}_card.ipa
       fi
       if [ -d $deployDir ]; then
          mkdir -p $deployDir/ios/unsign/card
          cp -rf ${outPutDir}/${ipaName} $deployDir/ios/unsign/card/${app}_card.ipa 
        fi
    else
        echo "打包失败 签名错误" 
        exit -1;
    fi

echo ipa包在 ${outPutDir}/${app}/${app}_card.ipa  目录下,上传 deploy成功！

done

