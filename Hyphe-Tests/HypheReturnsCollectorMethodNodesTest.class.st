Class {
	#name : 'HypheReturnsCollectorMethodNodesTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests - basic' }
HypheReturnsCollectorMethodNodesTest >> testCollectorCreation [
    | collector |
    collector := HypheReturnsCollectorMethodNodes new.
    
    self assert: collector notNil.
    self assert: collector result notNil.
    self assert: collector logger notNil.
    self assert: collector methodsToRecord isEmpty
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorMethodNodesTest >> testDataCollectionCapturesDefiningClass [
    | collector result testCase testMethod dataItem |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    result := collector runTest: testCase selector: #testSimpleReturn instrumentForRecording: true.
    
    dataItem := result collections detect: [ :item | item methodSelector = #testSimpleReturn ].
    
    self assert: dataItem definingClass = HypheReturnsCollectorTestFixture
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorMethodNodesTest >> testDataCollectionCapturesMethodSelector [
    | collector result testCase testMethod dataItem |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testArithmetic.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testArithmetic.
    
    collector setMethodsToRecord: { testMethod }.
    result := collector runTest: testCase selector: #testArithmetic instrumentForRecording: true.
    
    dataItem := result collections detect: [ :item | item methodSelector = #testArithmetic ].
    
    self assert: dataItem methodSelector = #testArithmetic
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorMethodNodesTest >> testDataCollectionCapturesReceiverClass [
    | collector result testCase testMethod dataItem |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    result := collector runTest: testCase selector: #testSimpleReturn instrumentForRecording: true.
    
    dataItem := result collections detect: [ :item | item methodSelector = #testSimpleReturn ].
    
    self assert: dataItem receiverClass = HypheReturnsCollectorTestFixture
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorMethodNodesTest >> testDataCollectionCapturesReturnValue [
    | collector result testCase testMethod dataItem |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    result := collector runTest: testCase selector: #testSimpleReturn instrumentForRecording: true.
    
    self assert: result collections notEmpty.
    dataItem := result collections detect: [ :item | item methodSelector = #testSimpleReturn ].
    
    self assert: dataItem returnClass = ByteString
]

{ #category : 'tests - result' }
HypheReturnsCollectorMethodNodesTest >> testExecutionTimeTracking [
    | collector result testCase testMethod |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    result := collector runTest: testCase selector: #testSimpleReturn instrumentForRecording: true.
    
    self assert: result executionTime notNil.
    self assert: result executionTime >= Duration zero
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorMethodNodesTest >> testInstrumentMultipleMethods [
    | collector methods |
    collector := HypheReturnsCollectorMethodNodes new.
    methods := {
        HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
        HypheReturnsCollectorTestFixture lookupSelector: #testArithmetic.
        HypheReturnsCollectorTestFixture lookupSelector: #helperMethod
    }.
    
    collector setMethodsToRecord: methods.
    collector instrumentForRecording.
    
    self assert: collector methodsToRecord size equals: 3.
    collector removeInstrumentation
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorMethodNodesTest >> testInstrumentationCleanup [
    | collector testMethod |
    collector := HypheReturnsCollectorMethodNodes new.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    collector instrumentForRecording.
    collector removeInstrumentation.
    
    "Should be clean after removal"
    self assert: collector methodsToRecord notEmpty.
    "Methods are still there but instrumentation is removed"
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorMethodNodesTest >> testManualInstrumentation [
    | collector testMethod |
    collector := HypheReturnsCollectorMethodNodes new.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    collector instrumentForRecording.
    
    self assert: collector methodsToRecord size equals: 1.
    collector removeInstrumentation
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorMethodNodesTest >> testResetFunctionality [
    | collector testMethod |
    collector := HypheReturnsCollectorMethodNodes new.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    collector instrumentForRecording.
    
    collector reset.
    
    self assert: collector methodsToRecord isEmpty.
    self assert: collector collectionsData isEmpty
]

{ #category : 'tests - api' }
HypheReturnsCollectorMethodNodesTest >> testRunBlockWithInstrumentation [
    | collector result testMethod fixture |
    collector := HypheReturnsCollectorMethodNodes new.
    fixture := HypheReturnsCollectorTestFixture new.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    
    result := collector run: [ fixture testSimpleReturn ] instrumentForRecording: true.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - api' }
HypheReturnsCollectorMethodNodesTest >> testRunBlockWithoutInstrumentation [
    | collector result testMethod fixture |
    collector := HypheReturnsCollectorMethodNodes new.
    fixture := HypheReturnsCollectorTestFixture new.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    
    result := collector run: [ fixture testSimpleReturn ] instrumentForRecording: false.
    
    self assert: result isCompleted.
    "No instrumentation, so no collections"
    self assert: result collections isEmpty
]

{ #category : 'tests - api' }
HypheReturnsCollectorMethodNodesTest >> testRunMultipleBlocks [
    | collector result fixture methods |
    collector := HypheReturnsCollectorMethodNodes new.
    fixture := HypheReturnsCollectorTestFixture new.
    methods := {
        HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
        HypheReturnsCollectorTestFixture lookupSelector: #testArithmetic
    }.
    
    collector setMethodsToRecord: methods.
    
    result := collector runMultiple: {
        [ fixture testSimpleReturn ].
        [ fixture testArithmetic ]
    } instrumentForRecording: true.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - api' }
HypheReturnsCollectorMethodNodesTest >> testRunMultipleTests [
    | collector result testCase1 testCase2 methods |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase1 := HypheReturnsCollectorTestFixture new.
    testCase1 setTestSelector: #testSimpleReturn.
    testCase2 := HypheReturnsCollectorTestFixture new.
    testCase2 setTestSelector: #testArithmetic.
    
    methods := {
        HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
        HypheReturnsCollectorTestFixture lookupSelector: #testArithmetic
    }.
    
    collector setMethodsToRecord: methods.
    
    result := collector runMultipleTests: {
        testCase1 -> #testSimpleReturn.
        testCase2 -> #testArithmetic
    } instrumentForRecording: true.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - api' }
HypheReturnsCollectorMethodNodesTest >> testRunTestArithmetic [
    | collector result testCase testMethod |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testArithmetic.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testArithmetic.
    
    collector setMethodsToRecord: { testMethod }.
    
    result := collector runTest: testCase selector: #testArithmetic instrumentForRecording: true.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - api' }
HypheReturnsCollectorMethodNodesTest >> testRunTestWithInstrumentation [
    | collector result testCase testMethod |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    
    result := collector runTest: testCase selector: #testSimpleReturn instrumentForRecording: true.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - basic' }
HypheReturnsCollectorMethodNodesTest >> testSetMethodsFromMultiplePackages [
    | collector |
    collector := HypheReturnsCollectorMethodNodes new.
    
    collector setMethodsFromPackages: #('Hyphe-Tests' 'Hyphe').
    
    self assert: collector methodsToRecord notEmpty
]

{ #category : 'tests - basic' }
HypheReturnsCollectorMethodNodesTest >> testSetMethodsFromPackages [
    | collector |
    collector := HypheReturnsCollectorMethodNodes new.
    
    collector setMethodsFromPackages: #('Hyphe-Tests').
    
    self assert: collector methodsToRecord notEmpty.
    self assert: (collector methodsToRecord allSatisfy: [ :m | m isCompiledMethod ])
]

{ #category : 'tests - basic' }
HypheReturnsCollectorMethodNodesTest >> testSetMethodsToRecord [
    | collector methods |
    collector := HypheReturnsCollectorMethodNodes new.
    methods := HypheReturnsCollectorTestFixture methods first: 3.
    
    collector setMethodsToRecord: methods.
    
    self assert: collector methodsToRecord size equals: 3.
    self assert: (collector methodsToRecord allSatisfy: [ :m | m isCompiledMethod ])
]

{ #category : 'tests - comparison' }
HypheReturnsCollectorMethodNodesTest >> testSimilarToStaticCollector [
    | methodNodesCollector staticCollector testCase1 testCase2 result1 result2 |
    
    "Setup method nodes collector"
    methodNodesCollector := HypheReturnsCollectorMethodNodes new.
    methodNodesCollector setMethodsFromPackages: #('Hyphe-Tests').
    testCase1 := HypheReturnsCollectorTestFixture new.
    testCase1 setTestSelector: #testSimpleReturn.
    result1 := methodNodesCollector runTest: testCase1 selector: #testSimpleReturn instrumentForRecording: true.
    
    "Setup static collector for comparison"
    testCase2 := HypheReturnsCollectorTestFixture new.
    testCase2 setTestSelector: #testSimpleReturn.
    staticCollector := HypheReturnsCollectorStatic on: testCase2 forPackages: #('Hyphe-Tests').
    result2 := staticCollector run.
    
    "Both should complete successfully"
    self assert: result1 isCompleted.
    self assert: result2 isCompleted.
    "Both should collect data"
    self assert: result1 collections notEmpty.
    self assert: result2 collections notEmpty
]

{ #category : 'tests - result' }
HypheReturnsCollectorMethodNodesTest >> testStatusTracking [
    | collector result testCase testMethod |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    testMethod := HypheReturnsCollectorTestFixture lookupSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: { testMethod }.
    result := collector runTest: testCase selector: #testSimpleReturn instrumentForRecording: true.
    
    self assert: result status = #completed
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorMethodNodesTest >> testWithChainedMethodCalls [
    | collector result testCase methods |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testChainedCalls.
    
    methods := {
        HypheReturnsCollectorTestFixture lookupSelector: #testChainedCalls.
        HypheReturnsCollectorTestFixture lookupSelector: #firstMethod.
        HypheReturnsCollectorTestFixture lookupSelector: #secondMethod.
        HypheReturnsCollectorTestFixture lookupSelector: #thirdMethod
    }.
    
    collector setMethodsToRecord: methods.
    result := collector runTest: testCase selector: #testChainedCalls instrumentForRecording: true.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty.
    "Should capture all method returns"
    self assert: (result collections anySatisfy: [ :item | item methodSelector = #testChainedCalls ]).
    self assert: (result collections anySatisfy: [ :item | item methodSelector = #firstMethod ]).
    self assert: (result collections anySatisfy: [ :item | item methodSelector = #secondMethod ]).
    self assert: (result collections anySatisfy: [ :item | item methodSelector = #thirdMethod ])
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorMethodNodesTest >> testWithEmptyMethodsList [
    | collector result testCase |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector setMethodsToRecord: {}.
    result := collector runTest: testCase selector: #testSimpleReturn instrumentForRecording: true.
    
    self assert: result isCompleted.
    "No methods to instrument, so no collections"
    self assert: result collections isEmpty
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorMethodNodesTest >> testWithMixedReturnTypes [
    | collector result testCase methods stringData numberData |
    collector := HypheReturnsCollectorMethodNodes new.
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testMixedReturnTypes.
    
    methods := {
        HypheReturnsCollectorTestFixture lookupSelector: #testMixedReturnTypes.
        HypheReturnsCollectorTestFixture lookupSelector: #getStringValue.
        HypheReturnsCollectorTestFixture lookupSelector: #getNumberValue
    }.
    
    collector setMethodsToRecord: methods.
    result := collector runTest: testCase selector: #testMixedReturnTypes instrumentForRecording: true.
    
    self assert: result isCompleted.
    stringData := result collections detect: [ :item | item methodSelector = #getStringValue ].
    numberData := result collections detect: [ :item | item methodSelector = #getNumberValue ].
    
    self assert: stringData returnClass = ByteString.
    self assert: numberData returnClass = SmallInteger
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorMethodNodesTest >> testWithNonExistentPackage [
    | collector |
    collector := HypheReturnsCollectorMethodNodes new.
    
    collector setMethodsFromPackages: #('NonExistentPackage123').
    
    self assert: collector methodsToRecord isEmpty
]
