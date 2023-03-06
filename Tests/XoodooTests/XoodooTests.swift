import XCTest
import Xoodoo

final class XoodooTests: XCTestCase {
    func testPermutation() {
        XCTAssert(Xoodoo().permutations().dropFirst(383).joined().starts(with: [
            0xb0, 0xfa, 0x04, 0xfe, 0xce, 0xd8, 0xd5, 0x42,
            0xe7, 0x2e, 0xc6, 0x29, 0xcf, 0xe5, 0x7a, 0x2a,
            0xa3, 0xeb, 0x36, 0xea, 0x0a, 0x9e, 0x64, 0x14,
            0x1b, 0x52, 0x12, 0xfe, 0x69, 0xff, 0x2e, 0xfe,
            0xa5, 0x6c, 0x82, 0xf1, 0xe0, 0x41, 0x4c, 0xfc,
            0x4f, 0x39, 0x97, 0x15, 0xaf, 0x2f, 0x09, 0xeb,
        ]))
    }
    
    func testMRAC() {
        var state = Xoodoo()
        
        XCTAssertEqual(state.count, 48)
        XCTAssertEqual(state.indices, 0..<48)
        
        XCTAssertEqual(state.index(after: state.startIndex), 1)
        XCTAssertEqual(state.index(before: state.endIndex), 47)
        
        state[43] = 0xff
        XCTAssertEqual(state[43], 0xff)
        state.first = 0xff
        XCTAssertEqual(state.first, 0xff)
        state.last = 0xff
        XCTAssertEqual(state.last, 0xff)
        
        state.withContiguousMutableStorageIfAvailable {
            for (index, element): (_, UInt8) in zip($0.indices, 0...) {
                $0[index] = element
            }
        }
        state.withContiguousStorageIfAvailable {
            XCTAssert($0.elementsEqual(0..<48))
        }
        
        state.withUnsafeMutableBytes {
            $0.copyBytes(from: 1...48)
        }
        state.withUnsafeBytes {
            XCTAssert($0.elementsEqual(1...48))
        }
        
        XCTAssert(state.elementsEqual(1...48))
    }
}

private extension Xoodoo {
    func permutations() -> some Sequence<Self> {
        sequence(state: self, next: {
            $0.permute()
            return $0
        })
    }
}
