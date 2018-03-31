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
    
    //basic test
    func testHelloWorld(){
        var helloWorld: String?
        
        XCTAssertNil(helloWorld)
        
        helloWorld = "hello world"
        XCTAssertEqual("hello world", helloWorld!)
    }
    
    
    
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
    
    //network test
    func testCallsWithUrlSession(){
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
    //TODO: make sure these two images are the EXACT same. (maybe with XCUITesting)
    func testStubbedCall1(){
        
        // Setup network stubs
        //note: url made up of scheme, host, and path components
        let testHost = "photo.nemours.org" //host
        let id = "64893"
        
        //lets convert this image stub to data
        let imageData:Data = UIImageJPEGRepresentation(#imageLiteral(resourceName: "stub.jpg"),1)!
        //        print("imageData: \(imageData.base64EncodedString())")
        let promise = expectation(description: "image call should succeed")
        stub(condition: isHost(testHost) && isPath("/P/\(id)/100x100")) {
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
    //BLOCKER: getting errors: "linker command failed with exit code 1 (use -v to see invocation)"
    func testStubbedCall2(){
        let pokemonId = 23
        
        NetworkService.downloadPokemon(for: pokemonId) {
            (pokemon, error) in
            print("handle pokemon here")
        }
        
        
    }
}



