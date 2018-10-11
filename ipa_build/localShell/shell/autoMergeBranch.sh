#automerge
#先更新配置表
resourcePath=~/Desktop/workspace/TC168_Config
packConfigPath=/Users/Sam/Desktop/workspace/TC168_android_config
projectPath=~/Desktop/workspace/TC168

cd ${resourcePath}
git pull
# allAppBranch=(038 106 118 306 c6 cp12 qq 666 709 tz kb wf d8 105 933 709 998 8yi 0500 xk 01 lcw 1233 168 cp77 awcp 779 xxcp 234cp xycp)
allAppBranch=(234)
for app in ${allAppBranch[@]}
do
	sleep 1
	#切换分支 合并代码
	cd $projectPath
	
	git checkout feature/release/${app}_release

	git pull
	
	git merge develop feature/release/${app}_release -m 'autoMerge'
    
    if [ $? -eq 0 ];then    
    echo ${app}'合并成功'
    else
    echo ${app}"合并失败 退出" exit;
    fi
	
	des="./src/Page/"
    src="${resourcePath}/${app}_config/resouce"
    cp -rf $src $des

	# 替换安卓配置
	case "${app}" in
	"cp12" )
	app="12"
	;;
	"cp77" )
	app="77"
	;;
	esac

	src=$packConfigPath"/${app}/strings.xml"
	des=$projectPath"/android/app/src/main/res/values"
	cp -f $src $des
	echo "已经更换strings.xml"

	src=$packConfigPath"/${app}/build.gradle"
	des=$projectPath"/android/app"
	cp -f $src $des
	echo "已经更换build.gradle"


	src="${packConfigPath}/${app}/gradle.properties"
	des="${projectPath}/android/"
	cp -f ${src} ${des}
	echo "已经更换对应gradle.properties文件"

	src=$packConfigPath"/${app}/res/"
	des=$projectPath"/android/app/src/main/res/drawable-xxhdpi"
	cp -fr  $src $des
	echo "已经更换对应res文件"

	src=$packConfigPath"/${app}/cp${app}-release-key.keystore"
	des=$projectPath"/android/app"
	cd $des
	rmCommand="rm *.keystore"
	$rmCommand
	cp -f $src $des
	echo "已经替换签名文件"

    case "${app}" in
	"12" )
	app="cp12"
	;;
	"77" )
	app="cp77"
	;;
	esac

	#提交git
	cd $projectPath
    git add ./
    git commit -m 'autoMerge|autoReplaceResouce'
    git push
    echo ${app} '已经完成'

done

