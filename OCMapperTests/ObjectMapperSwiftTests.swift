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
        let date = NSDate().dateByAddingTimeInterval(-5555)
        
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
        ]
        
        let customer = objectMapper.objectFromSource(dictionary, toInstanceOfClass: Customer.self) as! Customer
        
        XCTAssertTrue(customer.firstName == "Aryan", "FAIL")
        XCTAssertTrue(customer.age == 28, "FAIL")
        XCTAssertTrue(customer.dateOfBirth == date, "FAIL")
        
        XCTAssertNotNil(customer.location, "FAIL")
        XCTAssertTrue(customer.location!.name == "SF", "FAIL")

        XCTAssertNotNil(customer.billing, "FAIL")
        XCTAssertTrue(customer.billing!.name == "SD", "FAIL")
        
        let purchases = customer.valueForKey("purchases") as! NSArray
        
         // Can't access calues directly in unit test target, swift throws exception because it doesn't know which target the models belong to, main target or unit test target. This won't be an issue outside of test environment
        XCTAssertTrue(purchases.count == 3, "FAIL")
        XCTAssertTrue(purchases[0].valueForKey("summary") as! String == "bla 1", "FAIL")
        XCTAssertTrue(purchases[0].valueForKey("price") as! NSNumber == 123.4, "FAIL")
        XCTAssertTrue(purchases[1].valueForKey("summary") as! String == "bla 2", "FAIL")
        XCTAssertTrue(purchases[1].valueForKey("price") as! NSNumber == 55, "FAIL")
        XCTAssertTrue(purchases[2].valueForKey("summary") as! String == "bla 3", "FAIL")
        XCTAssertTrue(purchases[2].valueForKey("price") as! NSNumber == 99.99, "FAIL")
    }
    
}
