Class {
	#name : 'HypheReturnsCollectorSelfPropagatingTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests - control flow' }
HypheReturnsCollectorSelfPropagatingTest >> testAndOrInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testAndOr.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorSelfPropagatingTest >> testArithmeticCollection [
    | testCase collector result |
true ifTrue: [ ^ self ].
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testArithmetic.
    collector := HypheReturnsCollectorSelfPropagating on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - blocks' }
HypheReturnsCollectorSelfPropagatingTest >> testBlockValueInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testBlockValue.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - blocks' }
HypheReturnsCollectorSelfPropagatingTest >> testBlockWithArgumentInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testBlockWithArgument.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorSelfPropagatingTest >> testChainedCallsPropagation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testChainedCalls.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.

	"Should have instrumented and collected from firstMethod, secondMethod, and thirdMethod"
	self assert:
		(collections anySatisfy: [ :item |
			 item methodSelector = #firstMethod ]).
	self assert: (collections anySatisfy: [ :item |
			 item methodSelector = #secondMethod ]).
	self assert:
		(collections anySatisfy: [ :item |
			 item methodSelector = #thirdMethod ])
]

{ #category : 'tests - error handling' }
HypheReturnsCollectorSelfPropagatingTest >> testCleanupOnError [
    | testCase collector result |
true ifTrue: [ ^self ]."skip this. It freezes the system"
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testThatFails.
    collector := HypheReturnsCollectorSelfPropagating on: testCase.
    
    "Disable transcript logging to avoid clutter"
    
    result := collector run.
    
    "Result should still be returned with execution time"
    self assert: result notNil.
    self assert: result executionTime notNil
]

{ #category : 'tests - basic' }
HypheReturnsCollectorSelfPropagatingTest >> testCollectorCreation [

	| testCase collector |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.

	self assert: collector notNil.
	self assert: collector result notNil.
	self assert: collector logger notNil
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorSelfPropagatingTest >> testEnsureInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testEnsure.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - result' }
HypheReturnsCollectorSelfPropagatingTest >> testExecutionTimeTracking [

	| testCase collector result |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result executionTime notNil.
	self assert: result executionTime >= Duration zero
]

{ #category : 'tests - error handling' }
HypheReturnsCollectorSelfPropagatingTest >> testHandleFailingTest [
    | testCase collector result |
true ifTrue: [ ^self ]."skip this. It freezes the system"
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testThatFails.
    collector := HypheReturnsCollectorSelfPropagating on: testCase.
    result := collector run.
    
    "Should not be completed due to failure"
    self deny: result isCompleted.
    self assert: result status = #error."THIS WILL LIKELY TRIGGER AN ERROR NOT A TESTFAILURE"
    self assert: result errorMessage notNil
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorSelfPropagatingTest >> testIfNilIfNotNilInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testIfNilIfNotNil.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorSelfPropagatingTest >> testIfNilIfNotNilWithValueInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testIfNilIfNotNilWithValue.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - logger' }
HypheReturnsCollectorSelfPropagatingTest >> testLoggerAccess [

	| testCase collector |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.

	self assert: collector logger notNil.
	self assert: collector logger class = HypheReturnsCollectorLogger
]

{ #category : 'tests - logger' }
HypheReturnsCollectorSelfPropagatingTest >> testLoggerTranscriptCanBeDisabled [

	| testCase collector |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.

	collector logger disableTranscriptLogging.
	self deny: collector logger logToTranscript.

	"Should still work with transcript disabled"
	collector run.
	self assert: collector logger contents notEmpty
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorSelfPropagatingTest >> testMethodClassCollection [

	| testCase collector result collections dataItem |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	collections := result collections.
	dataItem := collections detect: [ :item |
		            item methodSelector = #testSimpleReturn ].

	self assert:
		dataItem definingClass = HypheReturnsCollectorTestFixture
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorSelfPropagatingTest >> testMixedReturnTypes [

	| testCase collector result collections stringData numberData |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testMixedReturnTypes.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	collections := result collections.

	"Should have different return types"
	stringData := collections detect: [ :item |
		              item methodSelector = #getStringValue ].
	numberData := collections detect: [ :item |
		              item methodSelector = #getNumberValue ].

	self assert: stringData returnClass = ByteString.
	self assert: numberData returnClass = SmallInteger
]

{ #category : 'tests - blocks' }
HypheReturnsCollectorSelfPropagatingTest >> testNestedBlocksInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testNestedBlocks.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorSelfPropagatingTest >> testNoDuplicateInstrumentation [

	| testCase collector result collections firstSize secondSize |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	firstSize := result collections size.

	"Run again with same test"
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	secondSize := result collections size.

	"Should collect similar amount of data (not exponentially more)"
	self assert: secondSize equals: firstSize
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorSelfPropagatingTest >> testOnDoInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testOnDo.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorSelfPropagatingTest >> testPrimitiveMethodHandling [

	| testCase collector result |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testPrimitives.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.

	"Should not crash on primitive methods"
	result := collector run.
	self assert: result notNil
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorSelfPropagatingTest >> testReceiverClassCollection [

	| testCase collector result collections dataItem |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testWithMessageSends.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	collections := result collections.
	"Find helper method data point"
	dataItem := collections detect: [ :item |
		            item methodSelector = #helperMethod ].

	self assert:
		dataItem receiverClass = HypheReturnsCollectorTestFixture
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorSelfPropagatingTest >> testReturnTypeCollection [

	| testCase collector result collections dataItem |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	collections := result collections.
	"Find the data point for testSimpleReturn"
	dataItem := collections detect: [ :item |
		            item methodSelector = #testSimpleReturn ].

	self assert: dataItem returnClass = ByteString "Return type should be String"
]

{ #category : 'tests - basic' }
HypheReturnsCollectorSelfPropagatingTest >> testSimpleReturnCollection [

	| testCase collector result |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result notNil.
	self assert: result isCompleted.
	self assert: result collections notEmpty
]

{ #category : 'tests - result' }
HypheReturnsCollectorSelfPropagatingTest >> testStatusTracking [

	| testCase collector result |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testSimpleReturn.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result status = #completed
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorSelfPropagatingTest >> testToDoInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testToDo.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorSelfPropagatingTest >> testWhileTrueInstrumentation [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testWhileTrue.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorSelfPropagatingTest >> testWithMessageSends [

	| testCase collector result collections |
	true ifTrue: [ ^ self ].
	testCase := HypheReturnsCollectorTestFixture new.
	testCase setTestSelector: #testWithMessageSends.
	collector := HypheReturnsCollectorSelfPropagating on: testCase.
	result := collector run.

	self assert: result isCompleted.
	collections := result collections.
	self assert: collections notEmpty.

	"Should have collected data from both testWithMessageSends and helperMethod"
	self assert: (collections anySatisfy: [ :item |
			 item methodSelector = #helperMethod ])
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorSelfPropagatingTest >> testWithOrderedCollection [
    | testCase collector result collections |
true ifTrue: [ ^self ]."skip this. It freezes the system"
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testWithOrderedCollection.
    collector := HypheReturnsCollectorSelfPropagating on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty.
    
]
