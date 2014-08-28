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
    func audioHelperDidFailToComposeVoice(error: NSError)
}

protocol LINAudioHelperPlayerDelegate {
    func audioHelperDidFinishPlaying()
}

class LINAudioHelper: NSObject {
    
    private let recorder: AVAudioRecorder
    private var player: AVAudioPlayer
    var recorderDelegate: LINAudioHelperRecorderDelegate?
    var playerDelegate: LINAudioHelperPlayerDelegate?

    /*  Before user starts recording, the device should vibrate for approximately
        1 sec, so the audio helper delays for the same amount of time to avoid
        accidently recording the vibration sound, there may be a chance that they
        cancel recording before recorder even started but the recorder keep starting
        anyways..
    */
    private var readyToRecord = true

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
        player = AVAudioPlayer(data: nil, error: nil)
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
        readyToRecord = true
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            AudioServicesPlaySystemSound(UInt32(kSystemSoundID_Vibrate))
            let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC))
            dispatch_after(delay, dispatch_get_main_queue(), {
                if self.readyToRecord {
                    AVAudioSession.sharedInstance().setActive(true, error: nil)
                    self.recorder.record()
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey: "The record is too short."]
                    let error = NSError(domain: "Lingua", code: 0, userInfo: userInfo)
                    self.recorderDelegate?.audioHelperDidFailToComposeVoice(error)
                }
            })
        })
    }

    func stopRecording() {
        readyToRecord = false
        if recorder.recording {
            recorder.stop()
            AVAudioSession.sharedInstance().setActive(false, error: nil)
        }
    }

    func isRecording() -> Bool {
        return recorder.recording
    }

    func startPlaying(data: NSData) {
        //Stop previous channel if any.
        stopPlaying()

        var error: NSError?
        player = AVAudioPlayer(data: data, error: &error)
        player.delegate = self
        player.volume = 1
        if error != nil {
            println(error)
        }
        else {
            player.play()
        }
    }

    func stopPlaying() {
        if player.playing {
            player.stop()
            playerDelegate?.audioHelperDidFinishPlaying()
        }
    }

    func isPlaying() -> Bool {
        return player.playing ?? false
    }

    func getDurationFromData(data: NSData) -> NSTimeInterval {
        var error: NSError?
        player = AVAudioPlayer(data: data, error: &error)
        if error != nil {
            println(error)
            return 0
        }
        return player.duration
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
            recorderDelegate?.audioHelperDidFailToComposeVoice(error!)
            return
        }
        
        if getDurationFromData(voiceData) <= 1 {
            let userInfo = [NSLocalizedDescriptionKey: "The record is too short."]
            let error = NSError(domain: "Lingua", code: 0, userInfo: userInfo)
            self.recorderDelegate?.audioHelperDidFailToComposeVoice(error)
            recorderDelegate?.audioHelperDidFailToComposeVoice(error)
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


