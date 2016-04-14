/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

@testable import Utility
import XCTest

class GitMoc: Git {
    static var mocVersion: String = "git version 2.5.4 (Apple Git-61)"
    override class var version: String! {
        return mocVersion
    }
}

class GitUtilityTests: XCTestCase {

    func testGitVersion() {
        XCTAssertEqual(GitMoc.majorVersionNumber, 2)

        GitMoc.mocVersion = "2.5.4"
        XCTAssertEqual(GitMoc.majorVersionNumber, 2)

        GitMoc.mocVersion = "git version 1.5.4"
        XCTAssertEqual(GitMoc.majorVersionNumber, 1)

        GitMoc.mocVersion = "1.25.4"
        XCTAssertEqual(GitMoc.majorVersionNumber, 1)
    }
    
    func testHeadSha() {
        mktmpdir { dir in
            initGitRepo(dir)            
            let sha = Git.Repo(path: dir)?.sha
            checkSha(sha!)
        }
    }
    
    func testVersionSha() {
        mktmpdir { dir in
            initGitRepo(dir, tag: "0.1.0") 
            let sha = try Git.Repo(path: dir)?.versionSha(tag: "0.1.0")
            checkSha(sha!)
        }
    }

    func testHeadAndVersionSha() {
        mktmpdir { dir in
            initGitRepo(dir, tag: "0.1.0")
            try commit(dir, file: "file2.swift") 
            
            let headSha = Git.Repo(path: dir)?.sha
            let versionSha = try Git.Repo(path: dir)?.versionSha(tag: "0.1.0")
            checkSha(headSha!)
            checkSha(versionSha!)
            XCTAssertNotEqual(headSha, versionSha)
        }
    }

    func testHasLocalChanges() {
        mktmpdir { dir in
            initGitRepo(dir, tag: "0.1.0")
            let repo = Git.Repo(path: dir)!
            XCTAssertFalse(repo.hasLocalChanges)

            let filePath = Path.join(dir, "file2.swift")
            try popen(["touch", filePath])

            XCTAssertTrue(repo.hasLocalChanges)
        }
    }

//MARK: - Helpers
    
    func checkSha(_ sha: String) {
        XCTAssertNotNil(sha)
        XCTAssertFalse(sha.isEmpty)
        XCTAssertEqual(sha.characters.count, 40)
    }
    
    func commit(_ dstdir: String, file: String) throws {
        let filePath = Path.join(dstdir, file)
        try popen(["touch", filePath])

        try popen(["git", "-C", dstdir, "add", "."])
        try popen(["git", "-C", dstdir, "commit", "-m", "msg"])
    }
}

extension GitUtilityTests {
    static var allTests : [(String, GitUtilityTests -> () throws -> Void)] {
        return [
                   ("testGitVersion", testGitVersion),
                   ("testHeadSha", testHeadSha),
                   ("testVersionSha", testVersionSha),
                   ("testHeadAndVersionSha", testHeadAndVersionSha),
                   ("testHasLocalChanges", testHasLocalChanges),
        ]
    }
}
