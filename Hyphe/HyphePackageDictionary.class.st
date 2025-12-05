Class {
	#name : 'HyphePackageDictionary',
	#superclass : 'Dictionary',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'as yet unclassified' }
HyphePackageDictionary class >> cleanUpInjection [
    "Replace all HyphePackageDictionary instances with regular dictionaries in all IceWorkingCopy instances"
    IceRepository registry do: [ :repo |
        | workingCopy packagesDict |
        workingCopy := repo workingCopy.
        packagesDict := workingCopy instVarNamed: #packages.
        (packagesDict isKindOf: HyphePackageDictionary) ifTrue: [
            workingCopy instVarNamed: #packages put: packagesDict asDictionary ] ]
]

{ #category : 'instance creation' }
HyphePackageDictionary class >> newFromDictionary: aDictionary [
"note that this convertion will register all packages as added in the listener"
    | newDic |
    newDic := self new.
    newDic addAll: aDictionary.
    ^ newDic
]

{ #category : 'as yet unclassified' }
HyphePackageDictionary class >> restoreOriginalMethod [
    "Restore the original packagesDictionary method by removing the extension and recompiling the original"
    "Recompile the original method - it will automatically be in the Iceberg package since IceWorkingCopy is defined there"
    IceWorkingCopy compile: 'packagesDictionary
	^ packages' classified: 'private - packages'.
]

{ #category : 'converting' }
HyphePackageDictionary >> asDictionary [
"used to restore the original dictionary when un-injecting code"
|newDic|

    newDic := Dictionary new.
    newDic addAll: self.
    ^ newDic
]

{ #category : 'accessing' }
HyphePackageDictionary >> at: key put: anObject [
	|res|
	res := super at: key put: anObject.
		Transcript showCr: 'Package added to dictionary:', res package.
	^ res
]

{ #category : 'removing' }
HyphePackageDictionary >> removeKey: aPackageSymbol ifAbsent: aBlock [
|res|
res:= super removeKey: aPackageSymbol ifAbsent: aBlock.
Transcript showCr: 'Removed package: ',aPackageSymbol.
^res
]
