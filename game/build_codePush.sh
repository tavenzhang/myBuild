#!/bin/sh
scriptPath=$(cd `dirname $0`; pwd)
#工程根目录 需要替换成自己本机的工程根目录
workRoot=${scriptPath}/work 


configDir=${scriptPath}/config/app-config 

#更新config文件
cd ${configDir}
git checkout -f taven
git pull 
echo checkout -f taven

appBranch=($@)

if [ "$@" = "all" ]; then
  appBranch=(365)
fi  
#allAppBranch=($@)
for app in ${appBranch[@]}
do
    codePushDir=${configDir}/${app}/code-push
    echo "codePushDir="${codePushDir} 

    if [ -d ${codePushDir} ]; then
      echo code-push ${codePushDir} 文件存在
    else
      echo  ${codePushDir}  目录不存在
      exit -1;
   fi
   cd ${workRoot}
   sh ${codePushDir}/publish.sh
   
   if [ $? -eq 0 ];then
    echo ${app} code-push成功
   else
    echo ${app} code-push 失败 
    exit -1;
   fi 
 
done

