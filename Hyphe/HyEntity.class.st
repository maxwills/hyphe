Class {
	#name : 'HyEntity',
	#superclass : 'Object',
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyEntity class >> fromJsonDictionary: aDict [
	self subclassResponsibility 
]

{ #category : 'converting' }
HyEntity >> asJsonDictionary [ 
	self subclassResponsibility 
]
