# MCSwiftChat
swift语言搭建聊天界面

注: 本项目素材以及部分灵感来自oc版聊天界面----https://github.com/ZhipingYang/UUChatTableView/

版本: swift1.2  
      Xcode6.3
      
实现文字,图片,语音消息的发送和显示

关于MCSwiftChat使用简介:

1.Lame文件夹下为音频转码为MP3格式的静态库和头文件,使用时需要打开swift调用oc的桥文件.

2.创建新消息记录时需要传入与setMessageWithDic(dic: NSDictionary)方法里有相应字段的dic.

3.聊天界面为McChatTableView继承UITableView.

4.发送一条新的消息时调用McChatTableView中的sendMessage(mcMessage)方法.


        
