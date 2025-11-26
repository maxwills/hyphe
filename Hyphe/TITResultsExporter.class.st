Class {
	#name : 'TITResultsExporter',
	#superclass : 'InferenceResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
TITResultsExporter >> doExport [

	(source methodsByPackages) methodsByPackages keysAndValuesDo: [ :package :methods | self processPackageMethods: package methods: methods ].
]

{ #category : 'initialization' }
TITResultsExporter >> extractTypeFrom: typeInfo [
    
	| typeName |
    
    typeInfo ifNil: [ ^ nil ].
    typeName := typeInfo types commonSuperclassOfTopWeightClassesOrAny.
    typeName ifNotNil: [ ^ typeName name ]
]

{ #category : 'initialization' }
TITResultsExporter >> initialize [

    super initialize.
    defaultSource := 'TIT-Gatherer'.
    defaultConfidence := 0.8.
]

{ #category : 'initialization' }
TITResultsExporter >> processPackageMethods: package methods: methods [

	| hyPackage |
	hyPackage := self findOrCreatePackage: package.

	methods do: [ :titMethod |
			| className typeName hyClass hyMethod |
			className := titMethod ownerClass name.
			typeName := self extractTypeFrom: titMethod typeInfo.
			typeName ifNotNil: [
					hyClass := self findOrCreateClass: className inPackage: hyPackage.
					hyMethod := hyClass findOrCreateMethod: (titMethod name).
					hyMethod addReturnType: typeName ] 
				]
]
