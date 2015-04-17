import UIKit
import AVFoundation
import MediaPlayer
protocol McAVAudioPlayerDelegate: NSObjectProtocol{
    func McAVAudioPlayerBeiginLoadVoice()
    func McAVAudioPlayerBeiginPlay()
    func McAVAudioPlayerDidFinishPlay()
}
class McAVAudioPlayer: NSObject, AVAudioPlayerDelegate{
    var delegate:McAVAudioPlayerDelegate?
    var player: AVAudioPlayer?
//    var player:MPMoviePlayerController?
    class var sharedInstance: McAVAudioPlayer {//单例模式的使用
        struct Singleton {
            static let instance = McAVAudioPlayer()
        }
        return Singleton.instance
    }
    
    func playSongWithString(songUrl:NSString){//播放网络音频文件
        println("playSongWithString-----sss--------->>")
        dispatch_async(dispatch_queue_create("dfsfe", nil), { () -> Void in
            self.delegate?.McAVAudioPlayerBeiginLoadVoice()
            var data = NSData(contentsOfURL: NSURL(string: songUrl as String)!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.player != nil{
                    self.delegate?.McAVAudioPlayerDidFinishPlay()
                    self.player!.stop()
                    self.player!.delegate = nil
                    self.player = nil
                }
                NSNotificationCenter.defaultCenter().postNotificationName("VoicePlayHasInterrupt", object: nil)
                var playerError: NSError?
                self.player = AVAudioPlayer(data: data, error: &playerError)
                self.player!.volume = 1.0
                if self.player == nil{
                    println("Error creating player: \(playerError?.description)")
                }else{
                    AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
                    self.player!.delegate = self
                    self.player!.play()
                    self.delegate?.McAVAudioPlayerBeiginPlay()
                }
            })
        })
    }
    
    func playSongWithUrl(songUrl:NSURL){//播放本地沙盒的音频文件
        println("playSongWithURL-----sss--------->>")
        dispatch_async(dispatch_queue_create("dfsfe", nil), { () -> Void in
            self.delegate?.McAVAudioPlayerBeiginLoadVoice()
            if let data = NSData(contentsOfFile: songUrl.path!){
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.player != nil{
                        self.delegate?.McAVAudioPlayerDidFinishPlay()
                        self.player!.stop()
                        self.player!.delegate = nil
                        self.player = nil
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("VoicePlayHasInterrupt", object: nil)
                    var playerError: NSError?
                    self.player = AVAudioPlayer(data: data, error: &playerError)
                    self.player!.volume = 1.0
                    if self.player == nil{
                        println("Error creating player: \(playerError?.description)")
                    }else{
                        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
                        self.player!.delegate = self
                        self.player!.play()
                        self.delegate?.McAVAudioPlayerBeiginPlay()
                    }
                })
            }else{
                println("当前音频文件不存在....")
            }
        })
    }

//
    func playSongWithData(songData:NSData){
        println("playSongWithData------->>>")

        if self.player != nil{
            self.player!.stop()
            self.player!.delegate = nil
            self.player = nil
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("VoicePlayHasInterrupt", object: nil)
        var playerError: NSError?
        self.player = AVAudioPlayer(data: songData, error: &playerError)
        self.player!.volume = 1.0
        if self.player == nil{
            println("Error creating player: \(playerError?.description)")
        }else{
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
            self.player!.delegate = self
            self.player!.play()
            self.delegate?.McAVAudioPlayerBeiginPlay()
        }
    }

    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        self.delegate?.McAVAudioPlayerDidFinishPlay()
    }
    
    func stopSound(){
    }
}
