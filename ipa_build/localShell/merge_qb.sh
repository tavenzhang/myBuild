#!/bin/sh

#工程根目录 需要替换成自己本机的工程根目录
tagetPath="/Users/taven/Desktop/cp_build/ios_qb/work"
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

allAppBranch=($@)
#allAppBranch=(977)
#allAppBranch=($1)
for app in ${allAppBranch[@]}
do
   ipaName=${app}.ipa
   echo ipa = ${app}
   cd ${tagetPath} 
   git fetch
   git checkout -f CardGame/${app}_release
   git pull
   git merge  origin/CardGame/develop_card -m 'autoMerge develop'
  if [ $? -eq 0 ];then
    echo ${app} merge成功
   else
    echo ${app} merge 失败 
    exit;
   fi

    #第一步先进行resouce 覆盖，调整基本资源配置
    cp -rf ${configDir}/${app}_config/resouce/* ${tagetPath}/src/Page/resouce/
    #第二步 copy 覆盖游戏图片
    cp -rf ${configDir}/${app}_config/card/res/* ${tagetPath}/src/Page/
    # 覆盖ios 配置
    cp -rf ${configDir}/${app}_config/card/ios/* ${tagetPath}/ios/JD/


   git commit -m 'autoMergeCard'
   git push
   if [ $? -eq 0 ];then
    echo ${app} push=========================成功
   else
    echo ${app} commit==========================打包失败 
    exit;
   fi

# if [ $? -eq 0 ];then	
#     echo 'merge成功'
# else
#     echo "merge失败" 
#     exit -1;
# fi
done

