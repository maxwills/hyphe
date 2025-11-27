Class {
	#name : 'RuntimeTypesCollector',
	#superclass : 'Object',
	#instVars : [
		'collectedTypes'
	],
	#category : 'Hyphe-Tool',
	#package : 'Hyphe',
	#tag : 'Tool'
}

{ #category : 'initialization' }
RuntimeTypesCollector >> addCollectedType: aClass [

	collectedTypes add: aClass
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collect [

	| testCase proxies methods |
	
	methods := self collectMethodsToInstrument: BagTest >> #testCreation.
	testCase := BagTest selector: #testCreation.

	proxies := methods collect: [ :m |
			           MpMethodProxy
				           onMethod: m
				           handler: (MpTypeFeedbackHandler new
						            collector: self;
						            method: m;
						            yourself) ].

	proxies do: [ :p | p install ].
	MpMethodProxy enableInstrumentation.

	testCase run.

	proxies do: [ :p | p uninstall ].
	MpMethodProxy disableInstrumentation
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectInAllTestPackages [
		
	(Smalltalk globals organization packages select: [ :p | p name endsWith: '-Tests' ]) do: [ :p | self collectInPackage: p name ]
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectInPackage: packageName [

	(Smalltalk globals organization packageNamed: packageName) classes do: [ :cl |
		cl methods do: [ :m |
			self collectInTest: m inClass: cl ]
		 ]
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectInTest: compiledTest inClass: classObj [

	| testCase proxies methods  |
	
	methods := self collectMethodsToInstrument:
		           classObj >> compiledTest selector.
	testCase := BagTest selector: compiledTest selector.

	proxies := methods collect: [ :m |
			           MpMethodProxy
				           onMethod: m
				           handler: (MpTypeFeedbackHandler new
						            collector: self;
						            method: m;
						            yourself) ].

	proxies do: [ :p | p install ].
	MpMethodProxy enableInstrumentation.

	testCase run.

	proxies do: [ :p | p uninstall ].
	MpMethodProxy disableInstrumentation
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectMethodsToInstrument: method [
	
	^ ((MessageNodesCollector new visit: method ast)
		                messageNodes)
	 flatCollect: [ :mn |
		           SystemNavigation default allImplementorsOf: mn selector ].

	
]

{ #category : 'accessing' }
RuntimeTypesCollector >> collectedTypes [

	^ collectedTypes
]

{ #category : 'initialization' }
RuntimeTypesCollector >> initialize [

	super initialize.
	collectedTypes := OrderedCollection new.
]
