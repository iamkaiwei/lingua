//
//  LINAudioHelper.swift
//  Lingua
//
//  Created by Hoang Ta on 8/21/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation
import AVFoundation

class LINAudioHelper: NSObject {
    
    private let recorder: AVAudioRecorder
    private var player: AVAudioPlayer?

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
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        recorder.record()
    }

    func stopRecording() {
        recorder.stop()
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }

    func startPlaying(data: NSData) {
        var error: NSError?
        player = AVAudioPlayer(data: data, error: &error)
        if error != nil {
            println(error)
        }
        else {
            player?.play()
        }
    }
}

extension LINAudioHelper: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {

    }

    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println(error)
    }
}