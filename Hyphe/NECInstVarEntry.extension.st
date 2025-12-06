Extension { #name : 'NECInstVarEntry' }

{ #category : '*Hyphe' }
NECInstVarEntry class >> new [
    | object |
    (self == NECInstVarEntry)
        ifTrue: [
            object := HypheNECInstVarEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
