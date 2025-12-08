Class {
	#name : 'HypheReturnDataItem',
	#superclass : 'Object',
	#instVars : [
		'receiverClass',
		'methodSelector',
		'definingClass',
		'returnClass'
	],
	#category : 'Hyphe-Collectors',
	#package : 'Hyphe',
	#tag : 'Collectors'
}

{ #category : 'accessing' }
HypheReturnDataItem >> definingClass [
    ^ definingClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> definingClass: aClass [
    definingClass := aClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> methodSelector [
    ^ methodSelector
]

{ #category : 'accessing' }
HypheReturnDataItem >> methodSelector: aSelector [
    methodSelector := aSelector
]

{ #category : 'printing' }
HypheReturnDataItem >> printOn: aStream [
    
        receiverClass printOn: aStream.
		  aStream nextPutAll: ' ('.
        definingClass printOn: aStream.
        aStream nextPutAll: ') >> '.
        methodSelector printOn: aStream.
        aStream nextPutAll: ' -> '.        
        returnClass printOn: aStream
]

{ #category : 'accessing' }
HypheReturnDataItem >> receiverClass [
    ^ receiverClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> receiverClass: aClass [
    receiverClass := aClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> returnClass [
    ^ returnClass
]

{ #category : 'accessing' }
HypheReturnDataItem >> returnClass: aClass [
    returnClass := aClass
]
