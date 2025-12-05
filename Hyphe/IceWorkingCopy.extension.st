Extension { #name : 'IceWorkingCopy' }

{ #category : '*Hyphe' }
IceWorkingCopy >> packagesDictionaryDeactivated [
"Deactivated for first iteration of the protype. Remove the Deactivated from the name to start intercepting adds and removes from the repositories packages"
"Overriden by Hyphe to listen to package changes"
^(packages class == Dictionary) ifTrue:[packages:=HyphePackageDictionary newFromDictionary: packages] ifFalse: [packages ]
	 
]
