//
//  AcceptorReactor.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

class AcceptorReactor: NSObject, SocketDelegate, Reactor, TalkDelegate {
    
    var acceptor: Socket!
    var clients: [Socket:EventStream]
    var reactor = ReactorImpl()
    let dg = DispatchGroup()
    
    override init() {
        clients = [:]
        super.init()
        acceptor = Socket(delegate: self, delegateQueue: DispatchQueue.global())
    }
    
    /*
     * Setup the server socket: non-blocking
     */
    func accept(on port: UInt16) {
        do {
            dg.enter()
            try acceptor.accept(onPort: port)
        } catch let e {
            print(e)
        }
    }
    
    /*
     * Reactor protocol
     */
    func register(name: String, handler: EventHandler) {
        reactor.register(name: name, handler: handler)
    }
    
    func deregister(name: String) {
        reactor.deregister(name: name)
    }
    
    func dispatch(event: Event) {
        reactor.dispatch(event: event)
    }
    
    /*
     * GCDAsyncSocketDelegate callbacks
     */
    
    
    /*
     * CODE HERE: Accepting a new socket
     * 1. Create an event source
     * 2. Save the event source keyed on the socket
     * 3. Schedule a read operation
     */
    func socket(_ socket: Socket, didAcceptNewSocket newSocket: Socket) {
        print("Client connected")
        let es = JSONEventStream(socket: newSocket)
        clients[newSocket] = es
        es.get()
    }
    
    /*
     * CODE HERE: Callback for disconnection
     * 1. Remove the socket from the hashtable
     * 2. Close the socket
     */
    func socketDidDisconnect(_ sock: Socket, withError err: Error?) {
        print("Client disconnected: \(String(describing: err))")
        clients.removeValue(forKey: sock)
        sock.disconnect()
    }
    
    /*
     * CODE HERE: Deals with:
     * 1. Finding the correct event source
     * 2. Obtaining the event from the data
     * 3. Dispatching the event to the correct handler
     * 4. Scheduling another read
     */
    func socket(_ sock: Socket, didRead data: Data, withTag tag: Int) {
        let es = clients[sock]
        dispatch(event: (es?.get(data: data))!)
        es?.get()
        
    }
}
