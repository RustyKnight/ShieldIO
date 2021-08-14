//
//  main.swift
//  ShieldIO
//
//  Created by Shane Whitehead on 8/9/20.
//  Copyright © 2020 Swann Security. All rights reserved.
//

import Foundation
import ArgumentParser

struct ShieldIO: ParsableCommand {
	
	@Argument(help: "Main text")
	var mainText: String
	
	@Argument(help: "Sub text")
	var subText: String
	
	mutating func run() throws {
		//https://raster.shields.io/badge/1.19.4-1-orange
		
		var builder = URLComponents()
		builder.scheme = "https"
		builder.host = "raster.shields.io"
		builder.path = "/badge/\(mainText)-\(subText)-orange"
		
		let url = builder.url!
		
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig)
		
		let semaphore = DispatchSemaphore(value: 0)
		
		let outputPath = FileManager.default.currentDirectoryPath + "/\(self.mainText)-\(self.subText)-orange.png"
		let localURL = URL(fileURLWithPath: outputPath)

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
			if let tempLocalUrl = tempLocalUrl, error == nil {
				// Success
				if let statusCode = (response as? HTTPURLResponse)?.statusCode {
					print("Success: \(statusCode)")
				}
				
				do {
					try? FileManager.default.removeItem(at: localURL)
					try FileManager.default.copyItem(at: tempLocalUrl, to: localURL)
				} catch (let writeError) {
					print("Failed to write image to \(localURL)")
					print("\(writeError)")
				}
				
			} else {
				print("Failure: %@", error?.localizedDescription);
			}
			
			semaphore.signal()
		}
		print("Downloading shield...")
		task.resume()
		semaphore.wait()
		print("Done...")
	}
	
}

ShieldIO.main()
