import Foundation
import Testing

@testable import CoreviaTalkPushKit

@Suite("Bounded native SVG avatars")
struct CoreviaTalkNotificationSVGTests {
  @Test func rendersBasicSVG() throws {
    let svg =
      ##"<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"><rect width="100" height="100" fill="#ff0000"/></svg>"##
    let png = try CoreviaTalkNotificationAvatarLoader.decode(Data(svg.utf8))
    #expect(png.starts(with: [137, 80, 78, 71]))
  }

  @Test func rejectsReferenceCyclesAndEntities() throws {
    for svg in [
      ##"<svg width="100" height="100"><g id="a"><use href="#a"/></g></svg>"##,
      ##"<!DOCTYPE svg [<!ENTITY x "expanded">]><svg width="1" height="1">&x;</svg>"##,
      ##"<svg width="1" height="1"><style>@font-face { src: url(data:font/woff;base64,AAAA); }</style></svg>"##,
    ] {
      #expect(throws: CoreviaTalkNotificationCacheError.self) {
        try CoreviaTalkNotificationSVG.validate(Data(svg.utf8))
      }
    }
  }

  @Test func rejectsDeepDocuments() {
    let svg =
      "<svg>" + String(repeating: "<g>", count: 33) + String(repeating: "</g>", count: 33)
      + "</svg>"
    #expect(throws: CoreviaTalkNotificationCacheError.self) {
      try CoreviaTalkNotificationSVG.validate(Data(svg.utf8))
    }
  }
}
