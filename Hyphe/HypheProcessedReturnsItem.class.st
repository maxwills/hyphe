Class {
	#name : 'HypheProcessedReturnsItem',
	#superclass : 'Object',
	#instVars : [
		'receiverClass',
		'methodSelector',
		'definingClass',
		'returnsInfo',
		'package'
	],
	#category : 'Hyphe-CollectorsProcessing',
	#package : 'Hyphe',
	#tag : 'CollectorsProcessing'
}

{ #category : 'adding' }
HypheProcessedReturnsItem >> addReturnsInfo: aHypheReturnsInfo [
    returnsInfo add: aHypheReturnsInfo
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> definingClass [
    ^ definingClass
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> methodSelector [
    ^ methodSelector
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> package [
    ^ package
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> package: aPackage [
    package := aPackage
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> receiverClass [
    ^ receiverClass
]

{ #category : 'initialization' }
HypheProcessedReturnsItem >> receiverClass: aReceiverClass methodSelector: aSelector definingClass: aDefiningClass [
    receiverClass := aReceiverClass.
    methodSelector := aSelector.
    definingClass := aDefiningClass.
    returnsInfo := OrderedCollection new
]

{ #category : 'resolving' }
HypheProcessedReturnsItem >> resolvePackage [
    "Look up the package from the compiled method in definingClass"
    | compiledMethod |
    compiledMethod := definingClass >> methodSelector.
    compiledMethod ifNotNil: [
        package := compiledMethod package name ]
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> returnsInfo [
    ^ returnsInfo
]

{ #category : 'accessing' }
HypheProcessedReturnsItem >> returnsInfo: aCollection [
    returnsInfo := aCollection
]
