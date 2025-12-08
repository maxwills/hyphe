Class {
	#name : 'HypheReturnsCollectorMessageSendsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests - basic' }
HypheReturnsCollectorMessageSendsTest >> testBasicStaticInstrumentation [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - cleanup' }
HypheReturnsCollectorMessageSendsTest >> testCleanup [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result isCompleted
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorMessageSendsTest >> testDataCollection [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testArithmetic.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty.
    self assert: (result collections allSatisfy: [ :item | 
        item isKindOf: HypheReturnDataItem ])
]

{ #category : 'tests - domain methods' }
HypheReturnsCollectorMessageSendsTest >> testDomainMethodsCollection [
    | testCase collector |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    collector collectDomainMethods.
    
    self assert: collector domainMethods notEmpty
]

{ #category : 'tests - error handling' }
HypheReturnsCollectorMessageSendsTest >> testErrorHandling [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testThatFails.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result notNil.
    self assert: result hasErrors
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorMessageSendsTest >> testInstrumentationCount [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: (collector logger contents includesSubstring: '[COLLECT] Found')
]

{ #category : 'tests - packages' }
HypheReturnsCollectorMessageSendsTest >> testMultiplePackages [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testChainedCalls.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('Hyphe-Tests' 'Hyphe').
    
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorMessageSendsTest >> testWithEmptyPackageList [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #().
    
    result := collector run.
    
    self assert: result isCompleted
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorMessageSendsTest >> testWithNonExistentPackage [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorMessageSends 
        on: testCase 
        forPackages: #('NonExistentPackage123').
    
    result := collector run.
    
    self assert: result isCompleted
]
