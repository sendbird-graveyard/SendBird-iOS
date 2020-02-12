//
//  SendBird_iOSTests.swift
//  SendBird-iOSTests
//
//  Created by Harry Kim on 2020/01/14.
//  Copyright © 2020 SendBird. All rights reserved.
//

import XCTest
import SendBird_iOS
import SendBirdSDK
import SendBirdSyncManager
import FLAnimatedImage

class SendBird_iOSTests: XCTestCase {

    override class func setUp() {
        print("++setup")
    }
    
    override func setUp() {
        print("--setup")
    }

    override func tearDown() {
        print("--teardown")
    }
    
    override class func tearDown() {
        print("++teardown")
    }
    

    func testLogin() {
        let exp = XCTestExpectation()
        ConnectionControl.setLoginInfo(userId: "\n", nickname: "\n").login { user, error in
            XCTAssertNotNil(user)
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        self.wait(for: [exp], timeout: 5)
    }

    func testGetChannelList() {
        let exp = XCTestExpectation()
        ConnectionControl.setLoginInfo(userId: "\n", nickname: "\n").login { user, error in

            let query = SBDGroupChannel.createMyGroupChannelListQuery()!
            query.order = .latestLastMessage
            
            let collection = SBSMChannelCollection.init(query: query)!
            collection.fetch { error in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    let channels = collection.channels
                    XCTAssertNil(error)
                    XCTAssertTrue(!channels.isEmpty)
                    exp.fulfill()
                }

            }
            
        }
        self.wait(for: [exp], timeout: 10)
    }
    
    func testGetMessage() {
        let exp = XCTestExpectation()
        ConnectionControl.setLoginInfo(userId: "\n", nickname: "\n").login { user, error in

            let query = SBDGroupChannel.createMyGroupChannelListQuery()!
            query.order = .latestLastMessage
            
            let collection = SBSMChannelCollection.init(query: query)!
            collection.fetch { error in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    let channels = collection.channels
                    XCTAssertNil(error)
                    XCTAssertTrue(!channels.isEmpty)
                    
                    let channel = channels.first!
                    
                    let collection = SBSMMessageCollection(channel: channel,filter: SBSMMessageFilter(), viewpointTimestamp: LONG_LONG_MAX)
                    collection.fetch(in: .next) { hasMore, error in

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            XCTAssertNil(error)
                            XCTAssertTrue(!collection.succeededMessages.isEmpty)
                            exp.fulfill()
                        }
                    }
                    
                }
            }
        }
        self.wait(for: [exp], timeout: 10)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
