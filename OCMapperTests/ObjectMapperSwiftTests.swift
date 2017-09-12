//
//  ObjectMapperSwiftTests.swift
//  OCMapper
//
//  Created by Aryan on 6/13/15.
//  Copyright (c) 2015 Aryan Ghassemi. All rights reserved.
//

import XCTest

class ObjectMapperSwiftTests : XCTestCase {
    
    private var objectMapper: ObjectMapper!
    private var mappingProvider: InCodeMappingProvider!
    
    // MARK: - Setup & tearDown -
    
    override func setUp() {
        super.setUp()
        
        mappingProvider = InCodeMappingProvider()
        objectMapper = ObjectMapper()
        objectMapper.mappingProvider = mappingProvider
    }
    
    override func tearDown() {
        super.setUp()
        
        objectMapper = nil
        mappingProvider = nil
    }
    
    // MARK: - Tests -
    
    func testAutomaticMapping() {
        let date = NSDate().addingTimeInterval(-5555)
        
        let dictionary = [
            "firstName":    "Aryan",
            "age":          28,
            "dateOfBirth":  date,
            "location":     ["name": "SF"],
            "billing":      ["name": "SD"],
            "purchases":    [
                ["summary": "bla 1", "price": 123.4],
                ["summary": "bla 2", "price": 55],
                ["summary": "bla 3", "price": 99.99],
            ]
        ] as [String : Any]
        
        let customer = objectMapper.object(fromSource: dictionary, toInstanceOf: Customer.self) as! Customer
        
        XCTAssertTrue(customer.firstName == "Aryan", "FAIL")
        XCTAssertTrue(customer.age == 28, "FAIL")
        XCTAssertTrue(customer.dateOfBirth == date, "FAIL")
        
        XCTAssertNotNil(customer.location, "FAIL")
        XCTAssertTrue(customer.location!.name == "SF", "FAIL")

        XCTAssertNotNil(customer.billing, "FAIL")
        XCTAssertTrue(customer.billing!.name == "SD", "FAIL")
        
        let purchases = customer.value(forKey: "purchases") as! NSArray
        
         // Can't access calues directly in unit test target, swift throws exception because it doesn't know which target the models belong to, main target or unit test target. This won't be an issue outside of test environment
        XCTAssertTrue(purchases.count == 3, "FAIL")
        XCTAssertTrue((purchases[0] as AnyObject).value(forKey: "summary") as! String == "bla 1", "FAIL")
        XCTAssertTrue((purchases[0] as AnyObject).value(forKey: "price") as! NSNumber == 123.4, "FAIL")
        XCTAssertTrue((purchases[1] as AnyObject).value(forKey: "summary") as! String == "bla 2", "FAIL")
        XCTAssertTrue((purchases[1] as AnyObject).value(forKey: "price") as! NSNumber == 55, "FAIL")
        XCTAssertTrue((purchases[2] as AnyObject).value(forKey: "summary") as! String == "bla 3", "FAIL")
        XCTAssertTrue((purchases[2] as AnyObject).value(forKey: "price") as! NSNumber == 99.99, "FAIL")
    }
    
    func testManualMapping() {
        mappingProvider.map(fromDictionaryKey: "fName", toPropertyKey: "firstName", for: Customer.self)
        mappingProvider.map(fromDictionaryKey: "ageee", toPropertyKey: "age", for: Customer.self)
        mappingProvider.map(fromDictionaryKey: "dob", toPropertyKey: "dateOfBirth", for: Customer.self)
        mappingProvider.map(fromDictionaryKey: "address", toPropertyKey: "location", withObjectType: Location.self, for: Customer.self)
        mappingProvider.map(fromDictionaryKey: "billing-address", toPropertyKey: "billing", withObjectType: Location.self, for: Customer.self)
        mappingProvider.map(fromDictionaryKey: "orders", toPropertyKey: "purchases", withObjectType: Purchase.self, for: Customer.self)
        
        let date = NSDate().addingTimeInterval(-5555)
        
        let dictionary = [
            "fName":            "Aryan",
            "ageee":            28,
            "dob":              date,
            "address":          ["name":  "SF"],
            "billing-address":  ["name":  "SD"],
			"status":			["value": "banned"],
            "orders":           [
                ["summary": "bla 1", "price": 123.4],
                ["summary": "bla 2", "price": 55],
                ["summary": "bla 3", "price": 99.99],
            ]
        ] as [String : Any]
        
        let customer = objectMapper.object(fromSource: dictionary, toInstanceOf: Customer.self) as! Customer
        
        XCTAssertTrue(customer.firstName == "Aryan", "FAIL")
        XCTAssertTrue(customer.age == 28, "FAIL")
        XCTAssertTrue(customer.dateOfBirth == date, "FAIL")
        
        XCTAssertNotNil(customer.location, "FAIL")
        XCTAssertTrue(customer.location!.name == "SF", "FAIL")
        
        XCTAssertNotNil(customer.billing, "FAIL")
        XCTAssertTrue(customer.billing!.name == "SD", "FAIL")
		
		XCTAssertNotNil(customer.status, "FAIL")
		XCTAssertTrue(customer.status!.value == "banned", "FAIL")
		
        let purchases = customer.value(forKey: "purchases") as! NSArray
        
        // Can't access calues directly in unit test target, swift throws exception because it doesn't know which target the models belong to, main target or unit test target. This won't be an issue outside of test environment
        XCTAssertTrue(purchases.count == 3, "FAIL")
        XCTAssertTrue((purchases[0] as AnyObject).value(forKey: "summary") as! String == "bla 1", "FAIL")
        XCTAssertTrue((purchases[0] as AnyObject).value(forKey: "price") as! NSNumber == 123.4, "FAIL")
        XCTAssertTrue((purchases[1] as AnyObject).value(forKey: "summary") as! String == "bla 2", "FAIL")
        XCTAssertTrue((purchases[1] as AnyObject).value(forKey: "price") as! NSNumber == 55, "FAIL")
        XCTAssertTrue((purchases[2] as AnyObject).value(forKey: "summary") as! String == "bla 3", "FAIL")
        XCTAssertTrue((purchases[2] as AnyObject).value(forKey: "price") as! NSNumber == 99.99, "FAIL")
    }
    
}
