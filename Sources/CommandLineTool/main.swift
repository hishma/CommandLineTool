import Foundation
import SPMUtility

let parser = ArgumentParser(usage: "<options>", overview: "This is what this tool is for")

// MARK: -  Example of a file arguemnt

let fileArg: PositionalArgument<PathArgument> = parser.add(positional: "file", kind: PathArgument.self, optional: true, usage: "Path to the plist file.", completion: .filename)


// MARK: -  Example of an enum argument

enum Protein: String {
    case chicken, beef
}

extension Protein: StringEnumArgument {
    static var completion: ShellCompletion {
        return ShellCompletion.values([
            (value: "chicken", description: "Tastes like chicken!"),
            (value: "beef", description: "Moooooooo."),
            ])
    }
}

let proteinArg: OptionArgument<Protein> = parser.add(option: "--protein", shortName: "-p", kind: Protein.self, usage: "[chicken|beef] choose your protein.", completion: Protein.completion)

// MARK: -  Example of a simple boolean argument (switch)

let yellArg = parser.add(option: "--yell", shortName: "-y", kind: Bool.self, usage: nil, completion: nil)


// reads the plist file
private func readPlist(at fileArg: PathArgument) throws -> [String : AnyObject] {
    
    let path = fileArg.path.pathString
    
    guard FileManager.default.fileExists(atPath: path) else {
        throw ArgumentParserError.invalidValue(argument: "file", error: ArgumentConversionError.custom("Invalid file path"))
    }
    
    let fileUrl = URL(fileURLWithPath: path)
    
    guard fileUrl.pathExtension == "plist" else {
        throw ArgumentParserError.invalidValue(argument: "file", error: ArgumentConversionError.custom("Not a plist"))
    }
    
    let data = try Data(contentsOf: fileUrl, options: [.mappedIfSafe])
    
    let plist = try PropertyListSerialization.propertyList(from: data, options:PropertyListSerialization.ReadOptions(), format: nil)
    
    guard let plistDict = plist as? [String : AnyObject] else {
        throw ArgumentParserError.invalidValue(argument: "file", error: ArgumentConversionError.custom("Property list is not a dictionary"))
    }
    
    return plistDict
}


// The first argument is always the executable, drop it
let args = Array(ProcessInfo.processInfo.arguments.dropFirst())

do {
    let arguments = try parser.parse(args)
    
    if let fileArg = arguments.get(fileArg) {
        let settings = try readPlist(at: fileArg)
        print(settings.description)
    }
    
    
    if let protein: Protein = arguments.get(proteinArg) {
        var message: String
        
        switch protein {
        case .chicken:
            message = "Tastes like chicken"
        case .beef:
            message = "Moooooooooooooooooo"
        }
        
        if (arguments.get(yellArg) ?? false) {
            message = message.uppercased() + "!"
        }
        
        print(message)
    }
    
    exit(EXIT_SUCCESS)
    
} catch let error as ArgumentParserError {
    print(error.description)
    exit(EXIT_FAILURE)
    
} catch let error {
    print(error.localizedDescription)
    exit(EXIT_FAILURE)
}
