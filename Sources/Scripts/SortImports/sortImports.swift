#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

guard CommandLine.argc > 1 else {
  print("Sorting imports terminated -> Missing project path!")
  exit(0)
}

let projectPath = CommandLine.arguments[1]

struct FilePath: Hashable {
  let fullPath: String?
  let name: String
  
  static func == (lhs: FilePath, rhs: FilePath) -> Bool { return lhs.name == rhs.name }
}

struct Line: Hashable, Equatable {
  let index: Int
  let value: String
}

func sortImports(for file: FilePath) {
  print("Sorting imports on '\(file.name)'", terminator: "")
  guard let relativePath = file.fullPath else {
    print(" -> Skipped (invalid path)")
    return
  }
  
  let filePath = projectPath + relativePath
  guard let fileText = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print(" -> Skipped (invalid content)")
    return
  }
  
  var fileLines = fileText.components(separatedBy: .newlines)
  
  var importLines = [Line]()
  for (index, line) in fileLines.enumerated() {
    switch line.hasPrefix("import") {
    case true:
      importLines.append(Line(index: index, value: line))
    case false:
      // stop searching for imports after last one is found
      if !importLines.isEmpty { break }
    }
  }
  
  guard !importLines.isEmpty else {
    print(" -> Skipped (no imports)")
    return
  }
  
  // remove unsorted imports from file
  importLines.reversed().forEach {
    fileLines.remove(at: $0.index)
  }
  
  guard var insertIndex = importLines.first?.index else {
    print(" -> Skipped (no import lines)")
    return
  }
  
  // remove duplicates and sort lines
  let sortedLines = Array(Set(importLines)).sorted { $0.value < $1.value }
  
  guard sortedLines != importLines else {
    print(" -> Skipped (nothing to sort)")
    return
  }
  
  // append sorted lines
  sortedLines.forEach {
    fileLines.insert($0.value, at: insertIndex)
    insertIndex += 1
  }
  
  // write back to file
  do {
    let updatedFile = fileLines.joined(separator: "\n")
    try updatedFile.write(toFile: filePath, atomically: true, encoding: .utf8)
    print(" -> Sorted")
  } catch {
    print(" -> Skipped (writting failed)")
  }
}

func allSwiftFiles(in directory: String) -> Set<FilePath> {
  return Set(( FileManager.default.subpaths(atPath: directory) ?? [])
    .compactMap {
      guard $0.hasSuffix(".swift") else { return nil }
      guard let lastSlash = $0.range(of: "/", options: .backwards)?.upperBound else {
        return FilePath(fullPath: $0, name: $0)
      }
      return FilePath(fullPath: $0, name: String($0[lastSlash...]))
    }
  )
}

let allFiles = allSwiftFiles(in: projectPath)
allFiles.forEach {
  sortImports(for: $0)
}
