//
//  TicketDetailsTicketStatisChange.m
//  Faveo Helpdesk Client AppUITests
//
//  Created by Mallikarjun on 12/02/19.
//  Copyright © 2019 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TicketDetailsTicketStatisChange : XCTestCase

@end

@implementation TicketDetailsTicketStatisChange

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

- (void)testTicktDetailsCheckStatus {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"Payment information (2)"]/*[[".cells.staticTexts[@\"Payment information (2)\"]",".staticTexts[@\"Payment information (2)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [app.navigationBars[@"Open Tickets"].buttons[@"verticle"] tap];
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"Open"]/*[[".cells.staticTexts[@\"Open\"]",".staticTexts[@\"Open\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [app.alerts[@"Faveo Helpdesk"].buttons[@"OK"] tap];
}

@end
