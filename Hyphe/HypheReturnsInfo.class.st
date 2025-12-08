Class {
	#name : 'HypheReturnsInfo',
	#superclass : 'Object',
	#instVars : [
		'returnClass',
		'count',
		'percentage'
	],
	#category : 'Hyphe-CollectorsProcessing',
	#package : 'Hyphe',
	#tag : 'CollectorsProcessing'
}

{ #category : 'accessing' }
HypheReturnsInfo >> count [
    ^ count
]

{ #category : 'accessing' }
HypheReturnsInfo >> percentage [
    ^ percentage
]

{ #category : 'printing' }
HypheReturnsInfo >> printOn: aStream [
    super printOn: aStream.
    aStream 
        nextPutAll: '(';
        print: returnClass;
        nextPutAll: ' count: ';
        print: count;
        nextPutAll: ' ';
        print: (percentage * 100) rounded;
        nextPutAll: '%)'
]

{ #category : 'accessing' }
HypheReturnsInfo >> returnClass [
    ^ returnClass
]

{ #category : 'initialization' }
HypheReturnsInfo >> returnClass: aClass count: aCount percentage: aPercentage [
    returnClass := aClass.
    count := aCount.
    percentage := aPercentage
]
