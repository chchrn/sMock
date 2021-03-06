/*
 * MIT License
 *
 * Copyright (c) 2020 Alkenso (Vladimir Vashurkin)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation


// MARK: - Multiple argument match

public extension MatcherType {
    static func splitArgs<T0, T1>(_ matcher0: MatcherType<T0>,
                                  _ matcher1: MatcherType<T1>) -> MatcherType<(T0, T1)> {
        .custom({ matcher0.match($0.0) && matcher1.match($0.1) })
    }
    
    static func splitArgs<T0, T1, T2>(_ matcher0: MatcherType<T0>,
                                      _ matcher1: MatcherType<T1>,
                                      _ matcher2: MatcherType<T2>) -> MatcherType<(T0, T1, T2)> {
        .custom({ matcher0.match($0.0) && matcher1.match($0.1) && matcher2.match($0.2) })
    }
    
    static func splitArgs<T0, T1, T2, T3>(_ matcher0: MatcherType<T0>,
                                          _ matcher1: MatcherType<T1>,
                                          _ matcher2: MatcherType<T2>,
                                          _ matcher3: MatcherType<T3>) -> MatcherType<(T0, T1, T2, T3)> {
        .custom({ matcher0.match($0.0) && matcher1.match($0.1) && matcher2.match($0.2) && matcher3.match($0.3) })
    }
    
    static func splitArgs<T0, T1, T2, T3, T4>(_ matcher0: MatcherType<T0>,
                                              _ matcher1: MatcherType<T1>,
                                              _ matcher2: MatcherType<T2>,
                                              _ matcher3: MatcherType<T3>,
                                              _ matcher4: MatcherType<T4>) -> MatcherType<(T0, T1, T2, T3, T4)> {
        .custom({ matcher0.match($0.0) && matcher1.match($0.1) && matcher2.match($0.2) && matcher3.match($0.3) && matcher4.match($0.4) })
    }
    
    static func splitArgs<T0, T1, T2, T3, T4, T5>(_ matcher0: MatcherType<T0>,
                                                  _ matcher1: MatcherType<T1>,
                                                  _ matcher2: MatcherType<T2>,
                                                  _ matcher3: MatcherType<T3>,
                                                  _ matcher4: MatcherType<T4>,
                                                  _ matcher5: MatcherType<T5>) -> MatcherType<(T0, T1, T2, T3, T4, T5)> {
        .custom({ matcher0.match($0.0) && matcher1.match($0.1) && matcher2.match($0.2) && matcher3.match($0.3) && matcher4.match($0.4) && matcher5.match($0.5) })
    }
}


// MARK: KeyPath, Optional, Cast

public extension MatcherType {
    static func keyPath<Root, Value>(_ keyPath: KeyPath<Root, Value>, _ valueMatcher: MatcherType<Value>) -> MatcherType<Root> {
        .custom { valueMatcher.match($0[keyPath: keyPath]) }
    }
    
    static func keyPath<Root, Value>(_ keyPath: KeyPath<Root, Value>, _ value: Value) -> MatcherType<Root> where Value: Equatable {
        .keyPath(keyPath, .equal(value))
    }
}

public extension MatcherType {
    static func optional(_ matcher: MatcherType<Args?>) -> MatcherType<Args> {
        .custom { matcher.match($0) }
    }
    
    static func isNil<T>() -> MatcherType<Args> where Args == Optional<T> {
        .custom { $0 == nil }
    }
    
    static func notNil<T>() -> MatcherType<Args> where Args == Optional<T> {
        .custom { $0 != nil }
    }
}

public extension MatcherType {
    static func cast<T>(_ matcher: MatcherType<T>) -> MatcherType<Args> {
        .cast(to: T.self, matcher)
    }
    
    static func cast<T>(to type: T.Type, _ matcher: MatcherType<T>) -> MatcherType<Args> {
        .custom {
            guard let arg = $0 as? T else { return false }
            return matcher.match(arg)
        }
    }
}


// MARK: Equatable

public extension MatcherType where Args: Equatable {
    static func equal(_ value: Args) -> MatcherType<Args> {
        .custom({ $0 == value })
    }
    
    static func notEqual(_ value: Args) -> MatcherType<Args> {
        .custom({ $0 != value })
    }
}


// MARK: Comparable

public extension MatcherType where Args: Comparable {
    static func greaterEqual(_ value: Args) -> MatcherType<Args> {
        .custom({ $0 >= value })
    }
    
    static func greater(_ value: Args) -> MatcherType<Args> {
        .custom({ $0 > value })
    }
    
    static func lessEqual(_ value: Args) -> MatcherType<Args> {
        .custom({ $0 <= value })
    }
    
    static func less(_ value: Args) -> MatcherType<Args> {
        .custom({ $0 < value })
    }
}


// MARK: Bool

public extension MatcherType where Args == Bool {
    static func isTrue() -> MatcherType<Args> {
        .custom({ $0 == true })
    }
    
    static func isFalse() -> MatcherType<Args> {
        .custom({ $0 == false })
    }
}


// MARK: String

public extension MatcherType where Args == String {
    static func strCaseEqual<S: StringProtocol>(_ str: S) -> MatcherType<Args> {
        .custom({ $0.compare(str, options: .caseInsensitive) == .orderedSame })
    }
    
    static func strCaseNotEqual<S: StringProtocol>(_ str: S) -> MatcherType<Args> {
        .custom({ $0.compare(str, options: .caseInsensitive) != .orderedSame })
    }
}


// MARK: Result

public extension MatcherType {
    static func success<Success, Failure>(_ matcher: MatcherType<Success>) -> MatcherType<Args> where Args == Result<Success, Failure> {
        .custom({
            switch $0 {
            case .success(let value): return matcher.match(value)
            case .failure: return false
            }
        })
    }
    
    static func failure<Success, Failure>(_ matcher: MatcherType<Failure>) -> MatcherType<Args> where Args == Result<Success, Failure> {
        .custom({
            switch $0 {
            case .success: return false
            case .failure(let error): return matcher.match(error)
            }
        })
    }
}


// MARK: - Collection

public extension MatcherType where Args: Collection, Args.Element: Equatable {
    static func contains(_ element: Args.Element) -> MatcherType<Args> {
        .custom({ $0.contains(element) })
    }
    
    static func containsAllOf<C>(_ subset: C) -> MatcherType<Args> where C: Collection, C.Element == Args.Element {
        .custom({ collection in subset.reduce(true) { $0 && collection.contains($1) } })
    }
    
    static func containsAnyOf<C>(_ subset: C) -> MatcherType<Args> where C: Collection, C.Element == Args.Element {
        .custom({ collection in subset.reduce(false) { $0 || collection.contains($1) } })
    }
    
    static func startsWith<C>(_ prefix: C) -> MatcherType<Args> where C: Collection, C.Element == Args.Element {
        .custom({ $0.starts(with: prefix) })
    }
    
    static func endsWith<C>(_ suffix: C) -> MatcherType<Args> where C: Collection, C.Element == Args.Element {
        .custom({
            guard $0.count < suffix.count else { return false }
            return $0.dropFirst($0.count - suffix.count).elementsEqual(suffix)
        })
    }
}

public extension MatcherType where Args: Collection {
    static func isEmpty() -> MatcherType<Args> {
        .custom({ $0.isEmpty })
    }
    
    static func sizeIs(_ size: Int) -> MatcherType<Args> {
        .custom({ $0.count == size })
    }
    
    static func each(_ matcher: MatcherType<Args.Element>) -> MatcherType<Args> {
        .custom({ $0.reduce(true) { $0 && matcher.match($1) } })
    }
    
    static func atLeastOne(_ matcher: MatcherType<Args.Element>) -> MatcherType<Args> {
        .custom({ $0.reduce(false) { $0 || matcher.match($1) } })
    }
}


// MARK: Element in Collection

public extension MatcherType where Args: Equatable {
    static func inCollection<C: Collection>(_ collection: C) -> MatcherType<Args> where Args == C.Element {
        .custom({ collection.contains($0) })
    }
}
