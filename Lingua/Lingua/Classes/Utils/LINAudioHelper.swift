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
    func audioHelperDidCancelRecording()
    func audioHelperDidFailToComposeVoice(error: NSError)
}

protocol LINAudioHelperPlayerDelegate {
    func audioHelperDidUpdateProgress(progress: NSTimeInterval, duration: NSTimeInterval)
    func audioHelperDidFinishPlaying(duration: NSTimeInterval)
}

class LINAudioHelper: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private let recorder: AVAudioRecorder
    private var player: AVAudioPlayer
    var recorderDelegate: LINAudioHelperRecorderDelegate?
    var playerDelegate: LINAudioHelperPlayerDelegate?
    var currentPlayingTime: NSTimeInterval { return player.currentTime }
    
    /*  Before user starts recording, the device should vibrate for approximately
        1 sec, so the audio helper delays for the same amount of time to avoid
        accidently recording the vibration sound, there may be a chance that they
        cancel recording before recorder even started but the recorder keep starting
        anyways..
    */
    private var readyToRecord = true
    private var shouldCancelRecording = false
    private var trackingTimer: NSTimer?
    //1004 is default system sound ID
    private var messageAlertSoundID: SystemSoundID = 1004
    
    class var sharedInstance: LINAudioHelper {
    struct Static {
        static let instance: LINAudioHelper = LINAudioHelper()
        }
        return Static.instance
    }
    
    override init() {
        let settings = [AVFormatIDKey: NSNumber(integer: kAudioFormatMPEG4AAC),
                        AVSampleRateKey: NSNumber(float: 44100.0),
                        AVNumberOfChannelsKey: NSNumber(integer: 2)]
        var error: NSError?
        let pathComponents: [AnyObject] = [NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!, "TempAudioFile.caf"]
        recorder = AVAudioRecorder(URL: NSURL.fileURLWithPathComponents(pathComponents), settings: settings, error: &error)
        
        if error != nil {
            println(error)
        }
        
        //New change to xcode 6.1, AVAudioPlayer have to initialized with non-nil data.
        let soundPath = NSBundle.mainBundle().pathForResource(kLINAlertSoundFileName, ofType: kLINAlertSoundExtension)
        player = AVAudioPlayer(data: NSData(contentsOfFile: soundPath!)!, error: nil)
        
        super.init()

        recorder.meteringEnabled = true
        recorder.delegate = self
        recorder.prepareToRecord()
    }
    
    // MARK: Playing Alert sound system
    
    func playAlertSound(){
        let tempSoundPath = NSBundle.mainBundle().pathForResource(kLINAlertSoundFileName, ofType: kLINAlertSoundExtension)
        if let soundPath = tempSoundPath {
            startPlaying(NSData(contentsOfFile: soundPath)!)
        }
    }

    // MARK: Recording
    
    func startRecording() {
        //Stop player if any
        stopPlaying()
        
        readyToRecord = true
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            AudioServicesPlaySystemSound(UInt32(kSystemSoundID_Vibrate))
            let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC))
            dispatch_after(delay, dispatch_get_main_queue(), {
                if self.readyToRecord {
                    var error: NSError?
                    AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord, error: &error)
                    if error != nil {
                        println(error)
                        self.recorderDelegate?.audioHelperDidFailToComposeVoice(error!)
                        return
                    }
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

    func finishRecording() {
        readyToRecord = false
        if recorder.recording {
            recorder.stop()
            AVAudioSession.sharedInstance().setActive(false, error: nil)
        }
    }

    func cancelRecording() {
        readyToRecord = false
        if recorder.recording {
            shouldCancelRecording = true
            recorder.stop()
            AVAudioSession.sharedInstance().setActive(false, error: nil)
        }
    }

    func isRecording() -> Bool {
        return recorder.recording
    }

    func startPlaying(data: NSData) {
        //Stop previous channel/recorder if any.
        stopPlaying()
        cancelRecording()
        
        var error: NSError?
        player = AVAudioPlayer(data: data, error: &error)
        player.delegate = self
        player.volume = 1
        if error != nil {
            println(error)
            return
        }
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &error)
        if error != nil {
            println(error)
            return
        }
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        player.play()
        trackingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timeTick:", userInfo: nil, repeats: true)
    }

    func stopPlaying() {
        if player.playing {
            player.stop()
            trackingTimer?.invalidate()
            playerDelegate?.audioHelperDidFinishPlaying(player.duration)
            AVAudioSession.sharedInstance().setActive(false, error: nil)
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

    func timeTick(timer: NSTimer) {
        playerDelegate?.audioHelperDidUpdateProgress(player.currentTime, duration: player.duration)
    }
    
    // MARK: AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if !flag {
            return
        }

        if shouldCancelRecording {
            shouldCancelRecording = false
            self.recorderDelegate?.audioHelperDidCancelRecording()
            return
        }
        
        var error: NSError?
        let voiceData = NSData(contentsOfURL: recorder.url, options: .DataReadingMappedIfSafe, error: &error)
        if error != nil {
            println(error)
            recorderDelegate?.audioHelperDidFailToComposeVoice(error!)
            return
        }
        
        if getDurationFromData(voiceData!) <= 1 {
            let userInfo = [NSLocalizedDescriptionKey: "The record is too short."]
            let error = NSError(domain: "Lingua", code: 0, userInfo: userInfo)
            self.recorderDelegate?.audioHelperDidFailToComposeVoice(error)
            recorderDelegate?.audioHelperDidFailToComposeVoice(error)
            return
        }

        recorderDelegate?.audioHelperDidComposeVoice(voiceData!)
    }

    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println(error)
    }

    // MARK: AVAudioRecorderDelegate

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        trackingTimer?.invalidate()
        playerDelegate?.audioHelperDidFinishPlaying(player.duration)
    }

    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println(error)
    }
}


