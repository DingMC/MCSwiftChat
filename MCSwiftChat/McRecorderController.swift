
import UIKit
import MediaPlayer
import AVFoundation

protocol McRecorderControllerDelegate: NSObjectProtocol{
    func failRecord(failedStr: String)
    func endConvertWithData(voiceURL: NSURL, fileName: String, voiceTime: Int)
}

class McRecorderController: NSObject {
    var delegate: McRecorderControllerDelegate?
    var recorder: AVAudioRecorder!
    class var sharedInstance: McRecorderController{//单例模式
        struct Singleton{
            static let instance = McRecorderController()
        }
        return Singleton.instance
    }
    var soundFileURL: NSURL!
    var recordFileName: String!
    
    func toRecord(){//进入录音接口...
        if self.recorder != nil{
            self.recorder == nil
        }
        self.recordWithPermission(true)
    }
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    func recordWithPermission(setup: Bool){//当前设备麦克风是否可用
        //ios8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    if NSUserDefaults.standardUserDefaults().objectForKey("firstRecoder") == nil{
                        println("isfirst")
                        NSUserDefaults.standardUserDefaults().setObject("111", forKey: "firstRecoder")
                    }else{
                        println("Permission to record granted")
                        self.setSessionPlayAndRecord()
                        self.setupRecorder()
                        self.recorder.record()//开始录音------------
                    }
                } else {
                    println("Permission to record not granted")
                    var alertView = UIAlertView(title: "提示", message: "当前无法访问您的麦克风，请检查设置", delegate: self, cancelButtonTitle: "好")
                    alertView.show()
                }
            })
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayAndRecord() {
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    var docsDir: AnyObject?
    func setupRecorder() {//设置录音文件的存储路径
        let imgVSize:CGFloat = 40.0
        var format = NSDateFormatter()
        format.dateFormat="yyyyMMddHHmmss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate()))"
        recordFileName = currentFileName
        println(currentFileName)
        docsDir = dirPaths[0]
        var soundFilePath = docsDir!.stringByAppendingPathComponent(currentFileName)
        
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            println("sound exists")
        }
        
        var recordSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM,//kAudioFormatAppleLossless,
            //            AVEncoderAudioQualityKey : AVAudioQuality.Max.toRaw(),
            //            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 11025.0,//44100.0
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue
        ]
        var error: NSError?
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings as [NSObject : AnyObject], error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }
    
    func audio_PCMtoMP3(){//将当前录音文件转成MP3格式...
        var curFileURL = self.soundFileURL!
        var mp3FileName = self.soundFileURL!.lastPathComponent
        mp3FileName = mp3FileName!.stringByAppendingString(".mp3")
        var mp3FilePath = self.docsDir!.stringByAppendingPathComponent(mp3FileName!)
        
        var read = Int()
        var write = Int()
        var pcm = fopen(self.soundFileURL!.path!, "rb")
        fseek(pcm, 4*1024, SEEK_CUR)
        var mp3 = fopen(mp3FilePath, "wb")
        
        let PCM_SIZE:Int = 8192
        let MP3_SIZE:Int = 8192
        var pcm_buffer = UnsafeMutablePointer<Int16>.alloc(PCM_SIZE*2)
        var mp3_buffer = UnsafeMutablePointer<UInt8>.alloc(MP3_SIZE)
        
        var lame:lame_t = lame_init()
        lame_set_in_samplerate(lame, 11025)
        lame_set_VBR(lame, vbr_default)
        lame_init_params(lame)
        do {
            read = Int(fread(pcm_buffer, Int(2 * sizeof(Int16)), Int(PCM_SIZE), pcm))
            if read == 0{
                write = Int(lame_encode_flush(lame, mp3_buffer, Int32(MP3_SIZE)))
            }else{
                write = Int(lame_encode_buffer_interleaved(lame, pcm_buffer, Int32(read), mp3_buffer, Int32(MP3_SIZE)))
            }
            fwrite(mp3_buffer, Int(write), 1, mp3)
        }while(read != 0)
        lame_close(lame)
        fclose(mp3)
        fclose(pcm)
        self.soundFileURL = NSURL(string: mp3FilePath)
        self.delegate?.endConvertWithData(self.soundFileURL, fileName: mp3FileName!, voiceTime: voiceTime)
        self.deleteCurRecording(curFileURL.path!)
    }
    
    var voiceTime = 0
    func stopRecord() {//停止录音
        println("stop")
        if recorder != nil{
            var cTime = self.recorder!.currentTime
            recorder.stop()
            recorder = nil
            if cTime >= 1{//判断录音时间是否大于1秒...
                let session:AVAudioSession = AVAudioSession.sharedInstance()
                var error: NSError?
                if !session.setActive(false, error: &error) {
                    println("could not make session inactive")
                    if let e = error {
                        println(e.localizedDescription)
                        return
                    }
                }
                self.voiceTime = Int(cTime)
                self.audio_PCMtoMP3()
            }else{
                self.deleteCurRecording(self.soundFileURL!.path!)
                self.delegate?.failRecord("太短啦")
            }
        }
    }
    func cancelRecord() {//取消录音
        if recorder != nil {
            recorder.stop()
            recorder = nil
            self.deleteCurRecording(self.soundFileURL!.path!)
        }
    }
    
    func deleteCurRecording(curPath: String){
        var docsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var fileManager = NSFileManager.defaultManager()
        var error: NSError?
        var files = fileManager.contentsOfDirectoryAtPath(docsDir, error: &error) as! [String]
        if let e = error {
            println(e.localizedDescription)
        }
        
        println("removing \(curPath)")
        if !fileManager.removeItemAtPath(curPath, error: &error) {
            NSLog("could not remove \(curPath)")
        }
        if let e = error {
            println(e.localizedDescription)
        }
    }
    
    func deleteAllRecordings() {//--删除所有录音文件
        var docsDir =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var fileManager = NSFileManager.defaultManager()
        var error: NSError?
        var files = fileManager.contentsOfDirectoryAtPath(docsDir, error: &error) as! [String]
        if let e = error {
            println(e.localizedDescription)
        }
        var recordings = files.filter( { (name: String) -> Bool in
            return name.hasPrefix("recording-")//name.hasSuffix("mp3")
        })
        for var i = 0; i < recordings.count; i++ {
            var path = docsDir + "/" + recordings[i]
            
            println("removing \(path)")
            if !fileManager.removeItemAtPath(path, error: &error) {
                NSLog("could not remove \(path)")
            }
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
}
