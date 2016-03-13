//
//  Tcp.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


/**
 Libuv Tcp bindings and allow the user to use a closure on event.
 */
public class Tcp : Stream {
    
    public let tcpHandle : uv_tcp_ptr
    
    public init () {
        
        self.tcpHandle = uv_tcp_ptr.alloc(1)
        
        uv_tcp_init(uv_default_loop(), self.tcpHandle)
        
        super.init(streamHandle : uv_stream_ptr(self.tcpHandle))
    }
    
    deinit {
        if isAlive {
            Handle.close(self.handle)
            self.tcpHandle.dealloc(1)
            isAlive = false
        }
    }
    
}



// Tcp static functions.

extension Tcp {
    
    
    public static func open (handle : uv_tcp_ptr, fd : uv_os_fd_t) {
        
        // Sets socket fd to non-block.
        uv_tcp_open(handle, fd)
    }
    
    
    public static func bind(handle : uv_tcp_ptr, address: String, port: Int32) -> Int32? {
        var sockaddr = sockaddr_in()
        
        let status = withUnsafeMutablePointer(&sockaddr) { (ptr) -> Int32 in
            
            var error = uv_ip4_addr(address, port, ptr)
            
            if error == 0 {
                error = uv_tcp_bind(handle , UnsafePointer(ptr), 0)
            }
            
            return error
        }
        
        if status != 0 {
            LibuvError.printState("Tcp.bind", error : status)
            return nil
        }
        
        return status
    }
    
    
    public static func bind6(handle : uv_tcp_ptr, address: String, port: Int32) -> Int32? {
        var sockaddr = sockaddr_in6()
        
        let status = withUnsafeMutablePointer(&sockaddr) { (ptr) -> Int32 in
            var error = uv_ip6_addr(address, port, ptr)
            
            if error == 0{
                error = uv_tcp_bind(handle , UnsafePointer(ptr), 0)
            }
            
            return error
        }
        
        if status != 0 {
            LibuvError.printState("Tcp.bind6", error : status)
            return nil
        }
        
        return status
    }
    
    
    public static func listen(handle : uv_tcp_ptr, backlog : Int32 = 50) -> Int32? {
        
//        Set onConnection event from other thread in thread pool. Not stable yet.
//        let error = uv_listen(uv_stream_ptr(handle), backlog, Work.onConnection)
        
        let error = uv_listen(uv_stream_ptr(handle), backlog, Tcp.onConnection)
        
        if error != 0 {
            LibuvError.printState("Tcp.listen", error : error)
            return nil
        }
        
        Loop.run(mode: UV_RUN_DEFAULT)
        
        return error
    }
    
    
    public static func connect(handle : uv_tcp_ptr) -> Int32? {
        let request = uv_connect_ptr.alloc(1)
        let address = Tcp.getSocketName(handle)
        let error = uv_tcp_connect(request, handle, address, Tcp.afterConnect)
        
        if error != 0 {
            LibuvError.printState("Tcp.connect", error : error)
            return nil
        }
        
        return error
    }
    
    
    //  Enable / disable Nagle’s algorithm.
    public static func setNoDelay (handle : uv_tcp_ptr, enable : Int32) {
        
        uv_tcp_nodelay(handle, enable)
    }
    
    
    public static func setKeepAlive (handle : uv_tcp_ptr, enable : Int32, delay : UInt32) {
        
        uv_tcp_keepalive(handle, enable, delay)
    }
    
    
    public static func setSimultaneousAccepts (handle : uv_tcp_ptr, enable : Int32) {
        
        uv_tcp_simultaneous_accepts(handle, enable)
    }
    
    
    // Should add dealloc module on return value sockaddr_ptr.
    // Temporary it is dealloced 
    
    public static func getSocketName(handle : uv_tcp_ptr) -> sockaddr_ptr {
        
        var len = Int32(sizeof(sockaddr))
        let name = sockaddr_ptr.alloc(Int(len))
        
        uv_tcp_getsockname(handle, name, &len)
        
        return name
    }
    
    public static func getPeerName(handle : uv_tcp_ptr) -> sockaddr_ptr {
        
        var len = Int32(sizeof(sockaddr))
        let name = sockaddr_ptr.alloc(Int(len))
        
        uv_tcp_getpeername(handle, name, &len)
        
        return name
    }
    
}


// Tcp static callbacks.

extension Tcp {
    
    public static var onConnection : uv_connection_cb = { (handle, status) in
        
        var client = Tcp()
        
        if uv_accept(handle, client.streamHandle) != 0 {
            return
        }
        
        if let wrap = Handle.dictionary[uv_handle_ptr(handle)] {
            if let callback =  wrap.event.onConnection {
                callback(client.streamHandle)
            }
        }
        
        client.readStart()
    }
    
    public static var afterConnect : uv_connect_cb = { (request, status) in
        
    }
}
