//
//  SwiftCLITests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

import SwiftCLI
import XCTest

extension CLI {
    static func createTester(commands: [Routable], description: String? = nil) -> CLI {
        return CLI(name: "tester", description: description, commands: commands)
    }
}

class TestCommand: Command {

    let name = "test"
    let shortDescription = "A command to test stuff"

    var executionString = ""

    @Param var testName: String
    @Param var testerName: String?
    
    @Flag("-s", "--silent", description: "Silence all test output")
    var silent: Bool
    
    @Key("-t", "--times", description: "Number of times to run the test")
    var times: Int?

    let completion: ((_ executionString: String) -> ())?

    init(completion: ((_ executionString: String) -> ())? = nil) {
        self.completion = completion
    }

    func execute() throws {
        executionString = "\(testerName ?? "defaultTester") will test \(testName), \(times ?? 1) times"
        if silent {
            executionString += ", silently"
        }

        completion?(executionString)
    }

}

class TestCommandWithLongDescription: Command {
    let name = "test"
    let shortDescription = "A command to test stuff"
    let longDescription = "This is a long\nmultiline description"

    func execute() throws {}
}

class MultilineCommand: Command {

    let name = "test"
    let shortDescription = "A command that has multiline comments.\nNew line"

    @Flag("-s", "--silent", description: "Silence all test output\nNewline")
    var silent: Bool
    
    @Key("-t", "--times", description: "Number of times to run the test")
    var times: Int?

    func execute() throws {}

}

class ReversedOrderCommand: Command {

    let name = "test"
    let shortDescription = "A command"

    @Flag("--silent", "-s", description: "Silence all test output\nNewline")
    var silent: Bool
    
    @Key("--times", "-t", description: "Number of times to run the test")
    var times: Int?

    func execute() throws {}

}

class TestInheritedCommand: TestCommand {
    @Flag("-v", "--verbose", description: "Show more output information")
    var verbose: Bool
}

// MARK: -

let alphaCmd = AlphaCmd()
let betaCmd = BetaCmd()
let charlieCmd = CharlieCmd()
let deltaCmd = DeltaCmd()

class AlphaCmd: Command {
    let name = "alpha"
    let shortDescription = "The alpha command"
    fileprivate init() {}
    func execute() throws {}
}

class BetaCmd: Command {
    let name = "beta"
    let shortDescription = "A beta command"
    fileprivate init() {}
    func execute() throws {}
}

class CharlieCmd: Command {
    let name = "charlie"
    let shortDescription = "A beta command"
    fileprivate init() {}
    func execute() throws {}
}

class DeltaCmd: Command {
    let name = "delta"
    let shortDescription = "A beta command"
    fileprivate init() {}
    func execute() throws {}
}

class EmptyCmd: Command {
    let name = "cmd"
    func execute() throws {}
}

class Req1Cmd: EmptyCmd {
    @Param(completion: .function("_ice_targets"))
    var req1: String
}

class Opt1Cmd: EmptyCmd {
    @Param var opt1: String?
}

class Req2Cmd: EmptyCmd {
    @Param(completion: .filename)
    var req1: String
    
    @Param(completion: .values([
        ("executable", "generates a project for a cli executable"),
        ("library", "generates project for a dynamic library"),
        ("other", "")
    ]))
    var req2: String
}

class Opt2Cmd: EmptyCmd {
    @Param(completion: .filename)
    var opt1: String?
    
    @Param(completion: .values([
        ("executable", "generates a project for a cli executable"),
        ("library", "generates project for a dynamic library")
    ]))
    var opt2: String?
}

class Opt2InhCmd: Opt2Cmd {
    @Param var opt3: String?
}

class ReqCollectedCmd: EmptyCmd {
    @CollectedParam(minCount: 1) var req1: [String]
}

class OptCollectedCmd: EmptyCmd {
    @CollectedParam var opt1: [String]
}

class Req2CollectedCmd: EmptyCmd {
    @Param(completion: .values([
        ("executable", "generates a project for a cli executable"),
        ("library", "generates project for a dynamic library")
    ]))
    var req1: String
    
