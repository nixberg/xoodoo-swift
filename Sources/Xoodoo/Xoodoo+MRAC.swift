extension Xoodoo: MutableCollection & RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    @inline(__always)
    public var startIndex: Index {
        0
    }
    
    @inline(__always)
    public var endIndex: Index {
        48
    }
    
    @inline(__always)
    public subscript(position: Index) -> Element {
        get {
            precondition(indices.contains(position))
            return self.withUnsafeBufferPointer {
                $0[position]
            }
        }
        set {
            precondition(indices.contains(position))
            self.withUnsafeMutableBufferPointer {
                $0[position] = newValue
            }
        }
    }
    
    @inline(__always)
    public var first: Element {
        get {
            self[startIndex]
        }
        set {
            self[startIndex] = newValue
        }
    }
    
    @inline(__always)
    public var last: Element {
        get {
            self[endIndex - 1]
        }
        set {
            self[endIndex - 1] = newValue
        }
    }
    
    @inline(__always)
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withUnsafeBufferPointer(body)
    }
    
    @inline(__always)
    public mutating func withContiguousMutableStorageIfAvailable<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withUnsafeMutableBufferPointer { bufferPointer in
            var inoutBufferPointer = bufferPointer
            defer {
                precondition(
                    inoutBufferPointer == bufferPointer,
                    "\(Self.self) \(#function): replacing the buffer is not allowed"
                )
            }
            return try body(&inoutBufferPointer)
        }
    }
}

extension Xoodoo {
    @inline(__always)
    public func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        try withUnsafePointer(to: self) {
            try $0.withMemoryRebound(to: Element.self, capacity: count) {
                try body(UnsafeBufferPointer(start: $0, count: count))
            }
        }
    }
    
    @inline(__always)
    public mutating func withUnsafeMutableBufferPointer<R>(
        _ body: (UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        let count = count
        return try withUnsafeMutablePointer(to: &self) {
            try $0.withMemoryRebound(to: Element.self, capacity: count) {
                try body(UnsafeMutableBufferPointer(start: $0, count: count))
            }
        }
    }
}

private extension UnsafeMutableBufferPointer {
    @inline(__always)
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.baseAddress == rhs.baseAddress && lhs.count == rhs.count
    }
}
