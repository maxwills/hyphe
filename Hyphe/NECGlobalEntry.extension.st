Extension { #name : 'NECGlobalEntry' }

{ #category : '*Hyphe' }
NECGlobalEntry class >> new [
    | object |
    (self == NECGlobalEntry)
        ifTrue: [
            object := HypheNECGlobalEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
