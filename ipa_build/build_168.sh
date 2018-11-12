#!/bin/sh
scriptPath=$(cd `dirname $0`; pwd)
#工程根目录 需要替换成自己本机的工程根目录
workRoot=${scriptPath}/168/work 
#ios工程目录
iosRoot=${workRoot}/ios
#scriptPath=$(cd `dirname $0`; pwd)
#产品输出目录
outPutDir=${scriptPath}/168/out
#工程名
targetName="TC168"
#时间
buildTime=`date "+%Y%m%d"`

configDir=${scriptPath}/config 
remoteDir="/Volumes/jxshare2/APP/iOS/未签名-企业包cp"
deployDir="/Volumes/jxshare/deploy/apk"

#更新config文件
cd ${configDir}
git checkout -f develop
git pull


appBranch=($@)

if [ "$@" = "all" ]; then
  appBranch=(01 038 0500 093 1000cc 105 106 118  1233 168 234 306 558 666 709 779 8yi 933 998 awcp c6 cp12 cp77 d8 kb lcw qq tz wf xk xxcp xy yycp)
fi  
#allAppBranch=($@)
for app in ${appBranch[@]}
do
   ipaName=${app}.ipa
   echo ipa = ${app} "com.id.org.${app}"
   cd ${workRoot} 
   git fetch
   git checkout -f feature/release/${app}_release
   
     #如果输入分支不存在 退出报错
   if [ $? -eq 0 ];then
      echo feature/release/${app}_release 分支切换成功
     else
      echo feature/release/${app}_release 分支不存在
   exit -1;
   fi

   git pull
   #git merge  origin/master -m 'autoMerge develop'
   git merge -Xtheirs origin/master -m 'autoMerge master'
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
   rm -rf ${iosRoot}/TC168/Images.xcassets
   cp -rf ${configDir}/${app}_config/ios/*   ${iosRoot}/TC168/
   cp -rf ${configDir}/${app}_config/resouce/* ./src/Page/resouce/
   # cp -rf ${configDir}/${app}_config/resource/* ./src/Page/resouce/
   #删除清理之前存在的文件
   cd ${iosRoot}
   xcodebuild -target ${targetName}  clean 
   xcodebuild clean -configuration Release
   rm -rf build/${targetName}.xcarchive 
   xcodebuild archive -scheme ${targetName} -archivePath build/${targetName}.xcarchive -workspace ${targetName}.xcworkspace -configuration Release  -allowProvisioningUpdates -allowProvisioningDeviceRegistration 
   #PRODUCT_BUNDLE_IDENTIFIER="com.id.org.${app}"
   if [ $? -eq 0 ];then
      echo ${app} '编译成功'
   else
     echo '打包失败'  
     exit -1;
   fi
   #先删除已经存在的
   rm -rf ${outPutDir}/${ipaName}
  xcodebuild -exportArchive  -archivePath build/${targetName}.xcarchive  -exportOptionsPlist build/exportOptions.plist -exportPath ${outPutDir}/${app} -allowProvisioningUpdates -allowProvisioningDeviceRegistration 
  if [ $? -eq 0 ];then	
      echo '打包签名成功'
      cd ${workRoot} 
      #git add -A
       git add ./
       git commit -m 'autoMerge-master and replace config'
      # git push
        @ echo ${app} commit===成功
        #上传deployGate
        mv ${outPutDir}/${app}/${targetName}.ipa    ${outPutDir}/${ipaName}
        rm -rf ${outPutDir}/${app}
        dg deploy ${outPutDir}/${ipaName}
         # -d 参数判断 $remoteDir 是否存在
        if [ -d $remoteDir ]; then
          cp -rf ${outPutDir}/${ipaName} $remoteDir/${ipaName}
        fi
        if [ -d $deployDir ]; then
          mkdir -p $deployDir/ios/unsign/cp
          cp -rf ${outPutDir}/${ipaName} $deployDir/ios/unsign/cp/${ipaName}
        fi

  else
      echo "打包失败 签名错误" 
      exit -1;
  fi

echo "ipa包在 ${outPutDir}/${app} 目录下,上传 deploy成功！";
done