    @CollectedParam(minCount: 1, completion: .filename)
    var req2: [String]
}

class TriReqCollectedCmd: EmptyCmd {
    @CollectedParam(minCount: 3)
    var triReq: [String]
}

class Opt2CollectedCmd: EmptyCmd {
    @Param var opt1: String?
    @CollectedParam var opt2: [String]
}

class Req2Opt2Cmd: EmptyCmd {
    @Param(completion: .filename)
    var req1: String
    
    @Param(completion: .function("_swift_dependency"))
    var req2: String
    
    @Param(completion: .none)
    var opt1: String?
    
    @Param(completion: .filename)
    var opt2: String?
}

// MARK: -

let midGroup = MidGroup()
let intraGroup = IntraGroup()

class MidGroup: CommandGroup {
    let name = "mid"
    let shortDescription = "The mid level of commands"
    let children: [Routable] = [alphaCmd, betaCmd]
    fileprivate init() {}
}

class IntraGroup: CommandGroup {
    let name = "intra"
    let shortDescription = "The intra level of commands"
    let children: [Routable] = [charlieCmd, deltaCmd]
    fileprivate init() {}
}

// MARK: -

class OptionCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    func execute() throws {}
}

class FlagCmd: OptionCmd {
    @Flag("-a", "--alpha")
    var flag: Bool
}

class KeyCmd: OptionCmd {
    @Key("-a", "--alpha")
    var key: String?
}

class DoubleFlagCmd: OptionCmd {
    @Flag("-a", "--alpha", description: "The alpha flag")
    var alpha: Bool
    
    @Flag("-b", "--beta", description: "The beta flag")
    var beta: Bool
}

class DoubleKeyCmd: OptionCmd {
    @Key("-a", "--alpha")
    var alpha: String?
 
    @Key("-b", "--beta")
    var beta: String?
}

class FlagKeyCmd: OptionCmd {
    @Flag("-a", "--alpha")
    var alpha: Bool
    
    @Key("-b", "--beta")
    var beta: String?
}

class FlagKeyParamCmd: OptionCmd {
    @Flag("-a", "--alpha")
    var alpha: Bool
    
    @Key("-b", "--beta")
    var beta: String?
    
    @Param var param: String
}

class IntKeyCmd: OptionCmd {
    @Key("-a", "--alpha")
    var alpha: Int?
}

class ExactlyOneCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    var helpFlag: Flag? = nil
    func execute() throws {}
    
    @Flag("-a", "--alpha", description: "the alpha flag")
    var alpha: Bool
    
    @Flag("-b", "--beta", description: "the beta flag")
    var beta: Bool
    
    lazy var optionGroups: [OptionGroup] = [.exactlyOne($alpha, $beta)]
}

class MultipleRestrictionsCmd: Command {
    let name = "cmd"
    
    @Flag("-a", "--alpha", description: "the alpha flag")
    var alpha: Bool
    
    @Flag("-b", "--beta", description: "the beta flag")
    var beta: Bool
    
    lazy var atMostOne: OptionGroup = .atMostOne($alpha, $beta)
    lazy var atMostOneAgain: OptionGroup = .atMostOne($alpha, $beta)
    
    var optionGroups: [OptionGroup] {
        return [atMostOne, atMostOneAgain]
    }
    
    func execute() throws {}
}

class VariadicKeyCmd: OptionCmd {
    @VariadicKey("-f", "--file", description: "a file")
    var files: [String]
}

class CounterFlagCmd: OptionCmd {
    @CounterFlag("-v", "--verbose", description: "Increase the verbosity")
    var verbosity: Int
}

class ValidatedKeyCmd: OptionCmd {
    
    static let capitalizedFirstName = Validation.custom("Must be a capitalized first name") { $0.capitalized == $0 }
    
    @Key("-n", "--name", validation: [capitalizedFirstName])
    var firstName: String?
    
    @Key("-a", "--age", validation: [.greaterThan(18)])
    var age: Int?
    
    @Key("-l", "--location", validation: [.rejecting("Chicago", "Boston")])
    var location: String?
    
