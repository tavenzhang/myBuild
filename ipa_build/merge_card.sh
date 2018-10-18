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

appBranch=($@)

if [ "$@" = "all" ]; then
  appBranch=(234 yycp 709 xy kb xxcp 933)
fi  
#allAppBranch=($@)
for app in ${appBranch[@]}
do
   ipaName=${app}.ipa
   echo start============= ipa = ${app}
   cd ${workRoot} 
   git fetch
   git checkout -f CardGame/${app}_release
   #如果输入分支不存在 退出报错
   if [ $? -eq 0 ];then
      echo $CardGame/${app}_release 分支切换成功
     else
      echo CardGame/${app}_release 分支不存在
     exit -1;
   fi
   git pull
   git merge -Xtheirs origin/master -m 'autoMerge master'
   if [ $? -eq 0 ];then
    echo ${app} merge成功
   else
    echo ${app} merge 失败 
    exit -1;
   fi
   if [ -d ${configDir}/${app}_config ]; then
      echo 开始拷贝和替换 ${configDir}/${app}_config 文件
   else
      echo  ${configDir}/${app}_config 目录不存在
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

   git commit -m 'autoMergeMaster '
   git push
   if [ $? -eq 0 ];then
    echo ${app} commit push--成功
   else
    echo ${app} commit push--失败 
    exit -1;
   fi
done

