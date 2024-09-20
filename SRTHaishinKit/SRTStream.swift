import AVFoundation
import Foundation
import HaishinKit194
import libsrt

/// An object that provides the interface to control a one-way channel over a SRTConnection.
public final class SRTStream: IOStream {
    private var name: String?
    private var action: (() -> Void)?
    private var keyValueObservations: [NSKeyValueObservation] = []
    private weak var connection: SRTConnection?
    private lazy var muxer: SRTMuxer = {
        SRTMuxer(self)
    }()

    /// Creates a new stream object.
    public init(connection: SRTConnection) {
        super.init()
        self.connection = connection
        self.connection?.streams.append(self)
        let keyValueObservation = connection.observe(\.connected, options: [.new, .old]) { [weak self] _, _ in
            guard let self = self else {
                return
            }
            if connection.connected {
                self.action?()
                self.action = nil
            } else {
                self.readyState = .open
            }
        }
        keyValueObservations.append(keyValueObservation)
    }

    deinit {
        connection = nil
        keyValueObservations.removeAll()
    }

    /// Sends streaming audio, vidoe and data message from client.
    public func publish(_ name: String? = "") {
        lockQueue.async {
            guard let name else {
                switch self.readyState {
                case .publish, .publishing:
                    self.readyState = .open
                default:
                    break
                }
                return
            }
            if self.connection?.connected == true {
                self.readyState = .publish
            } else {
                self.action = { [weak self] in self?.publish(name) }
            }
        }
    }

    /// Playback streaming audio and video message from server.
    public func play(_ name: String? = "") {
        lockQueue.async {
            guard let name else {
                switch self.readyState {
                case .play, .playing:
                    self.readyState = .open
                default:
                    break
                }
                return
            }
            if self.connection?.connected == true {
                self.readyState = .play
            } else {
                self.action = { [weak self] in self?.play(name) }
            }
        }
    }

    /// Stops playing or publishing and makes available other uses.
    public func close() {
        lockQueue.async {
            if self.readyState == .closed || self.readyState == .initialized {
                return
            }
            self.readyState = .closed
        }
    }

    override public func readyStateDidChange(to readyState: IOStream.ReadyState) {
        super.readyStateDidChange(to: readyState)
        switch readyState {
        case .play:
            connection?.socket?.doInput()
            self.readyState = .playing
        case .publish:
            muxer.expectedMedias.removeAll()
            if !videoInputFormats.isEmpty {
                muxer.expectedMedias.insert(.video)
            }
            if !audioInputFormats.isEmpty {
                muxer.expectedMedias.insert(.audio)
            }
            self.readyState = .publishing(muxer: muxer)
        default:
            break
        }
    }

    func doInput(_ data: Data) {
        muxer.read(data)
    }

    func doOutput(_ data: Data) {
        connection?.socket?.doOutput(data: data)
    }
}
