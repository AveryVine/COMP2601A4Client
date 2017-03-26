//
//  ServiceManager.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServiceManager: NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    var serviceBrowser: MCNearbyServiceBrowser
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    var session: MCSession
    var peers: [MCPeerID]
    var delegate: TalkDelegate!
    
    
    init(peerID: MCPeerID, type: String) {
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: type)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: type)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        peers = []
        super.init()
        session.delegate = self
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    deinit {
        session.disconnect()
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func stop() {
        session.disconnect()
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    /*
     * MCNearbyServiceBrowserDelegate code
     */
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost connectivity to \(peerID.displayName)")
        let index = peers.index(of: peerID)
        peers.remove(at: index!)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Did not start browsing for peers")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found a peer: \(peerID.displayName) with: \(info)")
        peers.append(peerID)
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    /*
     * MCNearbyServiceAdvertiserDelegate code
     */
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Did not start advertising peer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Did receive invitation from peer: \(peerID.displayName)")
        invitationHandler(true, session)
    }
    
    /*
     * MCSessionDelegate code
     */
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state)")
        if session.connectedPeers.count > 0 {
            let data = "Hello from \(peerID.displayName)".data(using: .ascii)
            try? session.send(data!, toPeers: peers, with: .reliable)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        let msg = String(data: data, encoding: .ascii)!
        delegate.talk(msg: msg)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
    
}
