import XCTest

class BTAppSwitch_Tests: XCTestCase {

    var appSwitch = BTAppSwitch.sharedInstance()

    override func setUp() {
        super.setUp()
        appSwitch = BTAppSwitch.sharedInstance()
    }
    
    override func tearDown() {
        MockAppSwitchHandler.cannedCanHandle = false
        MockAppSwitchHandler.lastCanHandleURL = nil
        MockAppSwitchHandler.lastCanHandleSourceApplication = nil
        MockAppSwitchHandler.lastHandleAppSwitchReturnURL = nil
        super.tearDown()
    }

    func testHandleOpenURL_whenHandlerIsRegistered_invokesCanHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHandler)
        let expectedURL = NSURL(string: "fake://url")!
        let expectedSourceApplication = "fakeSourceApplication"

        BTAppSwitch.handleOpenURL(expectedURL, sourceApplication: expectedSourceApplication)

        XCTAssertEqual(MockAppSwitchHandler.lastCanHandleURL!, expectedURL)
        XCTAssertEqual(MockAppSwitchHandler.lastCanHandleSourceApplication!, expectedSourceApplication)
    }

    func testHandleOpenURL_whenHandlerCanHandleOpenURL_invokesHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHandler)
        MockAppSwitchHandler.cannedCanHandle = true
        let expectedURL = NSURL(string: "fake://url")!

        let handled = BTAppSwitch.handleOpenURL(expectedURL, sourceApplication: "not important")
        
        XCTAssert(handled)
        XCTAssertEqual(MockAppSwitchHandler.lastHandleAppSwitchReturnURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCantHandleOpenURL_doesNotInvokeHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHandler)
        MockAppSwitchHandler.cannedCanHandle = false

        BTAppSwitch.handleOpenURL(NSURL(string: "fake://url")!, sourceApplication: "not important")

        XCTAssertNil(MockAppSwitchHandler.lastHandleAppSwitchReturnURL)
    }

    func testHandleOpenURL_whenHandlerCantHandleOpenURL_returnsFalse() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHandler)
        MockAppSwitchHandler.cannedCanHandle = false

        XCTAssertFalse(BTAppSwitch.handleOpenURL(NSURL(string: "fake://url")!, sourceApplication: "not important"))
    }
    
    func testHandleOpenURL_acceptsOptionalSourceApplication() {
        // This doesn't assert any behavior about nil source application. It only checks that the code will compile!
        let sourceApplication : String? = nil
        BTAppSwitch.handleOpenURL(NSURL(string: "fake://url")!, sourceApplication: sourceApplication)
    }
    
    func testHandleOpenURL_withNoAppSwitching() {
        let handled = BTAppSwitch.handleOpenURL(NSURL(string: "scheme://")!, sourceApplication: "com.yourcompany.hi")
        XCTAssertFalse(handled)
    }

}

class MockAppSwitchHandler: BTAppSwitchHandler {
    static var cannedCanHandle = false
    static var lastCanHandleURL : NSURL? = nil
    static var lastCanHandleSourceApplication : String? = nil
    static var lastHandleAppSwitchReturnURL : NSURL? = nil

    @objc static func canHandleAppSwitchReturnURL(url: NSURL, sourceApplication: String) -> Bool {
        lastCanHandleURL = url
        lastCanHandleSourceApplication = sourceApplication
        return cannedCanHandle
    }

    @objc static func handleAppSwitchReturnURL(url: NSURL) {
        lastHandleAppSwitchReturnURL = url
    }
}