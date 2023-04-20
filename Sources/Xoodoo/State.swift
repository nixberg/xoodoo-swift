public struct State {
    private var a: Row = .zero
    private var b: Row = .zero
    private var c: Row = .zero
    
    public init() {}
    
    public mutating func permute() {
        for constant: UInt32 in [
            0x058, 0x038, 0x3c0, 0x0d0, 0x120, 0x014,
            0x060, 0x02c, 0x380, 0x0f0, 0x1a0, 0x012,
        ] {
            let p = (a ^ b ^ c).rotatingLanes(right: 1)
            let e = p.rotated(left: 5) ^ p.rotated(left: 14)
            a ^= e
            b ^= e
            c ^= e
            
            b = b.rotatingLanes(right: 1)
            c = c.rotated(left: 11)
            
            a[0] ^= constant
            
            a ^= ~b & c
            b ^= ~c & a
            c ^= ~a & b
            
            b = b.rotated(left: 1)
            c = c[11, 8, 9, 10, 15, 12, 13, 14, 3, 0, 1, 2, 7, 4, 5, 6]
        }
    }
}

private typealias Row = SIMD4<UInt32>

extension Row {
    @inline(__always)
    fileprivate func rotatingLanes(right count: Int) -> Self {
        assert(count == 1)
        return self[Self(3, 0, 1, 2)]
    }
    
    @inline(__always)
    fileprivate func rotated(left count: Scalar) -> Self {
        self &<< count | self &>> (32 - count)
    }
    
    @inline(__always)
    fileprivate subscript(_ indices: UInt8...) -> Self {
        unsafeBitCast(unsafeBitCast(self, to: SIMD16<UInt8>.self)[SIMD16(indices)], to: Self.self)
    }
}

#if _endian(big)
#error("Big-endian platforms are currently not supported")
#endif
