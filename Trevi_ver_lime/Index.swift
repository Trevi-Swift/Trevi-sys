//
//  Index.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 2..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
public class Index : RouteAble{
    
    public override init() {
        super.init()

        
    }
    public override func prepare() {
        let index = trevi.trevi(self)
        index.get("/hi") { req ,res in
            print("index.hi")
            return true
        }
        index.get("/hi123") { req ,res in
            print("index.hi")
            return true
        }
        index.get("/end",End())
    }
}