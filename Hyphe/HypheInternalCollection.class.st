Class {
	#name : 'HypheInternalCollection',
	#superclass : 'OrderedCollection',
	#instVars : [
		'isExecuting'
	],
	#category : 'Hyphe-Collectors',
	#package : 'Hyphe',
	#tag : 'Collectors'
}

{ #category : 'adding' }
HypheInternalCollection >> add: newObject [
    "Re-entrancy guard: if already executing on THIS instance, return newObject to prevent recursion.
    Use == true to handle nil case (OrderedCollection uses basicNew which bypasses initialize)."
    | result |
    (isExecuting == true) ifTrue: [ ^ newObject ].
    
    isExecuting := true.
    [ result := super add: newObject ] ensure: [ isExecuting := false ].
    ^ result
]
