//
//  Stream.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv
import Foundation


/**
 Libuv stream bindings and allow the user to use a closure on event.
 Also, provides improved data read, write stream modules.
 */
public class Stream : Handle {
    
    public let streamHandle : uv_stream_ptr
    
    public init (streamHandle : uv_stream_ptr){
        self.streamHandle = streamHandle
        super.init(handle: uv_handle_ptr(streamHandle))
    }
    
    deinit{
        if isAlive {
            Handle.close(self.handle)
            self.streamHandle.dealloc(1)
            isAlive = false
        }
    }
    
    
    public func readStart() {
        
//        Set onRead event from other thread in thread pool. Not stable yet.
//        uv_read_start(self.streamHandle, Stream.onAlloc, Work.onRead)
        
        uv_read_start(self.streamHandle, Stream.onAlloc, Stream.onRead)
    }
    
    
    public func doTryWrite(buffer: UnsafeMutablePointer<uv_buf_ptr>, count : UnsafeMutablePointer<UInt32>) -> Int32 {
        var error : Int32
        var written : Int32
        var vbuffer : uv_buf_ptr = buffer.memory
        var vcount : UInt32 = count.memory
        
        error = uv_try_write(self.streamHandle, vbuffer, vcount)
        
        guard  (error != UV_ENOSYS.rawValue && error != UV_EAGAIN.rawValue) else {
            return 0
        }
        guard error >= 0 else {
            return error
        }
        
        written = error
        while vcount > 0 {
            if vbuffer[0].len > Int(written) {
                vbuffer[0].base.initialize(vbuffer[0].base[Int(written)])
                vbuffer[0].len -= Int(written)
                written = 0
                break;
            }
            else {
                written -= vbuffer[0].len;
            }
            
            vbuffer = vbuffer.successor()
            vcount = vcount.predecessor()
        }
        
        buffer.memory = vbuffer;
        count.memory = vcount;
        
        return 0
    }
    
}


// Stream static functions.

extension Stream {
    
    
    public static func readStart(handle : uv_stream_ptr) {
        
//        Set onRead event from other thread in thread pool. Not stable yet.
//        uv_read_start(handle, Stream.onAlloc, Work.onRead)
        
        uv_read_start(handle, Stream.onAlloc, Stream.onRead)
    }
    
    public func readStop(handle : uv_stream_ptr) -> Int32 {
        return uv_read_stop(self.streamHandle)
    }
    
    public static func doShutDown(handle : uv_stream_ptr) -> Int32 {
        
        let request = uv_shutdown_ptr.alloc(1)
        var error : Int32
                
        error = uv_shutdown(request, handle, Stream.afterShutdown)
        
        return error
    }
    
    
    public static func doWrite(data : NSData, handle : uv_stream_ptr,
        count : UInt32 = 1, sendHandle : uv_stream_ptr! = nil) -> Int {
            
        let error : Int32
        let buffer = uv_buf_ptr.alloc(1)
        let request : write_req_ptr = write_req_ptr.alloc(1)
            
        request.memory.buffer = buffer
            
        buffer.memory = uv_buf_init(UnsafeMutablePointer<Int8>(data.bytes), UInt32(data.length))
            
        if sendHandle != nil {
            error = uv_write2(uv_write_ptr(request), handle, buffer, count, sendHandle, Stream.afterWrite)
        }
        else {
            error = uv_write(uv_write_ptr(request), handle, buffer, count, Stream.afterWrite)
        }
            
            
        if error == 0 {
            // Should add count module
            
            //
        }
        
        return 1
    }
    
    public static func isReadable (handle : uv_stream_ptr) -> Bool {

       return uv_is_readable(handle) == 1
    }
    
    public static func isWritable (handle : uv_stream_ptr) -> Bool {
        
        return uv_is_writable(handle) == 1
    }
    
    public static func setBlocking (handle : uv_stream_ptr, blocking : Int32) {
        
        uv_stream_set_blocking(handle, blocking)
    }
    
    public static func isNamedPipe (handle : uv_stream_ptr) -> Bool {
        
        return handle.memory.type == UV_NAMED_PIPE
    }
    
    public static func isNamedPipeIpc (handle : uv_stream_ptr) -> Bool {
        
        return Stream.isNamedPipe(handle) && uv_pipe_ptr(handle).memory.ipc != 0
    }
    
    public static func getHandleType (handle : uv_stream_ptr) -> uv_handle_type {
        var type : uv_handle_type = UV_UNKNOWN_HANDLE
        
        if Stream.isNamedPipe(handle) && uv_pipe_pending_count(uv_pipe_ptr(handle)) > 0 {
            type = uv_pipe_pending_type(uv_pipe_ptr(handle))
        }
        
        return type
    }
}


// Stream static callbacks.

extension Stream {
    
    public static var onAlloc : uv_alloc_cb = { (_, suggestedSize, buffer) in
        
        buffer.initialize(uv_buf_init(UnsafeMutablePointer.alloc(suggestedSize), UInt32(suggestedSize)))
    }
    
    
    public static var onRead : uv_read_cb = { (handle, nread, buffer) in
        
        if nread <= 0 {
            if Int32(nread) == UV_EOF.rawValue {
                Handle.close(uv_handle_ptr(handle))
            }
            else {
                
                LibuvError.printState("Stream.onRead", error : Int32(nread))
            }
        }
        else if let wrap = Handle.dictionary[uv_handle_ptr(handle)] {
            if let callback =  wrap.event.onRead {
                
                let data = NSData(bytesNoCopy : buffer.memory.base, length : nread)
                callback(handle, data)
            }
        }
    }
    
    
    public static var afterShutdown : uv_shutdown_cb = { (request, status) in
        
        let handle = request.memory.handle
        
        if status < 0 {
            
            LibuvError.printState("Stream.afterShutdown", error : status)
        }
        
        Handle.close(uv_handle_ptr(handle))
        request.dealloc(1)
    }
    
    
    public static var afterWrite : uv_write_cb = { (request, status) in
 
        let writeRequest = write_req_ptr(request)
        let handle = writeRequest.memory.request.handle
        let buffer  = writeRequest.memory.buffer

        if let wrap = Handle.dictionary[uv_handle_ptr(handle)] {
            if let callback =  wrap.event.onAfterWrite {
                callback(handle)
            }
        }
        
        if buffer.memory.len > 0 {
            buffer.memory.base.dealloc(buffer.memory.len)
        }
        buffer.dealloc(1)
        
        uv_cancel(uv_req_ptr(request))
        writeRequest.dealloc(1)
    }
    
}