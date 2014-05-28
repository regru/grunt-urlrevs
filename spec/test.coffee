expect = require("chai").expect
fnc = require("../tasks/lib/replace")

options =
  abbrev      : 6
  branch      : 'HEAD'
  filter      : '\\.(png|jpg|jpeg|gif|svg|eot)'
  path        : 'root/i'
  prefix      : ''
  valid       : [ '' ],
  skip        : [ '^https?:\\/\\/', '^\\/\\/', '^data:image\\/(sv|pn)g', '^%23' ]
  implant     : true
  upcased     : true
  autocommit  : true
  message     : 'Wave a magic wand (by urlrevs)'

optionsTestImplant =
  abbrev      : 6
  branch      : 'HEAD'
  filter      : '\\.(png|jpg|jpeg|gif|svg|eot)'
  path        : 'root/i'
  prefix      : ''
  valid       : [ '' ],
  skip        : [ '^https?:\\/\\/', '^\\/\\/', '^data:image\\/(sv|pn)g', '^%23' ]
  implant     : false
  upcased     : true
  autocommit  : true
  message     : 'Wave a magic wand (by urlrevs)'

tree =
  "spec/img-test/some_image_img-1.png": "275b78"
  "spec/img-test/some_image_img-2.eot": "ed4da3"
  "spec/img-test/some_image_img-3.svg": "c4dc67"
  "spec/img-test/some_image_img-4.jpg": "a6489f"
  "spec/img-test/some_image_img-5.gif": "5bcf0c"
  "spec/img-test/some_image_img-6.png": "619e6e"
  "spec/img-test/some_image_img-7.svg": "619e6e"

describe "Tests", ->
  it "Common path", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-1.png);}", tree, options))
      .to.equal(".selector {background:url('spec/img-test/some_image_img-1.~275B78.png');}")
    return

  it "Path to image in single quote", ->
    expect(fnc.replaceContent(".selector {background:url(\"spec/img-test/some_image_img-1.png\");}", tree, options))
      .to.equal(".selector {background:url('spec/img-test/some_image_img-1.~275B78.png');}")
    return

  it "Path to image in double quote", ->
    expect(fnc.replaceContent(".selector {background:url(\"spec/img-test/some_image_img-1.png\");}", tree, options))
      .to.equal(".selector {background:url('spec/img-test/some_image_img-1.~275B78.png');}")
    return

  it "Path for fonts", ->
    expect(fnc.replaceContent("@font-face{src:url('spec/img-test/some_image_img-2.eot') format(\"embedded-opentype\")}", tree, options))
      .to.equal("@font-face{src:url('spec/img-test/some_image_img-2.~ED4DA3.eot') format(\"embedded-opentype\")}")
    return

  it "Query hash for IE fix", ->
    expect(fnc.replaceContent("@font-face{src:url(\"spec/img-test/some_image_img-2.eot?#iefix\") format(\"embedded-opentype\")}", tree, options))
      .to.equal("@font-face{src:url('spec/img-test/some_image_img-2.~ED4DA3.eot?#iefix') format(\"embedded-opentype\")}")
    return

  it "Hash for svg", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-3.svg#iefix);}", tree, options))
      .to.equal(".selector {background:url('spec/img-test/some_image_img-3.~C4DC67.svg#iefix');}")
    return

  it "Image path for IE", ->
    expect(fnc.replaceContent(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='spec/img-test/some_image_img-6.png')}", tree, options))
      .to.equal(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='spec/img-test/some_image_img-6.~619E6E.png')}")
    return

  it "Image path for IE (with #hash)", ->
    expect(fnc.replaceContent(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='spec/img-test/some_image_img-3.svg#hash')}", tree, options))
    .to.equal(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='spec/img-test/some_image_img-3.~C4DC67.svg#hash')}")
    return

  it "Base64", ->
    expect(fnc.replaceContent(".selector {background-image:url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/P);}", tree, options))
    .to.equal(".selector {background-image:url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/P);}")
    return

  it "Common svg #hash", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg#iefix);}", tree, options))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.~619E6E.svg#iefix');}")
    return

  it "URL was implant", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.~AAAAAA.svg#iefix);}", tree, options))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.~619E6E.svg#iefix');}")
    return

  it "URL with 2 params in qs", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?qwerty=12345&AAAAAA#iefix);}", tree, options))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.~619E6E.svg?qwerty=12345#iefix');}")
    return

  it "URL with 1 param in qs", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?AAAAAA#iefix);}", tree, options))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.~619E6E.svg#iefix');}")
    return

  it "URL without implant", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?AAAAAA#iefix);}", tree, optionsTestImplant))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.svg?619E6E#iefix');}")
    return

  it "URL without implant, has 2 params in qs, rev is last", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?qwerty=123&AAAAAA);}", tree, optionsTestImplant))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.svg?qwerty=123&619E6E');}")
    return

  it "URL without implant, has 2 params in qs, rev is first", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?AAAAAA&qwerty=123);}", tree, optionsTestImplant))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.svg?qwerty=123&619E6E');}")
    return

  it "URL without implant, has 3 params in qs", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?qwerty2=123&AAAAAA&qwerty=123);}", tree, optionsTestImplant))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.svg?qwerty2=123&qwerty=123&619E6E');}")
    return

  it "URL with empty search", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?);}", tree, optionsTestImplant))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.svg?619E6E');}")
    return

  it "URL with empty search, implant", ->
    expect(fnc.replaceContent(".selector {background:url(spec/img-test/some_image_img-7.svg?);}", tree, options))
    .to.equal(".selector {background:url('spec/img-test/some_image_img-7.~619E6E.svg');}")
    return

  it "Error: empty url", ->
    expect -> fnc.replaceContent(".selector {background:url();}", tree, options)
    .to.throw('Empty URLs are not supported!');
    return

  it "Error: empty src", ->
    expect -> fnc.replaceContent(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src=)}", tree, options)
      .to.throw('Empty URLs are not supported!');
    return

  it "Error: file not exist", ->
    expect -> fnc.replaceContent(".selector {_filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='spec/img-test/some_image_img-8.~C4DC67.svg#hash')}", tree, options)
      .to.throw('File for spec/img-test/some_image_img-8.svg does not exist!');
    return

return

