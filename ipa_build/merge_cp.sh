#!/bin/sh
scriptPath=$(cd `dirname $0`; pwd)
#工程根目录 需要替换成自己本机的工程根目录
workRoot=${scriptPath}/168/work 

configDir=${scriptPath}/config 

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
   echo start============= ipa = ${app}
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
   rm -rf ${iosRoot}/TC168/Images.xcassets
   cp -rf ${configDir}/${app}_config/ios/*   ${iosRoot}/TC168/
   cp -rf ${configDir}/${app}_config/resouce/* ./src/Page/resouce/

   git commit -m 'autoMergeMaster-第三方游戏接口'
   git push
   if [ $? -eq 0 ];then
    echo ${app} commit push--成功
   else
    echo ${app} commit push--失败 
    exit -1;
   fi
done

