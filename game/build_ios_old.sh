#!/bin/sh
scriptPath=$(cd `dirname $0`; pwd)
#工程根目录 需要替换成自己本机的工程根目录
workRoot=${scriptPath}/work 
#ios工程目录
iosRoot=${workRoot}/ios
#scriptPath=$(cd `dirname $0`; pwd)
androidRoot=${workRoot}/android
#工程名
targetName="JD"
#时间
buildTime=`date "+%Y%m%d"`

configDir=${scriptPath}/BBL_Game_Config

#产品输出目录
#outPutDir=${scriptPath}/out

deployDir="/Volumes/jxshare/deploy/game/release"

# CODE_SIGN_IDENTITY="iPhone Distribution: ALBARINA"

# PROVISIONING_PROFILE_NAME="wf-test"
# IOS_BOUND_ID="com.id.org.test"

#更新config文件
cd ${configDir}
git checkout  develop
git pull 
echo checkout develop
 if [ $? -eq 0 ];then
   echo checkout config develop 分支切换成功
  else
    echo checkout config develop 分支切换成功分支不存在 
    exit -1;
 fi
appBranch=($@)

if [ "$@" = "all" ]; then
  appBranch=(bbl 365)
fi  
#allAppBranch=($@)
for app in ${appBranch[@]}
do
   ipaName=${app}_unsign.ipa
   outPutDir=${configDir}/${app}/publish
   echo ipa = ${app} xingxing/bbl_${app}
   cd ${workRoot} 
   git fetch
   git checkout  release/${app} 
   if [ $? -eq 0 ];then
      echo ${app}  app/release/${app}  分支切换成功 ${workRoot}
     else
      echo ${app}  app/release/${app}  分支不存在 ${workRoot}
   exit -1;
   fi
   git pull 

   #git merge  app/develop -m 'app/develop'
   git merge -Xtheirs app/develop -m 'autoMerge release'
   if [ $? -eq 0 ];then
    echo ${app} merge成功
   else
    echo ${app} merge 失败 
    exit -1;
   fi
      #第0步判断 对应的config 分支是否存在 避免命令不一致的情况，早点发现
    if [ -d ${configDir}/${app}/ios ]; then
      echo 开始拷贝和替换 ${configDir}/${app}/ios 文件
    else
      echo  ${configDir}/${app}/ios 目录不存在
      exit -1;
   fi
   rm -rf ${iosRoot}/JD/Images.xcassets
   cp -rf ${configDir}/game/*   ${androidRoot}/app/src/main/assets/gamelobby/
   cp -rf ${configDir}/${app}/ios/*   ${iosRoot}/JD/
   cp -rf ${configDir}/${app}/js/* ${workRoot}/src
   #android的也替换处理
   cp -rf ${configDir}/${app}/android/*   ${androidRoot}/
  
   #删除清理之前存在的文件
   cd ${iosRoot}
   pod install
   xcodebuild -target card  clean 
   xcodebuild clean -configuration Release
   rm -rf build/${targetName}.xcarchive 

   buildPath=build/build
   payloadPath=build/temp/Payload
   appFileFullPath=${buildPath}/Build/Products/Release-iphoneos/${targetName}.app

   mkdir -p ${payloadPath} ${buildPath}

  xcodebuild archive -scheme ${targetName}  -sdk iphoneos -derivedDataPath  ${buildPath}   -workspace ${targetName}.xcworkspace -configuration Release  
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

   if [ $? -eq 0 ];then
      echo ${app} '编译成功'
   else
     echo '编译失败'  
     exit -1;
   fi
   cp -r ${appFileFullPath} ${payloadPath}
    # 打包并生成 .ipa 文件
    cd build/temp
    zip -q -r ${ipaName} Payload
    
  


  if [ $? -eq 0 ];then	
      echo '打包签名成功'
      cd ${workRoot} 
       #git add -A
       git add ./
       git commit -m `autoMerge-releae and replace config ${buildTime}`
      # git push
       # echo ${app} commit===成功
        #上传deployGate
        # mv ${outPutDir}/${app}/${targetName}.ipa    ${outPutDir}/${ipaName}
        # rm -rf ${outPutDir}/${app}
        # dg deploy ${outPutDir}/${ipaName}
        # if [ -d $deployDir ]; then
        #   mkdir -p $deployDir/${app}
        #   cp -rf ${outPutDir}/${ipaName} $deployDir/${app}/${ipaName}
        #    if [ $? -eq 0 ];then
        #       echo $deployDir/${app}/${ipaName} '上传服务器成功'
        #    else
        #      echo '上传服务器失败'  
        #      exit -1;
        #    fi
        # fi
  else
      echo "打包失败 签名错误" 
      exit -1;
  fi

echo "ipa包在 ${outPutDir}/${app} 目录下,上传 deploy成功！";
done

