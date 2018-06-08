import Foundation
import Utility

// The first argument is always the executable, drop it
let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parser = ArgumentParser(usage: "<options>", overview: "This is what this tool is for")

let fileArg: PositionalArgument<PathArgument> = parser.add(positional: "file", kind: PathArgument.self, optional: false, usage: "Path to the file", completion: .filename)


func processArguments(arguments: ArgumentParser.Result) throws -> [String: AnyObject]  {
    
    guard let path = arguments.get(fileArg)?.path.asString, FileManager.default.fileExists(atPath: path) else {
        throw ArgumentParserError.invalidValue(argument: "file", error: ArgumentConversionError.custom("Invalid file path"))
    }
    
    let fileUrl = URL(fileURLWithPath: path)
    
    
    guard fileUrl.pathExtension == "plist" else {
        throw ArgumentParserError.invalidValue(argument: "file", error: ArgumentConversionError.custom("Not a plist"))
    }
    
    let data = try Data(contentsOf: fileUrl, options: [.mappedIfSafe])
    
    
    
    let plist = try PropertyListSerialization.propertyList(from: data, options:PropertyListSerialization.ReadOptions(), format:nil)
    
    guard let plistDict = plist as? [String: AnyObject] else {
        throw ArgumentParserError.invalidValue(argument: "file", error: ArgumentConversionError.custom("Property list is not a dictionary"))
    }
    
    return plistDict
}

do {
    let parsedArguments = try parser.parse(arguments)
    
    let settings = try processArguments(arguments: parsedArguments)
    
    print(settings.description)
    
    exit(EXIT_SUCCESS)
    
} catch let error as ArgumentParserError {
    print(error.description)
    exit(EXIT_FAILURE)
} catch let error {
    print(error.localizedDescription)
    exit(EXIT_FAILURE)
}
