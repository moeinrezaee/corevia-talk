import Foundation
import Testing

@testable import CoreviaTalkPushKit

@Suite("Interaction deletion deadline")
struct CoreviaTalkInteractionDeletionDeadlineTests {
  @Test("A stalled deletion times out exactly once")
  func stalledDeletionTimesOutExactlyOnce() throws {
    var deletionCompletion: ((Error?) -> Void)?
    var timeoutAction: (() -> Void)?
    var completionErrors: [Error?] = []
    let deadline = CoreviaTalkInteractionDeletionDeadline(
      timeout: 5,
      deleteAllInteractions: { deletionCompletion = $0 },
      scheduleTimeout: { delay, action in
        #expect(delay == 5)
        timeoutAction = action
      }
    )

    deadline.deleteAll { completionErrors.append($0) }

    #expect(completionErrors.isEmpty)
    let fireTimeout = try #require(timeoutAction)
    fireTimeout()
    #expect(completionErrors.count == 1)
    #expect((completionErrors[0] as NSError?)?.code == 1)

    let finishDeletion = try #require(deletionCompletion)
    finishDeletion(nil)
    #expect(completionErrors.count == 1)
  }

  @Test("A completed deletion ignores the later timeout")
  func completedDeletionIgnoresLaterTimeout() throws {
    var deletionCompletion: ((Error?) -> Void)?
    var timeoutAction: (() -> Void)?
    var completionErrors: [Error?] = []
    let deadline = CoreviaTalkInteractionDeletionDeadline(
      timeout: 5,
      deleteAllInteractions: { deletionCompletion = $0 },
      scheduleTimeout: { _, action in timeoutAction = action }
    )

    deadline.deleteAll { completionErrors.append($0) }

    let finishDeletion = try #require(deletionCompletion)
    finishDeletion(nil)
    #expect(completionErrors.count == 1)
    #expect(completionErrors[0] == nil)

    let fireTimeout = try #require(timeoutAction)
    fireTimeout()
    #expect(completionErrors.count == 1)
  }
}
