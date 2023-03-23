//
//  LRUCache.swift
//  ZIMKit
//
//  Created by Kael Ding on 2023/2/21.
//

import Foundation

class LRUCache<K: Hashable, V> {
    // Node class for the doubly linked list
    class Node {
        let key: K
        var value: V
        var pre: Node? = nil
        var next: Node? = nil
        init(key: K, value: V) {
            self.key = key
            self.value = value
        }
    }
    
    let capacity: UInt
    var nodeMap: [K: Node] = [:]
    var head: Node? = nil
    var tail: Node? = nil
    
    init(capacity: UInt) {
        self.capacity = capacity
    }
    
    func get(_ key: K) -> V? {
        
        // Check if the key is in the cache
        guard let node = nodeMap[key] else {
            return nil
        }
        
        // Move the node to the front of the list
        moveNodeToHead(node)
        
        return node.value
    }
    
    func put(_ key: K, _ value: V) {
        
        // Check if the key is already in the cache
        if let node = nodeMap[key] {
            // Update the node's value
            node.value = value
            
            // Move the node to the front of the list
            moveNodeToHead(node)
            
            return
        }
        
        // Create a new node
        let node = Node(key: key, value: value)
        
        // Add the new node to the front of the list
        addNodeToHead(node)
        
        // Add the new node to the cache
        nodeMap[key] = node
        
        // Remove the least recently used node if the cache is full
        if nodeMap.count > capacity, let node = tail {
            tail = node.pre
            tail?.next = nil
            nodeMap[node.key] = nil
        }
    }
    
    func delete(_ key: K) {
        guard let node = nodeMap[key] else { return }
        
        if head === node {
            head = node.next
        }
        
        if tail === node {
            tail = node.pre
        }
        
        node.pre?.next = node.next
        node.next?.pre = node.pre
                
        nodeMap[key] = nil
    }
    
    func clear() {
        head = nil
        tail = nil
        nodeMap.removeAll()
    }
    
    // MARK: - Private
    private func addNodeToHead(_ node: Node) {
        if head == nil {
            head = node
            tail = node
        } else {
            node.next = head
            head?.pre = node
            head = node
        }
    }
    
    private func moveNodeToHead(_ node: Node) {
        if head === node { return }
        if head === tail { return }
        
        // Move the node to the front of the list
        if node === tail {
            tail = node.pre
            tail?.next = nil
        }
        
        node.pre?.next = node.next
        node.next?.pre = node.pre
        node.pre = nil
        node.next = head
        head?.pre = node
        head = node
    }
}
