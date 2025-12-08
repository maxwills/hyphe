Class {
	#name : 'HypheReturnsCollectorBase',
	#superclass : 'Object',
	#instVars : [
		'methodsToRecord',
		'logger',
		'result',
		'collectionsData',
		'installedLinks',
		'instrumentedMethods',
		'owningProcess'
	],
	#category : 'Hyphe-Collectors',
	#package : 'Hyphe',
	#tag : 'Collectors'
}

{ #category : 'api-instrumentation' }
HypheReturnsCollectorBase >> cleanup [
    "Clean up all instrumentation"
    logger log: 'Cleaning up instrumentation (', instrumentedMethods size asString, ' methods, ', installedLinks size asString, ' links)'.
    
    [ 
        self removeInstrumentation.
        logger log: 'All links uninstalled'
    ] on: Error do: [ :ex |
        Transcript show: 'CRITICAL ERROR during cleanup: '; show: ex messageText; cr.
        logger log: 'CRITICAL ERROR during cleanup: ', ex messageText
    ]
]

{ #category : 'accessing' }
HypheReturnsCollectorBase >> collectionsData [
    ^ collectionsData
]

{ #category : 'initialization' }
HypheReturnsCollectorBase >> initialize [
    super initialize.
    methodsToRecord := OrderedCollection new.
    logger := HypheReturnsCollectorLogger new.
    result := HypheReturnsCollectorResult new.
    collectionsData := HypheInternalCollection new.
    installedLinks := HypheInternalCollection new.
    instrumentedMethods := IdentitySet new.
    owningProcess := nil
]

{ #category : 'api-instrumentation' }
HypheReturnsCollectorBase >> instrumentForRecording [
    "Instrument all methodsToRecord. Override in subclasses."
    self subclassResponsibility
]

{ #category : 'accessing' }
HypheReturnsCollectorBase >> logger [
    ^ logger
]

{ #category : 'accessing' }
HypheReturnsCollectorBase >> methodsToRecord [
    ^ methodsToRecord
]

{ #category : 'api-instrumentation' }
HypheReturnsCollectorBase >> removeInstrumentation [
    "Remove all instrumentation. Override in subclasses."
    self subclassResponsibility
]

{ #category : 'api-configuration' }
HypheReturnsCollectorBase >> reset [
    "Clean up and reset all internal state"
    [ self cleanup ] on: Error do: [ :ex |
        logger log: 'Error during cleanup in reset: ', ex messageText
    ].
    methodsToRecord := OrderedCollection new.
    collectionsData := HypheInternalCollection new.
    installedLinks := HypheInternalCollection new.
    instrumentedMethods := IdentitySet new.
    owningProcess := nil.
    result := HypheReturnsCollectorResult new.
    logger log: '[RESET] Collector reset completed'
]

{ #category : 'accessing' }
HypheReturnsCollectorBase >> result [
    ^ result
]

{ #category : 'api-running' }
HypheReturnsCollectorBase >> run: aBlockOrMethod instrumentForRecording: aBoolean [
    "Run a block or method, optionally instrumenting first"
    | startTime endTime returnValue |
    result status: #running.
    startTime := DateAndTime now.
    owningProcess := Processor activeProcess.
    
    [
        [
            aBoolean ifTrue: [ self instrumentForRecording ].
            
            returnValue := aBlockOrMethod isBlock
                ifTrue: [ aBlockOrMethod value ]
                ifFalse: [ 
                    "Assume it's a compiled method, need receiver"
                    self error: 'Use runTest:selector:instrumentForRecording: for methods'
                ].
            
            result status: #completed.
            logger log: 'Execution completed successfully'
        ] on: Error do: [ :ex |
            result status: #error.
            result errorMessage: ex messageText.
            logger log: 'Error during execution: ', ex messageText
        ]
    ] ensure: [
        aBoolean ifTrue: [ self cleanup ].
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        result collections: collectionsData asArray.
    ].
    
    ^ result
]

{ #category : 'api-running' }
HypheReturnsCollectorBase >> runMultiple: aCollectionOfBlocksOrMethods instrumentForRecording: aBoolean [
    "Run multiple blocks or methods, instrumenting once if requested"
    | startTime endTime |
    result status: #running.
    startTime := DateAndTime now.
    owningProcess := Processor activeProcess.
    
    [
        [
            aBoolean ifTrue: [ self instrumentForRecording ].
            
            aCollectionOfBlocksOrMethods do: [ :blockOrMethod |
                logger log: 'Running: ', blockOrMethod printString.
                blockOrMethod isBlock
                    ifTrue: [ blockOrMethod value ]
                    ifFalse: [ 
                        self error: 'Methods need receiver - use runMultipleTests: instead'
                    ]
            ].
            
            result status: #completed.
            logger log: 'All executions completed successfully'
        ] on: Error do: [ :ex |
            result status: #error.
            result errorMessage: ex messageText.
            logger log: 'Error during multiple execution: ', ex messageText
        ]
    ] ensure: [
        aBoolean ifTrue: [ self cleanup ].
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        result collections: collectionsData asArray.
    ].
    
    ^ result
]

{ #category : 'api-running' }
HypheReturnsCollectorBase >> runMultipleTests: aCollectionOfPairs instrumentForRecording: aBoolean [
    "Run multiple tests given as pairs of (testCase -> selector).
    Sets test selectors internally and uses runCaseForHyphe for proper setup/tearDown."
    | startTime endTime |
    result status: #running.
    startTime := DateAndTime now.
    owningProcess := Processor activeProcess.
    
    [
        [
            aBoolean ifTrue: [ self instrumentForRecording ].
            
            aCollectionOfPairs do: [ :pair |
                | testCase selector |
                testCase := pair key.
                selector := pair value.
                
                "Set the test selector"
                testCase setTestSelector: selector.
                
                logger log: 'Running test: ', testCase class name, '>>', selector.
                
                "Use runCaseForHyphe for proper setup/tearDown"
                testCase runCaseForHyphe
            ].
            
            result status: #completed.
            logger log: 'All tests completed successfully'
        ] on: Error do: [ :ex |
            result status: (ex class name = #TestFailure
                ifTrue: [ #testFailure ]
                ifFalse: [ #error ]).
            result errorMessage: ex messageText.
            logger log: 'Error during multiple tests: ', ex messageText
        ]
    ] ensure: [
        aBoolean ifTrue: [ self cleanup ].
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        result collections: collectionsData asArray.
    ].
    
    ^ result
]

{ #category : 'api-running' }
HypheReturnsCollectorBase >> runTest: aTestCase selector: aSymbol instrumentForRecording: aBoolean [
    "Run a test case with a specific selector.
    Sets the test selector internally and uses runCaseForHyphe for proper setup/tearDown."
    | startTime endTime testReturnValue testMethod |
    result status: #running.
    startTime := DateAndTime now.
    owningProcess := Processor activeProcess.
    
    [
        [
            "Set the test selector on the test case"
            aTestCase setTestSelector: aSymbol.
            
            aBoolean ifTrue: [ self instrumentForRecording ].
            
            testMethod := aTestCase class lookupSelector: aSymbol.
            logger log: 'Running test: ', aTestCase class name, '>>', aSymbol.
            
            "Use runCaseForHyphe to run setUp/tearDown and get actual return value"
            testReturnValue := aTestCase runCaseForHyphe.
            
            result status: #completed.
            logger log: 'Test completed successfully'
        ] on: Error do: [ :ex |
            result status: (ex class name = #TestFailure
                ifTrue: [ #testFailure ]
                ifFalse: [ #error ]).
            result errorMessage: ex messageText.
            logger log: 'Error during test execution: ', ex messageText
        ]
    ] ensure: [
        aBoolean ifTrue: [ self cleanup ].
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        result collections: collectionsData asArray.
    ].
    
    ^ result
]

{ #category : 'api-configuration' }
HypheReturnsCollectorBase >> setMethodsFromPackages: aCollectionOfPackages [
    "Collect all methods from the given packages and store them"
    | methods |
    methods := OrderedCollection new.
    aCollectionOfPackages do: [ :packageName |
        | package |
        package := PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ].
        package ifNotNil: [
            logger log: '[SET] Processing package: ', packageName.
            package definedClasses do: [ :class |
                "Instance methods"
                class methods do: [ :method | methods add: method ].
                "Class-side methods"
                class classSide methods do: [ :method | methods add: method ]
            ]
        ] ifNil: [
            logger log: '[SET] WARNING: Package not found: ', packageName
        ]
    ].
    self setMethodsToRecord: methods.
    logger log: '[SET] Total methods from packages: ', methods size asString
]

{ #category : 'api-configuration' }
HypheReturnsCollectorBase >> setMethodsToRecord: aCollectionOfCompiledMethods [
    "Store the methods to be instrumented and recorded"
    methodsToRecord := aCollectionOfCompiledMethods asOrderedCollection.
    logger log: '[SET] Methods to record: ', methodsToRecord size asString
]
