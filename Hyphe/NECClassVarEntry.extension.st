Extension { #name : 'NECClassVarEntry' }

{ #category : '*Hyphe' }
NECClassVarEntry class >> new [
    | object |
    (self == NECClassVarEntry)
        ifTrue: [
            object := HypheNECClassVarEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
