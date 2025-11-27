Class {
	#name : 'MessageNodesCollector',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'messageNodes'
	],
	#category : 'Hyphe-Tool',
	#package : 'Hyphe',
	#tag : 'Tool'
}

{ #category : 'visiting' }
MessageNodesCollector >> initialize [ 

	super initialize.
	messageNodes := OrderedCollection new. 
]

{ #category : 'accessing' }
MessageNodesCollector >> messageNodes [

	^ messageNodes
]

{ #category : 'visiting' }
MessageNodesCollector >> visitMessageNode: aMessageNode [

	super visitMessageNode: aMessageNode.
	messageNodes add: aMessageNode. 
]
