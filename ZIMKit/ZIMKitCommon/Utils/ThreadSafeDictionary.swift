//
//  ThreadSafeDictionary.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/10/17.
//

import Foundation

public class ThreadSafeDictionary<V: Hashable, T>: Collection {
    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue",
                                                attributes: .concurrent)

    init(dict: [V : T] = [V: T]()) {
        self.dictionary = dict
    }

    public var startIndex: Dictionary<V, T>.Index {
        concurrentQueue.sync {
            self.dictionary.startIndex
        }
    }

    public var endIndex: Dictionary<V, T>.Index {
        concurrentQueue.sync {
            self.dictionary.endIndex
        }
    }

    public func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        concurrentQueue.sync {
            self.dictionary.index(after: i)
        }
    }

    public var count: Int {
        concurrentQueue.sync {
            self.dictionary.count
        }
    }

    public var isEmpty: Bool {
        concurrentQueue.sync {
            self.dictionary.isEmpty
        }
    }

    public var keys: Dictionary<V, T>.Keys {
        concurrentQueue.sync {
            self.dictionary.keys
        }
    }

    public var values: Dictionary<V, T>.Values {
        concurrentQueue.sync {
            self.dictionary.values
        }
    }

    public subscript(key: V) -> T? {
        get {
            concurrentQueue.sync {
                self.dictionary[key]
            }
        }
        set {
            concurrentQueue.async(flags: .barrier) { [weak self] in
                self?.dictionary[key] = newValue
            }
        }
    }

    public subscript(position: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        concurrentQueue.sync {
            self.dictionary[position]
        }
    }

    public func removeValue(forKey key: V) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    public func removeAll() {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeAll()
        }
    }
}
