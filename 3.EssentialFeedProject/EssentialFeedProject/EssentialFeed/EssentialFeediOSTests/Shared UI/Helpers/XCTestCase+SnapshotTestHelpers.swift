//
//  SharedSnapshotTestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 20/07/2023.
//

import XCTest

extension XCTestCase {

    func record(_ snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file, line: line)
        let snapshotData = makeSnapshotData(snapshot, file: file, line: line)
            
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
            
            XCTFail("Record Successful - use 'assert' to compare the captured snapshot with recorded snapshot", file: file, line: line)
        }
        catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    func assert(_ snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let recordedSnapshotURL = makeSnapshotURL(named: name, file: file, line: line)
        let newSnapshotData = makeSnapshotData(snapshot, file: file, line: line)
        
        guard let recordedSnapshotData = try? Data(contentsOf: recordedSnapshotURL) else {
            return XCTFail("Failed to load the recorded snapshot at \(recordedSnapshotURL). Use 'record' method before asserting", file: file, line: line)
        }
        
        if newSnapshotData != recordedSnapshotData {
            let temporaryURL = FileManager.default.temporaryDirectory.appending(path: recordedSnapshotURL.lastPathComponent)
            try! newSnapshotData?.write(to: temporaryURL)
            
            XCTAssertEqual(newSnapshotData, recordedSnapshotData, "New Snapshot does not match recorded snapshot. New Snapshot URL: \(temporaryURL), Recorded Snapshot URL: \(recordedSnapshotURL)", file: file, line: line)
        }
    }

    private func makeSnapshotData(_ snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Falied to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        return data
    }

    private func makeSnapshotURL(named name: String, file: StaticString = #file, line: UInt = #line) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshot")
            .appending(path: "\(name).png")
    }
}

