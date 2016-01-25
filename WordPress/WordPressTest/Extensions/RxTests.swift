import XCTest
import RxSwift
import RxTests
@testable import WordPress

class RxTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPausable_simple1() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(360, 6),
            completed(390)
            ])

        let ys = scheduler.createHotObservable([
            next(210, true),
            next(300, false),
            next(350, true),
            completed(400)
            ])

        let res = scheduler.start {
            xs.pausable(ys)
        }

        XCTAssertEqual(res.events, [
            next(250, 3),
            next(260, 4),
            next(360, 6),
            completed(390)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(210, 300),
            Subscription(350, 390)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 390)
            ])

    }

    func testPausable_PauserCompleteContinuesEmittingIfLastValueTrue() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(360, 6),
            completed(390)
            ])

        let ys = scheduler.createHotObservable([
            next(290, true),
            completed(300)
            ])

        let res = scheduler.start {
            xs.pausable(ys)
        }

        XCTAssertEqual(res.events, [
            next(310, 5),
            next(360, 6),
            completed(300)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(290, 390)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 300)
            ])
        
    }

    func testPausable_PauserCompleteDoesntEmitIfLastValueFalse() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(360, 6),
            completed(390)
            ])

        let ys = scheduler.createHotObservable([
            next(240, true),
            next(290, false),
            completed(320)
            ])

        let res = scheduler.start {
            xs.pausable(ys)
        }

        XCTAssertEqual(res.events, [
            next(250, 3),
            next(260, 4),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(240, 290)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
        
    }

}
