//
//  SwiftUser.swift
//  OCMapper
//
//  Created by Aryan on 6/13/15.
//  Copyright (c) 2015 Aryan Ghassemi. All rights reserved.
//

import Foundation

public class Customer: NSObject {
    
    public var firstName: String?
    public var age: NSNumber?
    public var dateOfBirth: NSDate?
    public var location: Location?
    public var billing: Location?
    public var home: Location?
    public var purchases: [Purchase]?
    
}
