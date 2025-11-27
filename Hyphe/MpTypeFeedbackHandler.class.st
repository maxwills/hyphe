Class {
	#name : 'MpTypeFeedbackHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'collector'
	],
	#category : 'Hyphe-Tool',
	#package : 'Hyphe',
	#tag : 'Tool'
}

{ #category : 'evaluating' }
MpTypeFeedbackHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: returnValue [

	collector addCollectedType: returnValue class.
	1 halt.
	^ returnValue
]

{ #category : 'evaluating' }
MpTypeFeedbackHandler >> collector: anObject [

	collector := anObject
]

{ #category : 'initialization' }
MpTypeFeedbackHandler >> initialize [

	super initialize
]

{ #category : 'evaluating' }
MpTypeFeedbackHandler >> method: anObject [

	method := anObject
]

{ #category : 'evaluating' }
MpTypeFeedbackHandler >> proxy: anObject [

	proxy := anObject
]
