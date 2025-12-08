Class {
	#name : 'HypheReturnDataProcessorTest',
	#superclass : 'TestCase',
	#instVars : [
		'testData',
		'processor'
	],
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'helpers' }
HypheReturnDataProcessorTest >> createItemWithReceiver: aReceiverClass selector: aSelector defining: aDefiningClass returning: aReturnClass [
    ^ HypheReturnDataItem new
        receiverClass: aReceiverClass;
        methodSelector: aSelector;
        definingClass: aDefiningClass;
        returnClass: aReturnClass;
        yourself
]

{ #category : 'helpers' }
HypheReturnDataProcessorTest >> createItemWithReceiver: aReceiverClass selector: aSelector returning: aReturnClass [
    | definingClass |
    definingClass := aReceiverClass lookupSelector: aSelector.
    definingClass := definingClass 
        ifNotNil: [ definingClass methodClass ]
        ifNil: [ aReceiverClass ].
    ^ HypheReturnDataItem new
        receiverClass: aReceiverClass;
        methodSelector: aSelector;
        definingClass: definingClass;
        returnClass: aReturnClass;
        yourself
]

{ #category : 'running' }
HypheReturnDataProcessorTest >> setUp [
    super setUp.
    testData := OrderedCollection new
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testByPackageDictionaryBuilt [
    | result |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #size 
        returning: SmallInteger).
    
    result := HypheReturnDataProcessor process: testData.
    
    self assert: result byPackage isNotNil.
    self assert: result byPackage isDictionary.
    self deny: result byPackage isEmpty
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testByPackageGroupsItemsFromSamePackage [
    | result item1 item2 packageName items |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #size 
        returning: SmallInteger).
    
    result := HypheReturnDataProcessor process: testData.
    
    item1 := result at: 'String>>size'.
    item2 := result at: 'Array>>size'.
    packageName := item1 package.
    
    "If both have same package, they should be grouped together"
    (item1 package = item2 package) ifTrue: [
        items := result byPackage at: packageName.
        self assert: items size >= 2.
        self assert: (items includes: item1).
        self assert: (items includes: item2) ]
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testByPackageWithDifferentPackages [
    | result |
    "Add methods that might be from different packages"
    testData add: (self 
        createItemWithReceiver: OrderedCollection 
        selector: #add: 
        returning: Object).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    
    result := HypheReturnDataProcessor process: testData.
    
    "Should have at least one package"
    self deny: result byPackage isEmpty.
    
    "Each package should have a collection of items"
    result byPackage valuesDo: [ :items |
        self assert: items isCollection.
        self deny: items isEmpty.
        items do: [ :item |
            self assert: item class equals: HypheProcessedReturnsItem ] ]
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testByReceiverClassDictionaryBuilt [
    | result |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #at: 
        returning: Object).
    
    result := HypheReturnDataProcessor process: testData.
    
    self assert: result byReceiverClass isNotNil.
    self assert: result byReceiverClass isDictionary.
    self assert: result byReceiverClass keys size equals: 2.
    self assert: (result byReceiverClass keys includes: 'String').
    self assert: (result byReceiverClass keys includes: 'Array')
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testByReceiverClassGroupsCorrectly [
    | result stringItems |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: Character).
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #size 
        returning: SmallInteger).
    
    result := HypheReturnDataProcessor process: testData.
    
    stringItems := result byReceiverClass at: 'String'.
    self assert: stringItems size equals: 2.
    self assert: (stringItems allSatisfy: [ :item | item receiverClass = String ])
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testByReceiverClassSingleMethodPerClass [
    | result |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #at: 
        returning: Object).
    testData add: (self 
        createItemWithReceiver: OrderedCollection 
        selector: #add: 
        returning: Object).
    
    result := HypheReturnDataProcessor process: testData.
    
    self assert: result byReceiverClass keys size equals: 3.
    self assert: (result byReceiverClass at: 'String') size equals: 1.
    self assert: (result byReceiverClass at: 'Array') size equals: 1.
    self assert: (result byReceiverClass at: 'OrderedCollection') size equals: 1
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testHypheProcessedReturnsDictionary [
    | processed item |
    processed := HypheProcessedReturns new.
    
    self assert: processed keys isEmpty.
    
    item := HypheProcessedReturnsItem new
        receiverClass: String
        methodSelector: #size
        definingClass: Collection.
    
    processed at: 'String>>size' put: item.
    
    self assert: processed keys size equals: 1.
    self assert: (processed at: 'String>>size') equals: item.
    self assert: (processed at: 'String>>size' ifAbsent: [ nil ]) equals: item.
    self assert: (processed at: 'NonExistent' ifAbsent: [ #notFound ]) equals: #notFound
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testHypheProcessedReturnsItemInitialization [
    | item info |
    item := HypheProcessedReturnsItem new
        receiverClass: String
        methodSelector: #size
        definingClass: Collection.
    
    self assert: item receiverClass equals: String.
    self assert: item methodSelector equals: #size.
    self assert: item definingClass equals: Collection.
    self assert: item returnsInfo isEmpty.
    
    info := HypheReturnsInfo new
        returnClass: SmallInteger
        count: 1
        percentage: 1.0.
    item addReturnsInfo: info.
    
    self assert: item returnsInfo size equals: 1.
    self assert: item returnsInfo first equals: info
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testHypheReturnsInfoInitialization [
    | info |
    info := HypheReturnsInfo new
        returnClass: String
        count: 5
        percentage: 0.25.
    
    self assert: info returnClass equals: String.
    self assert: info count equals: 5.
    self assert: info percentage equals: 0.25
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testItemPackageAccessor [
    | result item |
    testData add: (self 
        createItemWithReceiver: OrderedCollection 
        selector: #add: 
        returning: Object).
    
    result := HypheReturnDataProcessor process: testData.
    item := result at: 'OrderedCollection>>add:'.
    
    self assert: item package isNotNil.
    self assert: item package isString.
    self deny: item package isEmpty
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeComplexScenario [
    | result1 result2 testData2 item returnsInfo |
    "Result 1: String>>size with SmallInteger(4) and LargePositiveInteger(2)"
    4 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: SmallInteger) ].
    2 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: LargePositiveInteger) ].
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #at: 
        returning: Object).
    
    "Result 2: String>>size with SmallInteger(3) and Object(1), plus OrderedCollection>>add:"
    testData2 := OrderedCollection new.
    3 timesRepeat: [
        testData2 add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: SmallInteger) ].
    testData2 add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: Object).
    testData2 add: (self 
        createItemWithReceiver: OrderedCollection 
        selector: #add: 
        returning: Object).
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: testData2.
    
    result1 merge: result2.
    
    "Should have 3 different method keys"
    self assert: result1 keys size equals: 3.
    
    "Check String>>size merged correctly"
    item := result1 at: 'String>>size'.
    self assert: item returnsInfo size equals: 3.
    
    "SmallInteger: 4+3=7 out of 10 total"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = SmallInteger ].
    self assert: returnsInfo count equals: 7.
    self assert: returnsInfo percentage equals: 0.7.
    
    "LargePositiveInteger: 2 out of 10"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = LargePositiveInteger ].
    self assert: returnsInfo count equals: 2.
    self assert: returnsInfo percentage equals: 0.2.
    
    "Object: 1 out of 10"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = Object ].
    self assert: returnsInfo count equals: 1.
    self assert: returnsInfo percentage equals: 0.1
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeFractionalPercentages [

	| result1 result2 testData2 item totalPercentage |
	"Create scenario with thirds"
	testData add: (self
			 createItemWithReceiver: String
			 selector: #at:
			 returning: Character).

	testData2 := OrderedCollection new.
	2 timesRepeat: [
			testData2 add:
				(self
					 createItemWithReceiver: String
					 selector: #at:
					 returning: String) ].

	result1 := HypheReturnDataProcessor process: testData.
	result2 := HypheReturnDataProcessor process: testData2.

	result1 merge: result2.

	item := result1 at: 'String>>at:'.

	"All percentages should be floats, not fractions"
	item returnsInfo do: [ :ri |
		self assert: (ri percentage isKindOf: Float) ].

	"Sum should be 1.0"
	totalPercentage := item returnsInfo sum: [ :ri | ri percentage ].
	self assert: (totalPercentage - 1.0) abs < 0.0001
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeIntoEmptyResult [
    | result1 result2 emptyData item |
    emptyData := OrderedCollection new.
    
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    
    result1 := HypheReturnDataProcessor process: emptyData.
    result2 := HypheReturnDataProcessor process: testData.
    
    result1 merge: result2.
    
    self assert: result1 keys size equals: 1.
    item := result1 at: 'String>>size'.
    self assert: item returnsInfo size equals: 1.
    self assert: item returnsInfo first count equals: 1
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeNonOverlappingKeys [
    | result1 result2 testData2 |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    
    testData2 := OrderedCollection new.
    testData2 add: (self 
        createItemWithReceiver: Array 
        selector: #at: 
        returning: Object).
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: testData2.
    
    result1 merge: result2.
    
    self assert: result1 keys size equals: 2.
    self assert: (result1 keys includes: 'String>>size').
    self assert: (result1 keys includes: 'Array>>at:')
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeOrderIndependence [
    | result1a result1b result2a result2b data1 data2 item1 item2 |
    "Create two identical datasets"
    data1 := OrderedCollection new.
    data1 add: (self createItemWithReceiver: String selector: #size returning: SmallInteger).
    data1 add: (self createItemWithReceiver: String selector: #size returning: SmallInteger).
    
    data2 := OrderedCollection new.
    data2 add: (self createItemWithReceiver: String selector: #size returning: LargePositiveInteger).
    
    "Process in different orders"
    result1a := HypheReturnDataProcessor process: data1.
    result2a := HypheReturnDataProcessor process: data2.
    result1a merge: result2a.
    
    result1b := HypheReturnDataProcessor process: data2.
    result2b := HypheReturnDataProcessor process: data1.
    result1b merge: result2b.
    
    "Results should be equivalent"
    item1 := result1a at: 'String>>size'.
    item2 := result1b at: 'String>>size'.
    
    self assert: item1 returnsInfo size equals: item2 returnsInfo size.
    self assert: (item1 returnsInfo sum: [ :ri | ri count ]) equals: (item2 returnsInfo sum: [ :ri | ri count ])
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeOverlappingKeysDifferentReturnTypes [
    | result1 result2 testData2 item returnsInfo |
    2 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: SmallInteger) ].
    
    testData2 := OrderedCollection new.
    3 timesRepeat: [
        testData2 add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: LargePositiveInteger) ].
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: testData2.
    
    result1 merge: result2.
    
    item := result1 at: 'String>>size'.
    self assert: item returnsInfo size equals: 2.
    
    "SmallInteger: 2 out of 5 = 40%"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = SmallInteger ].
    self assert: returnsInfo count equals: 2.
    self assert: returnsInfo percentage equals: 0.4.
    
    "LargePositiveInteger: 3 out of 5 = 60%"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = LargePositiveInteger ].
    self assert: returnsInfo count equals: 3.
    self assert: returnsInfo percentage equals: 0.6
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeOverlappingKeysSameReturnType [
    | result1 result2 testData2 item returnsInfo |
    2 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: SmallInteger) ].
    
    testData2 := OrderedCollection new.
    3 timesRepeat: [
        testData2 add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: SmallInteger) ].
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: testData2.
    
    result1 merge: result2.
    
    self assert: result1 keys size equals: 1.
    item := result1 at: 'String>>size'.
    self assert: item returnsInfo size equals: 1.
    returnsInfo := item returnsInfo first.
    self assert: returnsInfo count equals: 5.
    self assert: returnsInfo percentage equals: 1.0
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergePercentagesSumToOne [
    | result1 result2 testData2 item totalPercentage |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: Character).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: String).
    
    testData2 := OrderedCollection new.
    testData2 add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: Object).
    testData2 add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: Character).
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: testData2.
    
    result1 merge: result2.
    
    item := result1 at: 'String>>at:'.
    totalPercentage := item returnsInfo sum: [ :ri | ri percentage ].
    self assert: (totalPercentage - 1.0) abs < 0.0001
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergePreservesDefiningClass [

	| result1 result2 testData2 item |
	testData add: (self
			 createItemWithReceiver: String
			 selector: #size
			 returning: SmallInteger).

	testData2 := OrderedCollection new.
	testData2 add: (self
			 createItemWithReceiver: String
			 selector: #size
			 returning: SmallInteger).

	result1 := HypheReturnDataProcessor process: testData.
	result2 := HypheReturnDataProcessor process: testData2.

	result1 merge: result2.

	item := result1 at: 'String>>size'.
	self assert: item receiverClass equals: String.
	self assert: item methodSelector equals: #size.
	self assert: item definingClass equals: ArrayedCollection 
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testMergeRebuildsOrganizedViews [
    | result1 result2 testData2 |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    
    testData2 := OrderedCollection new.
    testData2 add: (self 
        createItemWithReceiver: Array 
        selector: #at: 
        returning: Object).
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: testData2.
    
    result1 merge: result2.
    
    "Both receiver classes should be present"
    self assert: (result1 byReceiverClass keys includes: 'String').
    self assert: (result1 byReceiverClass keys includes: 'Array').
    
    "byPackage should also be updated"
    self deny: result1 byPackage isEmpty
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeWithEmptyResult [
    | result1 result2 emptyData |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    
    emptyData := OrderedCollection new.
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: emptyData.
    
    result1 merge: result2.
    
    self assert: result1 keys size equals: 1.
    self assert: (result1 at: 'String>>size') returnsInfo size equals: 1
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMergeWithManyReturnTypes [
    | result1 result2 testData2 item |
    "Result 1: 5 different return types"
    testData add: (self createItemWithReceiver: Array selector: #collect: returning: Array).
    testData add: (self createItemWithReceiver: Array selector: #collect: returning: OrderedCollection).
    testData add: (self createItemWithReceiver: Array selector: #collect: returning: Set).
    testData add: (self createItemWithReceiver: Array selector: #collect: returning: Dictionary).
    testData add: (self createItemWithReceiver: Array selector: #collect: returning: ByteArray).
    
    "Result 2: 3 new return types + 2 existing"
    testData2 := OrderedCollection new.
    testData2 add: (self createItemWithReceiver: Array selector: #collect: returning: Array).
    testData2 add: (self createItemWithReceiver: Array selector: #collect: returning: String).
    testData2 add: (self createItemWithReceiver: Array selector: #collect: returning: Symbol).
    testData2 add: (self createItemWithReceiver: Array selector: #collect: returning: OrderedCollection).
    testData2 add: (self createItemWithReceiver: Array selector: #collect: returning: SmallInteger).
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: testData2.
    
    result1 merge: result2.
    
    item := result1 at: 'Array>>collect:'.
    "Should have 8 unique return types"
    self assert: item returnsInfo size equals: 8.
    
    "Total should be 10 items"
    self assert: (item returnsInfo sum: [ :ri | ri count ]) equals: 10
]

{ #category : 'tests-merging' }
HypheReturnDataProcessorTest >> testMultipleMergesInSequence [
    | result1 result2 result3 data2 data3 item returnsInfo |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    
    data2 := OrderedCollection new.
    data2 add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    data2 add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: LargePositiveInteger).
    
    data3 := OrderedCollection new.
    2 timesRepeat: [
        data3 add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: Object) ].
    
    result1 := HypheReturnDataProcessor process: testData.
    result2 := HypheReturnDataProcessor process: data2.
    result3 := HypheReturnDataProcessor process: data3.
    
    result1 merge: result2.
    result1 merge: result3.
    
    item := result1 at: 'String>>size'.
    self assert: item returnsInfo size equals: 3.
    
    "Total: 1+1=2 SmallInteger, 1 LargePositiveInteger, 2 Object = 5 total"
    "SmallInteger: 2/5 = 0.4"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = SmallInteger ].
    self assert: returnsInfo count equals: 2.
    self assert: returnsInfo percentage equals: 0.4.
    
    "LargePositiveInteger: 1/5 = 0.2"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = LargePositiveInteger ].
    self assert: returnsInfo count equals: 1.
    self assert: returnsInfo percentage equals: 0.2.
    
    "Object: 2/5 = 0.4"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = Object ].
    self assert: returnsInfo count equals: 2.
    self assert: returnsInfo percentage equals: 0.4
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testMultipleMethodsSameReceiverClass [
    | result stringItems |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: Character).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #isEmpty 
        returning: Boolean).
    
    result := HypheReturnDataProcessor process: testData.
    
    stringItems := result byReceiverClass at: 'String'.
    self assert: stringItems size equals: 3.
    
    "Check all method selectors are different"
    self assert: (stringItems collect: [ :item | item methodSelector ]) asSet size equals: 3
]

{ #category : 'tests-organization' }
HypheReturnDataProcessorTest >> testPackageResolution [
    | result item |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    
    result := HypheReturnDataProcessor process: testData.
    item := result at: 'String>>size'.
    
    "Package should be resolved"
    self assert: item package isNotNil.
    self assert: item package isString
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessEmptyCollection [
    | result |
    result := HypheReturnDataProcessor process: testData.
    
    self assert: result keys isEmpty
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessMultipleMethods [
    | result sizeItem atItem |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: OrderedCollection 
        selector: #at: 
        returning: Object).
    testData add: (self 
        createItemWithReceiver: OrderedCollection 
        selector: #at: 
        returning: String).
    
    result := HypheReturnDataProcessor process: testData.
    
    self assert: result keys size equals: 2.
    self assert: (result keys includes: 'String>>size').
    self assert: (result keys includes: 'OrderedCollection>>at:').
    
    sizeItem := result at: 'String>>size'.
    self assert: sizeItem returnsInfo size equals: 1.
    
    atItem := result at: 'OrderedCollection>>at:'.
    self assert: atItem returnsInfo size equals: 2
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessMultipleReturnTypes [
    | result item returnsInfo |
    2 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: SmallInteger) ].
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: LargePositiveInteger).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: LargePositiveInteger).
    
    result := HypheReturnDataProcessor process: testData.
    
    item := result at: 'String>>size'.
    self assert: item returnsInfo size equals: 2.
    
    "Find SmallInteger returns info"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = SmallInteger ].
    self assert: returnsInfo count equals: 2.
    self assert: returnsInfo percentage equals: 0.5.
    
    "Find LargePositiveInteger returns info"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = LargePositiveInteger ].
    self assert: returnsInfo count equals: 2.
    self assert: returnsInfo percentage equals: 0.5
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessMultipleSameReturnType [
    | result item returnsInfo |
    3 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: String 
            selector: #size 
            returning: SmallInteger) ].
    
    result := HypheReturnDataProcessor process: testData.
    
    item := result at: 'String>>size'.
    self assert: item returnsInfo size equals: 1.
    returnsInfo := item returnsInfo first.
    self assert: returnsInfo returnClass equals: SmallInteger.
    self assert: returnsInfo count equals: 3.
    self assert: returnsInfo percentage equals: 1.0
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessPercentagesSumToOne [
    | result item totalPercentage |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: Character).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: String).
    testData add: (self 
        createItemWithReceiver: String 
        selector: #at: 
        returning: Object).
    
    result := HypheReturnDataProcessor process: testData.
    item := result at: 'String>>at:'.
    
    totalPercentage := item returnsInfo sum: [ :ri | ri percentage ].
    self assert: totalPercentage equals: 1.0
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessSameMethodDifferentReceivers [
    | result |
    testData add: (self 
        createItemWithReceiver: String 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #size 
        returning: SmallInteger).
    testData add: (self 
        createItemWithReceiver: OrderedCollection 
        selector: #size 
        returning: SmallInteger).
    
    result := HypheReturnDataProcessor process: testData.
    
    "Each receiver class should have its own entry"
    self assert: result keys size equals: 3.
    self assert: (result keys includes: 'String>>size').
    self assert: (result keys includes: 'Array>>size').
    self assert: (result keys includes: 'OrderedCollection>>size')
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessSingleMethodSingleReturnType [

	| result item |
	testData add: (self
			 createItemWithReceiver: String
			 selector: #size
			 returning: SmallInteger).

	result := HypheReturnDataProcessor process: testData.

	self assert: result keys size equals: 1.
	item := result at: 'String>>size'.
	self assert: item receiverClass equals: String.
	self assert: item methodSelector equals: #size.
	self assert: item definingClass equals: ArrayedCollection ."this might change in other versions of Pharo"
	self assert: item returnsInfo size equals: 1.
	self assert: item returnsInfo first returnClass equals: SmallInteger.
	self assert: item returnsInfo first count equals: 1.
	self assert: item returnsInfo first percentage equals: 1.0
]

{ #category : 'tests' }
HypheReturnDataProcessorTest >> testProcessUnevenPercentages [
    | result item returnsInfo |
    6 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: Array 
            selector: #at: 
            returning: String) ].
    3 timesRepeat: [
        testData add: (self 
            createItemWithReceiver: Array 
            selector: #at: 
            returning: SmallInteger) ].
    testData add: (self 
        createItemWithReceiver: Array 
        selector: #at: 
        returning: Object).
    
    result := HypheReturnDataProcessor process: testData.
    
    item := result at: 'Array>>at:'.
    self assert: item returnsInfo size equals: 3.
    
    "String should be 60%"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = String ].
    self assert: returnsInfo count equals: 6.
    self assert: returnsInfo percentage equals: 0.6.
    
    "SmallInteger should be 30%"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = SmallInteger ].
    self assert: returnsInfo count equals: 3.
    self assert: returnsInfo percentage equals: 0.3.
    
    "Object should be 10%"
    returnsInfo := item returnsInfo detect: [ :ri | ri returnClass = Object ].
    self assert: returnsInfo count equals: 1.
    self assert: returnsInfo percentage equals: 0.1
]
