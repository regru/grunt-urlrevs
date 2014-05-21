expect = require("chai").expect
grunt = require("grunt")
_ = grunt.util._
util = require("util")
fs = require("fs")
fnc = require("./replaceContent")
options =
  upcased: true
  implant: true

tree =
  "/path/to/file/some_image_img-1.png": "275b78"
  "/path/to/file/some_image_img-2.eot": "ed4da3"
  "/path/to/file/some_image_img-3.svg": "c4dc67"
  "/path/to/file/some_image_img-4.jpg": "a6489f"
  "/path/to/file/some_image_img-5.gif": "5bcf0c"
  "/path/to/file/some_image_img-6.png": "619e6e"

reFilter = /\.(png|jpg|jpeg|gif)/i
reCreateNew = (re) ->
  new RegExp(re, "i")

reSkip = _.map([
  "^https?:\\/\\/"
  "^\\/\\/"
  "^data:image\\/(sv|pn)g"
  "^%23"
], reCreateNew)
reValid = _.map(["^\\/"], reCreateNew)
describe "Tests", ->
  it "Common path", ->
    expect(".selector {background:url('/path/to/file/some_image_img-1.~275B78.png');}")
      .to.equal fnc.replaceContent(".selector {background:url(/path/to/file/some_image_img-1.png);}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt, grunt)
    return

  it "Path to image in single quote", ->
    expect(".selector {background:url('/path/to/file/some_image_img-1.~275B78.png');}")
      .to.equal fnc.replaceContent(".selector {background:url(\"/path/to/file/some_image_img-1.png\");}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Path to image in double quote", ->
    expect(".selector {background:url('/path/to/file/some_image_img-1.~275B78.png');}")
      .to.equal fnc.replaceContent(".selector {background:url('/path/to/file/some_image_img-1.png');}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Path for fonts", ->
    expect("@font-face{src:url('/path/to/file/some_image_img-2.eot') format(\"embedded-opentype\")}")
      .to.equal fnc.replaceContent("@font-face{src:url(\"/path/to/file/some_image_img-2.eot\") format(\"embedded-opentype\")}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Query hash for IE fix", ->
    expect("@font-face{src:url('/path/to/file/some_image_img-2.eot?#iefix') format(\"embedded-opentype\")}")
      .to.equal fnc.replaceContent("@font-face{src:url(\"/path/to/file/some_image_img-2.eot?#iefix\") format(\"embedded-opentype\")}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Hash for svg", ->
    expect(".selector {background:url('/path/to/file/some_image_img-3.svg#iefix');}")
      .to.equal fnc.replaceContent(".selector {background:url(/path/to/file/some_image_img-3.svg#iefix);}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Image path for IE", ->
    expect(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='/path/to/file/some_image_img-6.~619E6E.png')}")
      .to.equal fnc.replaceContent(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='/path/to/file/some_image_img-6.png')}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Image path for IE (with #hash)", ->
    expect(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='/path/to/file/some_image_img-3.svg#hash')}")
    .to.equal fnc.replaceContent(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='/path/to/file/some_image_img-3.svg#hash')}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Base64", ->
    expect(".selector {background-image:url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/P);}")
    .to.equal fnc.replaceContent(".selector {background-image:url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/P);}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Common svg #hash", ->
    expect(".selector {background:url('/path/to/file/some_image_img-7.svg#iefix');}")
    .to.equal fnc.replaceContent(".selector {background:url(/path/to/file/some_image_img-7.svg#iefix);}", reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    return

  it "Empty url", ->
    fnc.replaceContent('.selector {background:url();}', reFilter, tree, options, util, _, reSkip, reValid, fs, grunt)
    .mightThrowAnError;
    return

return
