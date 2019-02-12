//
//  CreateTicket.m
//  Faveo Helpdesk Client AppUITests
//
//  Created by Mallikarjun on 12/02/19.
//  Copyright © 2019 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CreateTicket : XCTestCase

@end

@implementation CreateTicket

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

- (void)testCreateTicket {
   
    //App is started and initilized
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    //clicked on top left navigation bar button
    [app.navigationBars[@"Open Tickets"].buttons[@"menu button"] tap];
    
    // Tableview object is created
    XCUIElementQuery *tablesQuery2 = app.tables;
    XCUIElementQuery *tablesQuery = tablesQuery2;
    
    //clicked on create ticket - row on the tableview
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"Create Ticket"]/*[[".cells.staticTexts[@\"Create Ticket\"]",".staticTexts[@\"Create Ticket\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    //created instance object of the subject text view
    XCUIElement *subjectTextView = [[tablesQuery2.cells containingType:XCUIElementTypeStaticText identifier:@"Subject*"] childrenMatchingType:XCUIElementTypeTextView].element;
   
    [subjectTextView tap];
    [subjectTextView typeText:@"Permission module is not working"];
    
    //created instance object of the subject text view
    XCUIElement *messageTextView = [[tablesQuery2.cells containingType:XCUIElementTypeStaticText identifier:@"Message*"] childrenMatchingType:XCUIElementTypeTextView].element;
    [messageTextView tap];
    [messageTextView typeText:@"The Agent who do not having permission to change status they can able to change the status."];
    
    XCUIElement *doneButton = app.toolbars[@"Toolbar"].buttons[@"Done"];

    /*@START_MENU_TOKEN@*/[tablesQuery.textFields[@"Select Priority"] pressForDuration:1.2];/*[["tablesQuery",".cells.textFields[@\"Select Priority\"]","["," tap];"," pressForDuration:1.2];",".textFields[@\"Select Priority\"]"],[[[-1,0,1]],[[-1,5,2],[-1,1,2]],[[2,4],[2,3]]],[0,0,0]]@END_MENU_TOKEN@*/
    [doneButton tap];
    
    /*@START_MENU_TOKEN@*/[tablesQuery.textFields[@"Select Helptopic"] pressForDuration:1.2];/*[["tablesQuery",".cells.textFields[@\"Select Helptopic\"]","["," tap];"," pressForDuration:1.2];",".textFields[@\"Select Helptopic\"]"],[[[-1,0,1]],[[-1,5,2],[-1,1,2]],[[2,4],[2,3]]],[0,0,0]]@END_MENU_TOKEN@*/
    [doneButton tap];
    
    
    //clicked on submit button
    [tablesQuery/*@START_MENU_TOKEN@*/.buttons[@"Submit"]/*[[".cells.buttons[@\"Submit\"]",".buttons[@\"Submit\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
}

@end