    @Key("--holiday", validation: [.allowing("Thanksgiving", "Halloween")])
    var holiday: String?
    
}

class QuoteDesciptionCmd: Command {
    let name = "cmd"
    let shortDescription = "this description has a \"quoted section\""
    
    @Flag("-q", "--quoted", description: "also has \"quotes\"")
    var flag: Bool
    
    func execute() throws {}
}

class CompletionOptionCmd: OptionCmd {
    @Key("-v", "--values", completion: .values([("opt1", "first option"), ("opt2", "second option")]))
    var values: String?
    
    @Key<String>("-f", "--function", completion: .function("_a_func"))
    var function: String?
    
    @Key<String>("-n", "--name", completion: .filename)
    var filename: String?
    
    @Key<String>("-z", "--zero", completion: .none)
    var none: String?
    
    @Key<String>("-d", "--default")
    var def: String?
    
    @Flag("-f", "--flag")
    var flag: Bool
}

class EnumCmd: Command {
    
    enum Speed: String, ConvertibleFromString {
        case slow
        case fast
    }
    
    enum Single: String, ConvertibleFromString {
        case value
        
        static let explanationForConversionFailure = "only can be 'value'"
    }
    
    let name = "cmd"
    let shortDescription = "Limits param values to enum"
    
    @Param var speed: Speed
    @Param var single: Single?
    @Param var int: Int?
    
    func execute() throws {}
    
}

#if swift(>=4.1.50)
extension EnumCmd.Speed: CaseIterable {}
#endif

class ValidatedParamCmd: Command {
    
    let name = "cmd"
    let shortDescription = "Validates param values"
    
    @Param(validation: .greaterThan(18))
    var age: Int?
    
    func execute() throws {}
    
}

class RememberExecutionCmd: Command {
    
    let name = "cmd"
    let shortDescription = "Remembers execution"
    
    @Param var param: String?
    
    var executed = false
    
    func execute() throws {
        executed = true
    }
    
}

class ParamInitCmd: Command {
    let name = "cmd"
    
    @Param(completion: .filename)
    var reqComp: String
    
    @Param(completion: .filename)
    var optComp: String?
    
    @Param(validation: .allowing("hi"))
    var reqVal: String
    
    @Param(validation: .allowing("yo"))
    var optVal: String?
    
    @Param(completion: .filename, validation: .allowing("hi"))
    var reqCompVal: String
    
    @Param(completion: .filename, validation: .allowing("yo"))
    var optCompVal: String?
    
    @Param
    var reqNone: String
    
    @Param
    var optNone: String?
    
    func execute() {}
}

// MARK: -

func XCTAssertThrowsSpecificError<T, E: Error>(
    expression: @escaping @autoclosure () throws -> T,
    file: StaticString = #file,
    line: UInt = #line,
    error errorHandler: @escaping (E) -> Void) {
    XCTAssertThrowsError(try expression(), file: file, line: line) { (error) in
        guard let specificError = error as? E else {
            XCTFail("Error must be type \(String(describing: E.self)), is \(String(describing: type(of: error)))", file: file, line: line)
            return
        }
        errorHandler(specificError)
    }
}

func XCTAssertEqualLineByLine(_ s1: String, _ s2: String, file: StaticString = #file, line: UInt = #line) {
    let lines1 = s1.components(separatedBy: "\n")
    let lines2 = s2.components(separatedBy: "\n")
    
    XCTAssertEqual(lines1.count, lines2.count, "line count should be equal", file: file, line: line)
    
    for (l1, l2) in zip(lines1, lines2) {
        XCTAssertEqual(l1, l2, file: file, line: line)
    }
}

extension CLI {
    
    static func capture(_ block: () -> ()) -> (String, String) {
        let out = CaptureStream()
        let err = CaptureStream()
        
        Term.stdout = out
        Term.stderr = err
        block()
        Term.stdout = WriteStream.stdout
        Term.stderr = WriteStream.stderr
        
        out.closeWrite()
        err.closeWrite()
        
        return (out.readAll(), err.readAll())
    }
    
}
