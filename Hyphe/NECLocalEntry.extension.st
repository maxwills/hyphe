Extension { #name : 'NECLocalEntry' }

{ #category : '*Hyphe' }
NECLocalEntry class >> new [
    | object |
    (self == NECLocalEntry)
        ifTrue: [
            object := HypheNECLocalEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
