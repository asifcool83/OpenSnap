import Testing
@testable import OpenSnap

struct SmartSnapControllerTests {
    @Test func repeatedSameSideCyclesThroughDefaultSteps() {
        var controller = SmartSnapController()

        #expect(controller.nextStep(for: .left) == .sixtyPercent)
        #expect(controller.nextStep(for: .left) == .half)
        #expect(controller.nextStep(for: .left) == .third)
        #expect(controller.nextStep(for: .left) == .quarter)
        #expect(controller.nextStep(for: .left) == .sixtyPercent)
    }

    @Test func changingSidesRestartsCycle() {
        var controller = SmartSnapController()

        #expect(controller.nextStep(for: .left) == .sixtyPercent)
        #expect(controller.nextStep(for: .left) == .half)
        #expect(controller.nextStep(for: .right) == .sixtyPercent)
    }

    @Test func resetRestartsCycle() {
        var controller = SmartSnapController()

        _ = controller.nextStep(for: .left)
        _ = controller.nextStep(for: .left)
        controller.reset()

        #expect(controller.nextStep(for: .left) == .sixtyPercent)
    }
}
