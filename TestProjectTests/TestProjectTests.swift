//
//  TestProjectTests.swift
//  TestProjectTests
//
//  Created by Admin on 3/28/18.
//  Copyright © 2018 Patel, Sanjay. All rights reserved.
//

import XCTest

@testable import TestProject
import OHHTTPStubs



class TestProjectTests: XCTestCase {
    
    func testHelloWorld(){
        var helloWorld: String?
        
        XCTAssertNil(helloWorld)
        
        helloWorld = "hello world"
        XCTAssertEqual("hello world", helloWorld!)
    }
    
    
//    func testSquareInt(){
//        let value = 3
//        let actual = value.square()
//        
//        XCTAssertEqual(actual, 9)
//    }
    
    
    //basic network test
    func testNetworkCall(){
        
        //1. create your expectation with associated description
        let promise = expectation(description: "We want this call to succeed.")
        let id = "64893"
        
        //3. escaping closure will execute once it has received something from the network thread.
        NetworkService.downloadImage(from: id) {
            (image, error) in
            XCTAssertNil(error)     //4. the error should be nil, or the test will fail.
            XCTAssertNotNil(image)  //5. the image data should not be nil or else the test will fail.
            promise.fulfill()       //6. fulfill the expectation to pass the test.
        }
        
        //2. Give it 10 seconds to response, after which time we will say that it has timed out.
        waitForExpectations(timeout: 10) {
            (err) in
            XCTAssertNil(err, "this test timed out \(err!.localizedDescription)")
        }
    }
    
    //if i need to manipulate the run loop during unit test (unlikely)
    func testNetworkCallWithSemaphore(){
        
        //1. create your semaphore that will allow for a semaphore resource
        let sem = DispatchSemaphore(value: 0)
        
        let id = "64893"
        NetworkService.downloadImage(from: id) {
            (image, error) in
            print("in here")
            
            XCTAssertNil(error)     //3. the error should be nil, or the test will fail.
            XCTAssertNotNil(image)  //4. the image data should not be nil or else the test will fail.
            sem.signal()            //5. increment your semaphore value by 1. ( release the semaphore resource)
        }
        
        //2. timeout condition
        let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(5)
        if sem.wait(timeout: timeout) == DispatchTimeoutResult.timedOut{
            XCTFail("semaphore - we wait() 'ed for more than 5 seconds.")
        }
        
    }
    
    //network test with stubbing.
    func testStubbedCalls(){
        let promise = expectation(description: "call should succeed")
        let urlString = "http://images.apple.com/support/assets/images/products/iphone/hero_iphone4-5_wide.png"
        
        guard let url = URL(string: urlString) else {
            XCTFail("bad url")
            return
        }
        
        URLSession.shared.dataTask(with: url){
            (data, response, error) in
            print("test in _-__")
            XCTAssertNil(error) //the error should be nil, or the test will fail.
            XCTAssertNotNil(UIImage(data: data!)) //the image data should not be nil or else the test will fail.
            promise.fulfill()
            }.resume()
        
        waitForExpectations(timeout: 10){
            (error) in
            XCTAssertNil(error, "response timed out! \(error?.localizedDescription ?? "")")
        }
    }
    
    //this is for am image stub. i replaced it with stub.jpg for hypothetical image link
    //TODO: make sure these two images are the EXAXT same.
    func testStubbedCall1(){
        
        // Setup network stubs
        //note: url made up of scheme, host, and path components
        let testHost = "photo.nemours.org" //host
        let id = "64893"
        
        //lets convert this image stub to data
        let imageData:Data = UIImageJPEGRepresentation(#imageLiteral(resourceName: "stub.jpg"),1)!
        //        print("imageData: \(imageData.base64EncodedString())")
        let promise = expectation(description: "image call should succeed")
        stub(condition: isHost(testHost) && isPath("/P/\(id)/100x100")) { //path was annoying to find
            _ in
            return OHHTTPStubsResponse(data: imageData, statusCode: 200, headers: .none)
        }
        
        NetworkService.downloadImage(from: id) {
            (image, error) in
            XCTAssertNil(error) //the error should be nil, or the test will fail.
            XCTAssertNotNil(image) //the image data should not be nil or else the test will fail.
            //            let imageData2:Data = UIImageJPEGRepresentation(image!,1)!
            //            print("imageData2: \(imageData2.base64EncodedString())")
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 10){
            (error) in
            XCTAssertNil(error, "response timed out! \(error?.localizedDescription ?? "")")
        }
        
        // my cleanup (also makes sense to put this in teardown)
        OHHTTPStubs.removeAllStubs()
    }
    
    
    //stubbed call for json. (there is no network call for pokemon so i took one from another project)
    func testStubbedCall2(){
        //        let pokemonId = 23
        
        guard let gitUrl = URL(string: "https://api.github.com/users/shashikant86") else { return }
        let promise = expectation(description: "Simple Request")
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let result = json as? NSDictionary {
                    XCTAssertTrue(result["name"] as! String == "Shashikant")
                    XCTAssertTrue(result["location"] as! String == "London")
                    promise.fulfill()
                }
            } catch let err {
                print("Err", err)
            }
            }.resume()
        waitForExpectations(timeout: 5, handler: nil)
        
        
        
        //                let stubbedJSON = [
        //                    "id": id,
        //                    "foo": "some text",
        //                    "bar": "some other text",
        //                    ]
        
        //        NetworkService.downloadPokemon(for: pokemonId) {
        //            (pokemon, error) in
        //            print("completion")
        //        }
        
        // Setup network stubs
        //        let testHost = "te.st"
        //        let id = "42-abc"
        //        let stubbedJSON = [
        //            "id": id,
        //            "foo": "some text",
        //            "bar": "some other text",
        //            ]
        //        stub(isHost(testHost) && isPath("/resources/\(id)")) { _ in
        //            return OHHTTPStubsResponse(
        //                JSONObject: stubbedJSON,
        //                statusCode: 200,
        //                headers: .None
        //            )
        //        }
        //        // Setup system under test
        //        let client = APIClient(baseURL: NSURL(string: "http://\(testHost)")!)
        //        let expectation = self.expectationWithDescription("calls the callback with a resource object")
        //
        //        // Act
        //        //
        //        client.getResource(withId: id) { resource, error in
        //
        //            // Assert
        //            //
        //            XCTAssertNil(error)
        //            XCTAssertEqual(resource?.id, stubbedJSON["id"])
        //            XCTAssertEqual(resource?.aProperty, stubbedJSON["foo"])
        //            XCTAssertEqual(resource?.anotherPropert, stubbedJSON["bar"])
        //
        //            expectation.fulfill()
        //        }
        //
        //        self.waitForExpectationsWithTimeout(0.3, handler: .None)
        //
        //        // Tear Down
        //        //
        //        OHHTTPStubs.removeAllStubs()
        
        
    }
    
}



