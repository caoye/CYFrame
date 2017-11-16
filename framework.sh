#!/bin/sh

# 需自己配置（project名字）
FRAMEWORK_NAME="CYFrame"
SUB_FRAMEWORK_NAME="OOO"
# 邮件title
email_title="客户端SDK更新"
# 邮件内容
email_content="更新了SDK，谢谢!"
# 接受者邮箱
email_reciver=caoye@gomeplus.com
# 发送者邮箱
email_sender=caoye@gomeplus.com
# 邮箱用户名
email_username=caoye
# 邮箱密码
email_password=123..gome
# smtp服务器地址
email_smtphost=mail.gomeplus.com

#
##################################################################
target_Name=${FRAMEWORK_NAME}
xcodebuild -target ${target_Name} clean

# 工程文件夹
PROJECT_DIR=${SRCROOT}
# 系统生成的默认文件
SYSTEM_DIR=build

DIR_NAME=MergedFramework
# 最终文件夹
MERGED_DIR=${SRCROOT}/${DIR_NAME}/${FRAMEWORK_NAME}.framework

# 真机framework地址
DEVICE_DIR=${SRCROOT}/Release-iphoneos/${FRAMEWORK_NAME}.framework
# 模拟器framework地址
SIMULATOR_DIR=${SRCROOT}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework
# 构建真机framework
xcodebuild -configuration "Release" -target "${SUB_FRAMEWORK_NAME}" -target "${FRAMEWORK_NAME}" -sdk iphoneos clean build
# 构建模拟器framework
xcodebuild -configuration "Release" -target "${SUB_FRAMEWORK_NAME}" -target "${FRAMEWORK_NAME}" -sdk iphonesimulator clean build

# 如果存在MERGED_DIR，删除
if [ -d ./${MERGED_DIR} ];then
rm -rf ./${MERGED_DIR}
fi

mkdir -p ./${MERGED_DIR}

# 复制真机包到自定义目录
cp -R "./${SYSTEM_DIR}${DEVICE_DIR}/" ".${PROJECT_DIR}${MERGED_DIR}/"

# framework中.a包合并
lipo -create "./${SYSTEM_DIR}${DEVICE_DIR}/${FRAMEWORK_NAME}" "./${SYSTEM_DIR}/${SIMULATOR_DIR}/${FRAMEWORK_NAME}" -output ".${PROJECT_DIR}${MERGED_DIR}/${FRAMEWORK_NAME}"

rm -r ./${SYSTEM_DIR}

# 发邮件前删除之前的zip
if [ -d ./ ];then
rm -rf ./${DIR_NAME}.zip
fi

# 打zip压缩包
zip -r ${DIR_NAME}.zip .${MERGED_DIR}

# 邮件附件
file1_path=${DIR_NAME}.zip

# 邮件发送
./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -a ${file1_path} -o message-charset=utf-8 -o message-file=${file1_path}

# 删除zip包
if [ -d ./ ];then
rm -rf ./${DIR_NAME}.zip
fi

# 输出framework架构
echo "\033[31m *********Architecture******** \033[0m"
lipo -info ".${PROJECT_DIR}${MERGED_DIR}/${FRAMEWORK_NAME}"
echo "\033[31m *********Architecture******** \033[0m"


# 打开文件
open ".${MERGED_DIR}"




