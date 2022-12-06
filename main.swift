//
//  main.swift
//  file-version-sample
//
//  Created by 七海ステファヌス on 2022/12/06.
//

import Foundation

print("--- Begin ---")

let path = FileManager.default.currentDirectoryPath.appending("/test.dat")
let url = URL(filePath: path)
var error: NSError?

func randomData() -> [UInt8]
{
  var result = Array<UInt8>()
  for _ in 1...8 {
    let vv = UInt8.random(in: 0...255)
    result.append(vv)
  }
  return result
}

func print(fileVersion: NSFileVersion)
{
  print("Version info:")
  print("  \(fileVersion.url)")
  print("  \(fileVersion.localizedName ?? "No name")")
  if let date = fileVersion.modificationDate {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "YY/MM/dd, HH:mm:ss"
    print("  \(dateFormater.string(from: date))")
  }
  print("  \(fileVersion.persistentIdentifier)")
}

func write(data: [UInt8], toPath: String) throws
{
  let fileHandle = FileHandle(forWritingAtPath: toPath)
  try fileHandle?.write(contentsOf: data)
  try fileHandle?.close()
  print("Written \(data.count) byte(s) to \(toPath)")
}

func createVersionFor(url: URL) throws
{
  let fileVersion = try NSFileVersion.addOfItem(at: url, withContentsOf: url)
  print(fileVersion: fileVersion)
}

func writeTo(url: URL)
{
  do {
    let urlPath = url.path()

    // Get version.
    let fileVersion = NSFileVersion.currentVersionOfItem(at: url)
    if fileVersion != nil {
      print("File exist at \(url)")
      print(fileVersion: fileVersion!)

      let data = randomData()
      try write(data: data, toPath: urlPath)

      // Create new file version.
      try createVersionFor(url: url)
    } else {
      if FileManager.default.fileExists(atPath: urlPath) == false {
        FileManager.default.createFile(atPath: urlPath, contents: nil)
        print("File created at \(url)")
      }

      let data = randomData()
      try write(data: data, toPath: urlPath)

      // Create file version.
      try createVersionFor(url: url)
    }
  } catch {
    print("Error writing to \(url)")
  }
}

var coordinator = NSFileCoordinator()
coordinator.coordinate(writingItemAt: url,
                       error: &error,
                       byAccessor: writeTo)

print("--- Available versions ---")
let versions = NSFileVersion.otherVersionsOfItem(at: url)
for version in versions! {
  print(fileVersion: version)
}

print("--- End ---")
