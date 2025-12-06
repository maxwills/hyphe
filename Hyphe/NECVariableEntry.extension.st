Extension { #name : 'NECVariableEntry' }

{ #category : '*Hyphe' }
NECVariableEntry class >> new [
    | object |
    (self == NECVariableEntry)
        ifTrue: [
            object := HypheNECVariableEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
