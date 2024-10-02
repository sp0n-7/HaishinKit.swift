import AVFoundation
import CoreMedia
import Foundation

protocol RTMPTimeConvertible {
    var seconds: TimeInterval { get }
}

private let kRTMPTimestamp_defaultTimeInterval: TimeInterval = 0
private let kRTMPTimestamp_compositiionTimeOffset = CMTime(value: 3, timescale: 30)

struct RTMPTimestamp<T: RTMPTimeConvertible> {
    private var startedAt = kRTMPTimestamp_defaultTimeInterval
    private var updatedAt = kRTMPTimestamp_defaultTimeInterval
    private var timedeltaFraction: TimeInterval = kRTMPTimestamp_defaultTimeInterval

    mutating func update(_ value: T) -> UInt32 {
        if startedAt == 0 {
            startedAt = value.seconds
            updatedAt = value.seconds
            return 0
        } else {
            var timedelta = (value.seconds - updatedAt) * 1000

            // Clamp timedelta to a minimum of 0 to prevent negative values
            if timedelta < 0 {
                timedelta = 0
            }

            timedeltaFraction += timedelta.truncatingRemainder(dividingBy: 1)
            if 1 <= timedeltaFraction {
                timedeltaFraction -= 1
                timedelta += 1
            }
            updatedAt = value.seconds
            return UInt32(timedelta)
        }
    }

    mutating func update(_ message: RTMPMessage, chunkType: RTMPChunkType) {
        switch chunkType {
        case .zero:
            if startedAt == 0 {
                startedAt = TimeInterval(message.timestamp) / 1000
                updatedAt = TimeInterval(message.timestamp) / 1000
            } else {
                updatedAt = TimeInterval(message.timestamp) / 1000
            }
        default:
            updatedAt += TimeInterval(message.timestamp) / 1000
        }
    }

    mutating func clear() {
        startedAt = kRTMPTimestamp_defaultTimeInterval
        updatedAt = kRTMPTimestamp_defaultTimeInterval
        timedeltaFraction = kRTMPTimestamp_defaultTimeInterval
    }

    func getCompositionTime(_ sampleBuffer: CMSampleBuffer) -> Int32 {
        guard sampleBuffer.decodeTimeStamp.isValid, sampleBuffer.decodeTimeStamp != sampleBuffer.presentationTimeStamp else {
            return 0
        }
        let compositionTime = (sampleBuffer.presentationTimeStamp + kRTMPTimestamp_compositiionTimeOffset).seconds - updatedAt
        return Int32(compositionTime * 1000)
    }
}

extension AVAudioTime: RTMPTimeConvertible {
    var seconds: TimeInterval {
        AVAudioTime.seconds(forHostTime: hostTime)
    }
}

extension RTMPTimestamp where T == AVAudioTime {
    var value: AVAudioTime {
        return AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: updatedAt))
    }
}

extension CMTime: RTMPTimeConvertible {
}

extension RTMPTimestamp where T == CMTime {
    var value: CMTime {
        return CMTime(seconds: updatedAt, preferredTimescale: 1000)
    }
}
