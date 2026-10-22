import Foundation
import Testing

@testable import CoreviaTalkPushKit

@Test func `Round-trip opaque navigation target through notification user info`() {
  let target = CoreviaTalkPushNavigationTarget(
    eventID: "MESSAGE-ID",
    communityID: "community-id",
    channelID: "CHANNEL/GENERAL"
  )

  #expect(
    CoreviaTalkPushNavigationTarget.decodeIfPresent(
      from: [CoreviaTalkPushNavigationTarget.userInfoKey: target.userInfoValue]
    ) == target
  )
  #expect(target.eventID == "MESSAGE-ID")
  #expect(target.channelID == "CHANNEL/GENERAL")
}

@Test func `Reject incomplete or malformed navigation target`() {
  #expect(
    CoreviaTalkPushNavigationTarget.decodeIfPresent(
      from: [
        CoreviaTalkPushNavigationTarget.userInfoKey: [
          "event_id": "message-id",
          "community_id": "community-id",
        ]
      ]
    ) == nil
  )

  #expect(
    CoreviaTalkPushNavigationTarget.decodeIfPresent(
      from: [
        CoreviaTalkPushNavigationTarget.userInfoKey: [
          "event_id": "",
          "community_id": "community-id",
          "channel_id": "channel-id",
        ]
      ]
    ) == nil
  )

  #expect(
    CoreviaTalkPushNavigationTarget.decodeIfPresent(
      from: [
        CoreviaTalkPushNavigationTarget.userInfoKey: [
          "event_id": "message-id",
          "community_id": "community-id",
          "channel_id": "",
        ]
      ]
    ) == nil
  )
}

@Test func `Buffer preserves cold-start target until consumed`() {
  let first = CoreviaTalkPushNavigationTarget(
    eventID: String(repeating: "a", count: 64),
    communityID: "community-id",
    channelID: "123e4567-e89b-42d3-a456-426614174000"
  )
  let second = CoreviaTalkPushNavigationTarget(
    eventID: String(repeating: "b", count: 64),
    communityID: "community-id",
    channelID: "123e4567-e89b-42d3-a456-426614174000"
  )
  let buffer = CoreviaTalkPushNavigationBuffer()

  buffer.record(first)
  buffer.remove(ifMatching: second)
  #expect(buffer.peek() == first)
  #expect(buffer.take() == first)
  #expect(buffer.take() == nil)
}

@Test func `Reply target preserves containing thread through user info and cold-start buffer`() {
  let target = CoreviaTalkPushNavigationTarget(
    eventID: "reply", communityID: "community", channelID: "channel", threadRootID: "parent"
  )
  let decoded = CoreviaTalkPushNavigationTarget.decodeIfPresent(
    from: [CoreviaTalkPushNavigationTarget.userInfoKey: target.userInfoValue]
  )
  #expect(decoded == target)
  let buffer = CoreviaTalkPushNavigationBuffer()
  buffer.record(target)
  #expect(buffer.take() == target)
}

@Test func `Reject malformed optional thread and unknown navigation fields`() {
  let cases: [[String: Any]] = [
    ["thread_root_id": ""], ["thread_root_id": 42], ["unknown": "value"],
  ]
  for extra in cases {
    var raw: [String: Any] = [
      "event_id": "reply", "community_id": "community", "channel_id": "channel",
    ]
    raw.merge(extra) { _, new in new }
    #expect(CoreviaTalkPushNavigationTarget.decodeIfPresent(
      from: [CoreviaTalkPushNavigationTarget.userInfoKey: raw]
    ) == nil)
  }
}

@Test func `Empty reply marker preserves channel navigation`() {
  let thread = CoreviaTalkPushNavigationTarget.threadRootID(in: [["e", "", "", "reply"]])
  #expect(thread == nil)
  let target = CoreviaTalkPushNavigationTarget(
    eventID: "message", communityID: "community", channelID: "channel", threadRootID: thread
  )
  #expect(CoreviaTalkPushNavigationTarget.decodeIfPresent(
    from: [CoreviaTalkPushNavigationTarget.userInfoKey: target.userInfoValue]
  ) == target)
}

@Test func `Thread destination keeps direct parent and broadcast semantics`() {
  let parent = String(repeating: "a", count: 64)
  let tags = [["e", "outer-root", "", "root"], ["e", parent, "", "reply"]]
  #expect(CoreviaTalkPushNavigationTarget.threadRootID(in: tags) == parent)
  #expect(CoreviaTalkPushNavigationTarget.threadRootID(in: tags + [["broadcast", "1"]]) == nil)
  #expect(CoreviaTalkPushNavigationTarget.threadRootID(in: [["e", "outer-root", "", "root"]]) == nil)
}

@Test func `Last valid reply marker wins despite trailing malformed markers`() {
  let first = String(repeating: "a", count: 64)
  let last = String(repeating: "B", count: 64)
  let invalidIDs = ["", "bad", String(repeating: "a", count: 63),
    String(repeating: "a", count: 65), String(repeating: "g", count: 64),
    String(repeating: "é", count: 64)]
  for invalid in invalidIDs {
    let invalidTag = ["e", invalid, "", "reply"]
    #expect(CoreviaTalkPushNavigationTarget.threadRootID(in: [invalidTag]) == nil)
    #expect(CoreviaTalkPushNavigationTarget.threadRootID(in: [
      ["e", first, "", "reply"], ["e", last, "", "reply"], invalidTag,
    ]) == last.lowercased())
  }
}
