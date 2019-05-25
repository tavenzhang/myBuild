#!/bin/sh
scriptPath=$(cd `dirname $0`; pwd)
#工程根目录 需要替换成自己本机的工程根目录
workRoot=${scriptPath}/work 

#时间
buildTime=`date "+%d%s"`

configDir=${scriptPath}/BBL_Game_Config

#产品输出目录
#outPutDir=${scriptPath}/out

deployDir="/Volumes/jxshare/deploy/game/release"

# CODE_SIGN_IDENTITY="iPhone Distribution: ALBARINA"

# PROVISIONING_PROFILE_NAME="wf-test"
# IOS_BOUND_ID="com.id.org.test"

#更新config文件



mkdir -p ${payloadPath} ${buildPath}

cp -r ${appFileFullPath} ${payloadPath}

zip -q -r ${ipaName} Payload
  


      # git push
       # echo ${app} commit===成功
        #上传deployGate
        # mv ${outPutDir}/${app}/${targetName}.ipa    ${outPutDir}/${ipaName}
        # rm -rf ${outPutDir}/${app}
        # dg deploy ${outPutDir}/${ipaName}
        if [ -d $deployDir ]; then
          mkdir -p $deployDir/${app}
          cp -rf ${outPutDir}/${ipaName} $deployDir/${app}/${ipaName}
           if [ $? -eq 0 ];then
              echo $deployDir/${app}/${ipaName} '上传服务器成功'
           else
             echo '上传服务器失败'  
             exit -1;
           fi
        fi

done

