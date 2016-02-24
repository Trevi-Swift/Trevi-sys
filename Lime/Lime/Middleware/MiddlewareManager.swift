//
//  MiddlewareManager.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
public class MiddlewareManager {

    public var enabledMiddlwareList = [ Any ] ()

    public class func sharedInstance () -> MiddlewareManager {
        dispatch_once ( &StaticInstance.dispatchToken ) {
            StaticInstance.instance = MiddlewareManager ()
        }
        return StaticInstance.instance!
    }

    struct StaticInstance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance:      MiddlewareManager?
    }

    private init () {

    }

    /**
     *
     * Handling request and operate middleware stacked in(at?) list
     * if matched suitable module or middleware, that should return false to stop operate next thing
     *
     *
     * @param {Request} request
     * @param {Response} response
     * @public
     */
    public func handleRequest ( request: Request, _ response: Response ) {
        let containerRoute = Route ()
        for middleware in enabledMiddlwareList {
            let isNextMd = matchType ( middleware, params: MiddlewareParams ( request, response, containerRoute ) )
            if isNextMd == true {
                return
            }
        }
    }
    
    /**
     *
     * Operate after matching type of module
     *
     *
     * @param {Any | Middleware | CallBack} obj
     * @param {MiddlewareParams} params
     * @public
     */
    private func matchType ( obj: Any, params: MiddlewareParams ) -> Bool {
        
        
        var ret: Bool = false;
        switch obj {
        case let mw as Middleware:
            ret = mw.operateCommand ( params )
//        case let cb as HttpCallback:
//            ret = cb ( params.req, params.res )
        default:
            break

        }
        return ret
    }

    public func appendMiddleWare ( md: Any ) {
        enabledMiddlwareList.append ( md )
    }


}