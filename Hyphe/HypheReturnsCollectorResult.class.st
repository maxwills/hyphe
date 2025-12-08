Class {
	#name : 'HypheReturnsCollectorResult',
	#superclass : 'Object',
	#instVars : [
		'collections',
		'status',
		'executionTime',
		'errorMessage'
	],
	#category : 'Hyphe-Collectors',
	#package : 'Hyphe',
	#tag : 'Collectors'
}

{ #category : 'operations' }
HypheReturnsCollectorResult >> addCollection: aCollection [
    collections add: aCollection
]

{ #category : 'converting' }
HypheReturnsCollectorResult >> asProcessedResults [
|processedResults|
processedResults := HypheReturnDataProcessor process: self collections.
^processedResults 
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> collections [
    ^ collections
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> collections: aCollection [
    collections := aCollection
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> errorMessage [
    ^ errorMessage
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> errorMessage: aString [
    errorMessage := aString
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> executionTime [
    ^ executionTime
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> executionTime: aDuration [
    executionTime := aDuration
]

{ #category : 'testing' }
HypheReturnsCollectorResult >> hasErrors [
    ^ status = #error or: [ status = #fatalError ]
]

{ #category : 'initialization' }
HypheReturnsCollectorResult >> initialize [
    super initialize.
    collections := OrderedCollection new.
    status := #notStarted
]

{ #category : 'testing' }
HypheReturnsCollectorResult >> isCompleted [
    ^ status = #completed
]

{ #category : 'printing' }
HypheReturnsCollectorResult >> printOn: aStream [
    aStream 
        nextPutAll: 'HypheReturnsCollectorResult(';
        nextPutAll: status asString;
        nextPutAll: ', ';
        nextPutAll: collections size asString;
        nextPutAll: ' collections, ';
        nextPutAll: (executionTime ifNil: ['no time'] ifNotNil: [:t | t asMilliSeconds asString , 'ms']);
        nextPutAll: ')'
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> status [
    ^ status
]

{ #category : 'accessing' }
HypheReturnsCollectorResult >> status: aSymbol [
    status := aSymbol
]
