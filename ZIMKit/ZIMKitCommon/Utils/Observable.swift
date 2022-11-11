//
//  Observable.swift
//  ZIMKitCommon
//
//  Created by Kael Ding on 2022/8/1.
//

import Foundation

@propertyWrapper
public class Observable<T> {

    private var listeners: [((T) -> Void)] = []

    public var wrappedValue: T {
        didSet {
            listeners.forEach {
                $0(wrappedValue)
            }
        }
    }

    public var projectedValue: Observable<T> { return self }

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public func bind(_ listener: @escaping (T) -> Void) {
        listener(wrappedValue)
        self.listeners.append(listener)
    }

    // only bind once, and when call this method, will remove other listeners
    public func bindOnce(_ listener: @escaping (T) -> Void) {
        listener(wrappedValue)
        self.listeners.removeAll()
        self.listeners.append(listener)
    }
}
