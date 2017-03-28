//
//  AcceptorReactor.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import UIKit

class AcceptorReactor: NSObject, SocketDelegate, NetServiceDelegate, NetServiceBrowserDelegate, Reactor {
    
    var acceptor: Socket!
    var clients: [Socket:EventStream]
    var reactor = ReactorImpl()
    let dg = DispatchGroup()
    
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
    
    //Server setup
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
    
    //Client setup
    func open(host: String, port:UInt16) {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket.connect(toHost: host, onPort: port)
        }
        catch let e {
            print(e)
        }
    }
    
    //Client setup
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("netServiceBrowser - didFind - \(service.name)")
        service.delegate = self
        if !services.contains(service) && service != netService {
            services.append(service)
            service.resolve(withTimeout: 10)
        }
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("netServiceDidResolveAddress - \(sender.name)")
        MasterViewController.instance?.updateServices(services: services)
        
        //Put the next line on a button click to open a connection
        //connection.open(host: sender.hostName!, port: UInt16(sender.port))
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("netService - didNotResolve - \(sender.name)")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("netServiceBrowser - didRemove - \(service.name)")
        if let index = services.index(of: service) {
            services.remove(at: index)
        }
    }
    
    //Reactor protocol
    func register(name: String, handler: EventHandler) {
        reactor.register(name: name, handler: handler)
    }
    
    func deregister(name: String) {
        reactor.deregister(name: name)
    }
    
    func dispatch(event: Event) {
        reactor.dispatch(event: event)
    }
    
    //GCDAsyncSocketDelegate callbacks
    func socket(_ socket: Socket, didAcceptNewSocket newSocket: Socket) {
        print("Socket Created")
        let es = JSONEventStream(socket: socket)
        clients[newSocket] = es
        MasterViewController.instance?.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        print("Socket Created")
        let es = JSONEventStream(socket: socket)
        let source = MasterViewController.instance?.deviceName
        let destination = MasterViewController.instance?.opponentName
        clients[socket] = es
        Event(stream: es, fields: ["TYPE": "PLAY_GAME_REQUEST", "SOURCE": source!, "DESTINATION": destination!]).put()
    }
    
    func socketDidDisconnect(_ sock: Socket, withError err: Error?) {
        print("Client disconnected: \(String(describing: err))")
        clients.removeValue(forKey: sock)
        sock.disconnect()
    }

    func socket(_ sock: Socket, didRead data: Data, withTag tag: Int) {
        let es = clients[sock]
        dispatch(event: (es?.get(data: data))!)
        es?.get()
    }
}
