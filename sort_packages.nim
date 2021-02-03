from re import `=~`, re
from algorithm import sort
from os import `/`, splitPath
from options import Option, isNone, option, get
from strutils import toLower, join, splitLines, strip, repeat
from json import `[]`, `%`, parseJSON, items, to, pretty # getStr

type
  Package = object
    name, repo, scheme, `method`, description, license: Option[string]
    tags: Option[seq[string]]

let filepath = currentSourcePath().splitPath.head / "packages.json"
let contents = readFile(filepath)
let jdata = parseJSON(contents)
var packages: seq[tuple[name: string, pkg: Package]] = @[]

const empty: seq[string] = @[]
for item in items(jdata):
    var package = to(item, Package)
    if package.name.isNone: package.name = option("")
    if package.repo.isNone: package.repo = option("")
    if package.scheme.isNone: package.scheme = option("")
    if package.`method`.isNone: package.`method` = option("")
    if package.description.isNone: package.description = option("")
    if package.license.isNone: package.license = option("")
    if package.tags.isNone: package.tags = option(empty)

    var p: tuple[name: string, pkg: Package]
    p = (name: package.name.get(), pkg: package)
    # p = (name: item["name"].getStr(""), pkg: package)
    packages.add(p)

# [https://stackoverflow.com/a/6712058]
proc alphasort(a, b: tuple[name: string, pkg: Package]): int =
    let aname = a.name.toLower()
    let bname = b.name.toLower()
    if aname < bname: result = -1 # Sort string ascending.
    elif aname > bname: result = 1
    else: result = 0 # Default return value (no sorting).
packages.sort(alphasort)

const spaces = 4
var package_nodes: seq[string]
for item in packages: package_nodes.add(pretty(%item.pkg, spaces))
let jstr = package_nodes.join(",\n")

var padded_lines: seq[string] = @[]
for line in splitLines(jstr):
    var cline = line.strip(leading = true, trailing = false)
    if line =~ re"^(\s*)":
        let l = matches[0].len
        var padding = 1
        if l > 0: padding += l div spaces
        cline = "\t".repeat(padding) & cline
    padded_lines.add(cline)

writeFile(filepath, "[\n" & padded_lines.join("\n") & "\n]")
