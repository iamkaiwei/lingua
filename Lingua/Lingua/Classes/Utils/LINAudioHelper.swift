//
//  LINAudioHelper.swift
//  Lingua
//
//  Created by Hoang Ta on 8/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

protocol LINAudioHelperRecorderDelegate {
    func audioHelperDidComposeVoice(voice: NSData)
}

protocol LINAudioHelperPlayerDelegate {
    func audioHelperDidFinishPlaying()
}

class LINAudioHelper: NSObject {
    
    private let recorder: AVAudioRecorder
    private var player: AVAudioPlayer?
    var recorderDelegate: LINAudioHelperRecorderDelegate?
    var playerDelegate: LINAudioHelperPlayerDelegate?

    class var sharedInstance: LINAudioHelper {
    struct Static {
        static let instance: LINAudioHelper = LINAudioHelper()
        }
        return Static.instance
    }
    
    override init() {
        let settings = [AVFormatIDKey: NSNumber.numberWithInteger(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: NSNumber.numberWithFloat(44100.0),
                        AVNumberOfChannelsKey: NSNumber.numberWithInt(2)];
        var error: NSError?
        let pathComponents: [AnyObject] = [NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!, "TempAudioFile.caf"]
        recorder = AVAudioRecorder(URL: NSURL.fileURLWithPathComponents(pathComponents), settings: settings, error: &error)
        if error != nil {
            println(error)
        }
        super.init()
        recorder.meteringEnabled = true
        recorder.delegate = self
        recorder.prepareToRecord()
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        if error != nil {
            println(error)
        }
    }

    func startRecording() {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            AudioServicesPlaySystemSound(UInt32(kSystemSoundID_Vibrate))
            let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC))
            dispatch_after(delay, dispatch_get_main_queue(), {
                AVAudioSession.sharedInstance().setActive(true, error: nil)
                self.recorder.record()
            })
        })
    }

    func stopRecording() {
        recorder.stop()
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }

    func isRecording() -> Bool {
        return recorder.recording
    }

    func startPlaying(data: NSData) {
        var error: NSError?
        player = AVAudioPlayer(data: data, error: &error)
        player?.delegate = self
        player?.volume = 1
        if error != nil {
            println(error)
        }
        else {
            player?.play()
        }
    }

    func stopPlaying() {
        player?.stop()
        playerDelegate?.audioHelperDidFinishPlaying()
    }

    func isPlaying() -> Bool {
        return player?.playing ?? false
    }

    func getDurationFromData(data: NSData) -> NSTimeInterval {
        var error: NSError?
        player = AVAudioPlayer(data: data, error: &error)
        if error != nil {
            println(error)
            return 0
        }
        return player?.duration ?? 0
    }
}

extension LINAudioHelper: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if !flag {
            return
        }
        
        var error: NSError?
        let voiceData = NSData(contentsOfURL: recorder.url, options: .DataReadingMappedIfSafe, error: &error)
        if error != nil {
            println(error)
            return
        }
        
        recorderDelegate?.audioHelperDidComposeVoice(voiceData)
    }

    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println(error)
    }
}

extension LINAudioHelper: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        playerDelegate?.audioHelperDidFinishPlaying()
    }

    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println(error)
    }
}


