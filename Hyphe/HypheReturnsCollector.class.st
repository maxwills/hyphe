Class {
	#name : 'HypheReturnsCollector',
	#superclass : 'Object',
	#instVars : [
		'testCase',
		'logger',
		'result',
		'instrumentedMethods',
		'installedLinks',
		'collectionsData',
		'methodToCompiledMethod'
	],
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'instance creation' }
HypheReturnsCollector class >> on: aTestCase [
    ^ self new initializeWith: aTestCase
]

{ #category : 'cleanup' }
HypheReturnsCollector >> cleanup [
    logger log: 'Cleaning up instrumentation (', instrumentedMethods size asString, ' methods, ', installedLinks size asString, ' links)'.
    
    [ 
        installedLinks do: [ :link | 
            [ link uninstall ] on: Error do: [ :ex | 
                logger log: 'Error uninstalling link: ', ex messageText 
            ]
        ].
        
        installedLinks := OrderedCollection new.
        logger log: 'All links uninstalled'
    ] on: Error do: [ :ex |
        Transcript show: 'CRITICAL ERROR during cleanup: '; show: ex messageText; cr.
        logger log: 'CRITICAL ERROR during cleanup: ', ex messageText
    ]
]

{ #category : 'initialization' }
HypheReturnsCollector >> initializeWith: aTestCase [
    testCase := aTestCase.
    logger := HypheReturnsCollectorLogger new.
    result := HypheReturnsCollectorResult new.
    instrumentedMethods := IdentitySet new.
    installedLinks := OrderedCollection new.
    collectionsData := OrderedCollection new.
    methodToCompiledMethod := Dictionary new.
    logger log: 'HypheReturnsCollector initialized for test: ', aTestCase printString
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentMethod: aCompiledMethod [
    | methodAst afterLink collector |
    
    "Check if already instrumented"
    (instrumentedMethods includes: aCompiledMethod) ifTrue: [ ^ self ].
    
    "Check if primitive - don't instrument but mark as seen"
    aCompiledMethod isPrimitive ifTrue: [ 
        instrumentedMethods add: aCompiledMethod.
        ^ self 
    ].
    
    "Mark as instrumented before actually instrumenting to avoid cycles"
    instrumentedMethods add: aCompiledMethod.
    
    logger log: 'Instrumenting: ', aCompiledMethod methodClass name, '>>', aCompiledMethod selector.
    
    "Get the AST"
    methodAst := aCompiledMethod ast.
    
    "Store the mapping for this method"
    methodToCompiledMethod at: methodAst put: aCompiledMethod.
    
    "Capture self in a variable to use in blocks"
    collector := self.
    
    "Install before links on all message send nodes"
    logger log: 'Installing before links on ', methodAst sendNodes size asString, ' send nodes'.
    methodAst sendNodes do: [ :sendNode |
        [
            | beforeLink |
            logger log: 'Creating before link for send node: ', sendNode selector asString.
            beforeLink := MetaLink new
                metaObject: [ :rcv :sel | collector propagateFrom: rcv with: sel ];
                selector: #value:value:;
                arguments: #(receiver selector);
                control: #before.
            installedLinks add: beforeLink.
            logger log: 'Linking before link to node: ', sendNode selector asString.
            sendNode link: beforeLink.
            logger log: 'Successfully linked before link for: ', sendNode selector asString
        ] on: Error do: [ :ex |
            logger log: 'ERROR linking before link for ', sendNode selector asString, ': ', ex messageText.
            logger log: 'Stack: ', ex signalerContext shortStack asString.
            ex pass
        ]
    ].
    
    "Create and install after link for return values on the method itself"
    [
        | methodClass |
        methodClass := aCompiledMethod methodClass.
        logger log: 'Creating after link for method: ', aCompiledMethod selector asString.
        afterLink := MetaLink new
            metaObject: [ :val :rcv :sel | 
                collector record: val from: rcv sel: sel in: methodClass
            ];
            selector: #value:value:value:;
            arguments: #(value receiver selector);
            control: #after.
        installedLinks add: afterLink.
        logger log: 'Linking after link to method AST'.
        methodAst link: afterLink.
        logger log: 'Successfully linked after link'
    ] on: Error do: [ :ex |
        logger log: 'ERROR linking after link: ', ex messageText.
        logger log: 'Stack: ', ex signalerContext shortStack asString.
        ex pass
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentTestCase [
    | testMethod |
    logger log: 'Instrumenting test case method'.
    testMethod := testCase class >> testCase selector.
    self instrumentMethod: testMethod
]

{ #category : 'accessing' }
HypheReturnsCollector >> logger [
    ^ logger
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> propagateFrom: aReceiver with: aSelector [
    [
        | compiledMethod |
        
        "Lookup the method that will be executed"
        compiledMethod := aReceiver class lookupSelector: aSelector.
        
        compiledMethod ifNil: [ 
            logger log: 'DNU detected for selector: ', aSelector.
            ^ self 
        ].
        
        "Propagate instrumentation to the called method"
        self instrumentMethod: compiledMethod
    ] on: Error do: [ :ex |
        logger log: 'Error in propagateFrom:with: ', ex messageText
    ]
]

{ #category : 'data collection' }
HypheReturnsCollector >> record: returnValue from: aReceiver sel: aSelector in: aMethodClass [
    [
        | receiverClass returnClass dataPoint |
        receiverClass := aReceiver class.
        returnClass := returnValue class.
        dataPoint := { receiverClass . aSelector . aMethodClass . returnClass }.
        collectionsData add: dataPoint.
        logger log: 'Collected: ', receiverClass name, ' >> ', aSelector, ' (method from: ', aMethodClass name, ', returns: ', returnClass name, ')'
    ] on: Error do: [ :ex |
        logger log: 'Error in record:from:sel:in: ', ex messageText
    ]
]

{ #category : 'accessing' }
HypheReturnsCollector >> result [
    ^ result
]

{ #category : 'running' }
HypheReturnsCollector >> run [
    | startTime endTime |
    logger log: 'Starting test execution with instrumentation'.
    result status: #running.
    startTime := DateAndTime now.
    
    [ 
        [ 
            self instrumentTestCase.
            logger log: 'Running test case'.
            testCase runCase.
            result status: #completed.
            logger log: 'Test completed successfully'
        ] on: Error do: [ :ex |
            result status: (ex class name = #TestFailure ifTrue: [ #testFailure ] ifFalse: [ #error ]).
            result errorMessage: ex messageText.
            logger log: 'Error during execution: ', ex messageText.
            logger log: 'Stack: ', ex signalerContext shortStack asString
        ]
    ] ensure: [
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        self cleanup.
        logger log: 'Cleanup completed'
    ].
    
    result collections: collectionsData.
    logger log: 'Collected ', collectionsData size asString, ' data points'.
    ^ result
]
