//
//  AcceptorReactor.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine (100999500) and Alexei Tipenko (100995947) on 2017-03-26.
//  Copyright © 2017 Avery Vine and Alexei Tipenko. All rights reserved.
//

import UIKit

class AcceptorReactor: NSObject, SocketDelegate, NetServiceDelegate, NetServiceBrowserDelegate, Reactor {
    
    var acceptor: Socket!
    var clients: [Socket:EventStream]
    var reactor = ReactorImpl()
    let dg = DispatchGroup()
    let strings = Strings()
    
    //Server variables
    var netService: NetService
    
    //Client variables
    var services: [NetService]
    var browser: NetServiceBrowser
    var socket: GCDAsyncSocket!
    
    
    
    init(domain: String, type: String, name: String, port: Int32) {
        //Client pre-initializer
        browser = NetServiceBrowser()
        services = []
        
        //Server pre-initializer
        netService = NetService(domain: domain, type: type, name: name, port: port)
        clients = [:]
        
        super.init()
        
        //Server post-initializer
        acceptor = Socket(delegate: self, delegateQueue: DispatchQueue.global())
        
        //Client post-initializer
        browser.delegate = self
        browser.searchForServices(ofType: type, inDomain: domain)
        browser.schedule(in: .main, forMode: .defaultRunLoopMode)
        
    }
    
    
    
    deinit {
        netService.stop()
        netService.remove(from: .main, forMode: .defaultRunLoopMode)
    }
    
    
    
    // Accepts incoming services on a provided port
    func accept(on port: UInt16) {
        do {
            dg.enter()
            try acceptor.accept(onPort: port)
            netService.delegate = self
            netService.publish()
            netService.schedule(in: .main, forMode: .defaultRunLoopMode)
            RunLoop.main.run()
        } catch let e {
            print(e)
        }
    }
    
    
    
    // Opens a socket on a provided host and port
    func open(host: String, port:UInt16) {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket.connect(toHost: host, onPort: port)
        }
        catch let e {
            print(e)
        }
    }
    
    
    
    /*
     - Description: if any sockets are connected, disconnect them and alert the person on the other end
     - Input: stream to be closed
     - Return: none
     */
    func disconnect(stream: EventStream) {
        if MasterViewController.instance?.inGame != MasterViewController.instance?.NOT_IN_GAME {
            let source = (MasterViewController.instance?.deviceName)!
            let destination = (MasterViewController.instance?.opponentName)!
            Event(stream: stream, fields: ["TYPE": "GAME_OVER", "SOURCE": source, "DESTINATION": destination, "REASON": strings.no_winner]).put()
            stream.close()
        }
    }
    
    
    
    // Runs when a new service is found
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        if !services.contains(service) && service != netService {
            services.append(service)
            service.resolve(withTimeout: 10)
        }
    }
    
    
    
    // Runs when a service's address is resolved
    func netServiceDidResolveAddress(_ sender: NetService) {
        MasterViewController.instance?.updateServices(services: services)
    }
    
    
    
    // Runs when a service's address fails to be resolved
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("netService - didNotResolve - \(sender.name)")
    }
    
    
    
    // Runs when a service is removed
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("netServiceBrowser - didRemove - \(service.name)")
        if let index = services.index(of: service) {
            services.remove(at: index)
        }
        MasterViewController.instance?.updateServices(services: services)
    }
    
    
    
    func register(name: String, handler: EventHandler) {
        reactor.register(name: name, handler: handler)
    }
    
    
    
    func deregister(name: String) {
        reactor.deregister(name: name)
    }
    
    
    
    func dispatch(event: Event) {
        reactor.dispatch(event: event)
    }
    
    
    
    // Runs when a new socket is accepted
    func socket(_ socket: Socket, didAcceptNewSocket newSocket: Socket) {
        print("Socket Created")
        let es = JSONEventStream(socket: newSocket)
        clients[newSocket] = es
        es.get()
    }

    
    
    // Runs when a socket succeeds in connecting
    func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        print("Socket Created")
        let es = JSONEventStream(socket: socket)
        let source = MasterViewController.instance?.deviceName
        let destination = MasterViewController.instance?.opponentName
        clients[socket] = es
        Event(stream: es, fields: ["TYPE": "PLAY_GAME_REQUEST", "SOURCE": source!, "DESTINATION": destination!]).put()
        es.get()
    }
    
    
    
    // Runs when a socket disconnects
    func socketDidDisconnect(_ sock: Socket, withError err: Error?) {
        print("Client disconnected with error: \(String(describing: err))")
        clients.removeValue(forKey: sock)
        sock.disconnect()
        if MasterViewController.instance?.inGame == MasterViewController.instance?.IN_GAME {
            DetailViewController.instance?.opponentDisconnected()
        }
    }

    
    
    // Runs when a socket reads some data
    func socket(_ sock: Socket, didRead data: Data, withTag tag: Int) {
        print("Received data")
        let es = clients[sock]
        dispatch(event: (es?.get(data: data))!)
        es?.get()
    }
}
