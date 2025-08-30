//
//  CheckpointBuilder.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-04.
//

@available(iOS 14.0, *)
@MainActor
public class CheckpointBuilder {
    private let name: String
    private let flock: Flock
    private var options = CheckpointOptions()
    private var onClose: (() -> Void)?
    private var onSuccess: ((Flock) -> Void)?
    private var onInvalid: ((Flock) -> Void)?

    init(name: String, flock: Flock) {
        self.name = name
        self.flock = flock
    }

    /**
     Sets the navigate option to true, allowing navigation within existing webViewController.

     - Parameter shouldNavigate: Whether to navigate instead of adding a new placement. Defaults to true.
     - Returns: The builder instance for method chaining.
     */
    @discardableResult
    public func navigate(_ shouldNavigate: Bool = true) -> CheckpointBuilder {
        options = CheckpointOptions(navigate: shouldNavigate)
        return self
    }

    /**
     Sets the onClose callback.

     - Parameter handler: The closure to execute when the placement is closed.
     - Returns: The builder instance for method chaining.
     */
    @discardableResult
    public func onClose(_ handler: @escaping () -> Void) -> CheckpointBuilder {
        onClose = handler
        return self
    }

    /**
     Sets the onSuccess callback.

     - Parameter handler: The closure to execute when the placement reports a success event.
     - Returns: The builder instance for method chaining.
     */
    @discardableResult
    public func onSuccess(_ handler: @escaping (Flock) -> Void) -> CheckpointBuilder {
        onSuccess = handler
        return self
    }

    /**
     Sets the onInvalid callback.

     - Parameter handler: The closure to execute when the placement reports an invalid event.
     - Returns: The builder instance for method chaining.
     */
    @discardableResult
    public func onInvalid(_ handler: @escaping (Flock) -> Void) -> CheckpointBuilder {
        onInvalid = handler
        return self
    }

    /**
     Trigger the checkpoint with the configured options and callbacks.
     */
    public func trigger() {
        flock.triggerCheckpoint(
            checkpointName: name,
            options: options,
            onClose: onClose,
            onSuccess: onSuccess,
            onInvalid: onInvalid
        )
    }
}
