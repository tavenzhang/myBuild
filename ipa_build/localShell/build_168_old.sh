#!/bin/sh
scriptPath=$(cd `dirname $0`; pwd)
#工程根目录 需要替换成自己本机的工程根目录
workRoot=${scriptPath}/168/work 
#ios工程目录
iosRoot=${workRoot}/ios
#scriptPath=$(cd `dirname $0`; pwd)
#产品输出目录
outPutDir=${scriptPath}/168/work/out
#工程名
targetName="TC168"
#时间
buildTime=`date "+%Y%m%d"`

configDir=${scriptPath}/config 

#更新config文件
cd ${configDir}
git checkout -f develop
git pull

rm -rf ${iosRoot}/build/Applications/*
# allAppBranch=(038 106 118 306 c6 cp12 qq 666 709 tz kb wf d8 105 933 998 8yi 0500 xk 01 lcw 1233 168 cp77 awcp 779)
allAppBranch=($@)
for app in ${allAppBranch[@]}
do
   ipaName=${app}.ipa
   echo ipa = ${app}
   rm -rf ${outPutDir}/${app}
   cd ${workRoot} 
   git fetch
   git checkout -f feature/release/${app}_release
   git pull
   #git merge  origin/develop -m 'autoMerge develop'
   git merge -Xtheirs origin/develop -m 'autoMerge develop'

   if [ $? -eq 0 ];then
    echo ${app} merge成功
   else
    echo ${app} merge 失败 
    exit -1;
   fi

   rm -rf ${iosRoot}/TC168/Images.xcassets
   cp -rf ${configDir}/${app}_config/ios/*   ${iosRoot}/TC168/

   cp -rf ${configDir}/${app}_config/resouce/* ./src/Page/resouce/

   #删除清理之前存在的文件
   cd ${iosRoot}
   xcodebuild -target ${targetName}  clean 
   xcodebuild clean -configuration Release
   #rm -rf build/${targetName}.xcarchive 
   #xcodebuild archive -scheme ${targetName}  DSTROOT="build" -workspace ${targetName}.xcworkspace 
   xcodebuild archive -scheme ${targetName} -archivePath build/${targetName}.xcarchive   -workspace ${targetName}.xcworkspace -configuration Release 
   if [ $? -eq 0 ];then
      echo ${app} '编译成功'
   else
     echo '打包失败'  
     exit -1;
   fi
   xcodebuild -exportArchive  -archivePath build/${targetName}.xcarchive -exportOptionsPlist build/exportOptions.plist -exportPath ${outPutDir}/${app}  -allowProvisioningUpdates -allowProvisioningDeviceRegistration 

   #老方式 打包体积有问题
   #xcrun -sdk iphoneos PackageApplication -v "${iosRoot}/build/Applications/${targetName}.app" -o "${outPutDir}/${ipaName}"
   #dg deploy ${outPutDir}/${ipaName}
  if [ $? -eq 0 ];then	
      echo '打包签名成功'
      cd ${workRoot} 
      #git add -A
      git add ./
      git commit -m 'autoMerge-develop'
      git push
       if [ $? -eq 0 ];then
         @ echo ${app} push===成功
          #上传deployGate
         dg deploy ${outPutDir}/${app}/${targetName}.ipa
      else
          echo ${app} push ==失败 
          exit -1;
      fi
  else
      echo "打包失败 签名错误" 
      exit -1;
  fi


echo "ipa包在 ${outPutDir} 目录下,上传 deploy成功！";

done

