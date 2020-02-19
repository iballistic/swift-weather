import XCTest
@testable import swift_weather

@available(OSX 10.12, *)
final class swift_weatherTests: XCTestCase {
    func testOpenWeather() {
        let api = OpenWeather(apiKey: "your_api_key")
        api.getWeather(latitude: 51.00, longitude: -114.00){
        }
        //we want to wait for the background process to finish
        Thread.sleep(forTimeInterval: TimeInterval.init(10.0))

        if let error = api.error{
            XCTFail("Error : \(error)")
        }
        if let temprature = api.temperature{
            XCTAssertEqual(temprature, temprature)
        }else{
            XCTFail("Nil value in Temprature")
        }
    }
    func testDarkSky() {
        let api = DarkSky(apiKey: "your_api_key")
        api.getWeather(latitude: 51.00, longitude: -114.00){
        }
        //we want to wait for the background process to finish
        Thread.sleep(forTimeInterval: TimeInterval.init(15.0))
        
        if let error = api.error{
            XCTFail("Error : \(error)")
        }
        if let temprature = api.temperature{
            XCTAssertEqual(temprature, temprature)
        }else
        {
            XCTFail("Nil value in Temprature")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    static var allTests = [
        ("testOpenWeather", testOpenWeather),("testDarkSky", testDarkSky)
    ]
}
