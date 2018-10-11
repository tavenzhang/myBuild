#!/bin/sh


#工程根目录 需要替换成自己本机的工程根目录
workRoot="/Users/taven/Desktop/cp_build/168/cp_168"
#ios工程目录
iosRoot=${workRoot}/ios
#scriptPath=$(cd `dirname $0`; pwd)
#产品输出目录
outPutDir="/Users/taven/Desktop/cp_build/168/cp_release"
#工程名
targetName="TC168"
#时间
buildTime=`date "+%Y%m%d"`

configDir="/Users/taven/Desktop/cp_build/TC168_Config"

rm -rf ${iosRoot}/build/Applications/*
# allAppBranch=(038 106 118 306 c6 cp12 qq 666 709 tz kb wf d8 105 933 998 8yi 0500 xk 01 lcw 1233 168 cp77 awcp 779)
allAppBranch=($@)
for app in ${allAppBranch[@]}
do
   ipaName=${app}.ipa
   echo ipa = ${app}
   rm -rf ${outPutDir}/${app}
      #删除清理之前存在的文件
   cd ${iosRoot}
   xcodebuild -exportArchive  -archivePath build/${targetName}.xcarchive   -exportOptionsPlist build/exportOptions.plist -exportPath ${outPutDir}/${app}
   #老方式 打包体积有问题
   #xcrun -sdk iphoneos PackageApplication -v "${iosRoot}/build/Applications/${targetName}.app" -o "${outPutDir}/${ipaName}"
   dg deploy ${outPutDir}/${app}/${targetName}.ipa
  if [ $? -eq 0 ];then	
      echo '打包签名成功'
  else
      echo "打包失败 签名错误" 
      exit -1;
  fi

done

