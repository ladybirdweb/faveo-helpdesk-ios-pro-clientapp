//
//  Search.m
//  Faveo Helpdesk Client AppUITests
//
//  Created by Mallikarjun on 12/02/19.
//  Copyright © 2019 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Search : XCTestCase

@end

@implementation Search

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSearchTicket {
   
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [[[app.navigationBars[@"Open Tickets"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1] tap];
    XCUIElement *searchTextField = app.textFields[@"search here..."];
    [searchTextField tap];
    XCTAssertTrue(searchTextField.exists);
    
    [searchTextField typeText:@"payment"];
    
    XCUIElement *searchButton = app.buttons[@"Search"];
    [searchButton tap];
    XCTAssertTrue(searchButton.exists);
}

@end
