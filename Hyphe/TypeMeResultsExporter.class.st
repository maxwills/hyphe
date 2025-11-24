Class {
	#name : 'TypeMeResultsExporter',
	#superclass : 'Object',
	#instVars : [
		'typeMeResults',
		'hyDataRepresentation',
		'defaultSource',
		'defaultConfidence'
	],
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'as yet unclassified' }
TypeMeResultsExporter class >> export: aTypeMeResults to: aHyDataRepresentation [
    "Export TypeMe results to HyDataRepresentation, updating existing data"
    ^ self new
        typeMeResults: aTypeMeResults;
        hyDataRepresentation: aHyDataRepresentation;
        export;
        yourself
]

{ #category : 'as yet unclassified' }
TypeMeResultsExporter class >> export: aTypeMeResults toFile: aFilePath [
    "Export TypeMe results to a new or existing HyDataRepresentation file"
    | hyData |
    hyData := aFilePath asFileReference exists
        ifTrue: [ HyDataRepresentation fromJsonFile: aFilePath ]
        ifFalse: [ 
            HyDataRepresentation new 
                filePath: aFilePath;
                yourself ].
    ^ self export: aTypeMeResults to: hyData

]

{ #category : 'initialization' }
TypeMeResultsExporter >> addReturnTypes: typeSet toMethod: method [
    "Add return types to method, avoiding duplicates"
    | existingTypes existingTypeNames |
    existingTypes := method returnTypes.
    existingTypeNames := existingTypes collect: [ :t | t type ].
    
    "Add only new types"
    typeSet do: [ :typeName |
        (existingTypeNames includes: typeName) ifFalse: [
            | newType |
            newType := HyType new
                name: typeName;
                source: defaultSource;
                yourself.
            method addReturnType: newType ] ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> defaultConfidence [

    ^ defaultConfidence 
]

{ #category : 'initialization' }
TypeMeResultsExporter >> defaultConfidence: aNumber [

    "Set the default confidence for exported data"
    defaultConfidence := aNumber
]

{ #category : 'initialization' }
TypeMeResultsExporter >> defaultSource [

    ^ defaultSource

]

{ #category : 'initialization' }
TypeMeResultsExporter >> defaultSource: aString [

    defaultSource := aString

]

{ #category : 'initialization' }
TypeMeResultsExporter >> determineSide: methodName [
    "Determine if method is class-side or instance-side"
    "Convention: class-side methods often start with lowercase or specific patterns"
    "For now, default to inst_side unless specified otherwise"
    
	^ 'inst_side'
]

{ #category : 'initialization' }
TypeMeResultsExporter >> determineSide: methodName forClass: class [
    "Determine if method is class-side or instance-side"
    "Convention: default to inst_side unless specified otherwise"
    "You can customize this logic based on your needs"
    ^ class instSide
]

{ #category : 'initialization' }
TypeMeResultsExporter >> export [
	"Export all TypeMe results to HyDataRepresentation"

	| typeResults |
	typeResults := typeMeResults typeResults.
	self processTypeResults: typeResults.
	^ hyDataRepresentation
]

{ #category : 'initialization' }
TypeMeResultsExporter >> exportOnlyNewData [
    "Export only data that doesn't exist in HyDataRepresentation"
    "Skip updating existing methods"
    | typeResults grouped |
    typeResults := typeMeResults typeResults.
    grouped := self groupTypeResults: typeResults.
    
    grouped keysAndValuesDo: [ :packageName :classesDict |
        | package |
        package := self findOrCreatePackage: packageName.
        
        classesDict keysAndValuesDo: [ :className :methodsDict |
            | class side |
            class := self findOrCreateClass: className inPackage: package.
            side := class instSide.
            
            "Process only new methods"
            methodsDict keysAndValuesDo: [ :methodName :typeSet |
                | method existingMethod |
                existingMethod := side methods 
                    detect: [ :m | m name = methodName ]
                    ifNone: [ nil ].
                
                "Only add if method doesn't exist"
                existingMethod ifNil: [
                    method := HyMethod new
                        name: methodName;
                        confidence: defaultConfidence;
                        yourself.
                    side addMethod: method.
                    
                    "Add all return types"
                    typeSet do: [ :typeName |
                        | newType |
                        newType := HyType new
                            type: typeName;
                            source: defaultSource;
                            yourself.
                        method addReturnType: newType ] ] ] ] ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> exportWithConfidenceCalculator: aCalculator [
    "Export using a custom confidence calculator"
    "aCalculator should respond to #calculateConfidence:"
    | typeResults grouped |
    typeResults := typeMeResults typeResults.
    grouped := self groupTypeResults: typeResults.
    
    grouped keysAndValuesDo: [ :packageName :classesDict |
        | package |
        package := self findOrCreatePackage: packageName.
        
        classesDict keysAndValuesDo: [ :className :methodsDict |
            | class |
            class := self findOrCreateClass: className inPackage: package.
            
            methodsDict keysAndValuesDo: [ :methodName :typeSet |
                | side method |
                side := class instSide.
                method := self findOrCreateMethod: methodName inSide: side.
                
                "Add types and calculate confidence"
                self addReturnTypes: typeSet toMethod: method.
                
                "Update confidence based on return types"
                method returnTypes ifNotEmpty: [
                    method confidence: (aCalculator calculateConfidence: method returnTypes) ] ] ] ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> exportWithSideDetection: aSideDetectionBlock [
    "Export with custom side detection logic"
    "aSideDetectionBlock: [ :methodName :class | class instSide or class classSide ]"
    | typeResults grouped |
    typeResults := typeMeResults typeResults.
    grouped := self groupTypeResults: typeResults.
    
    grouped keysAndValuesDo: [ :packageName :classesDict |
        | package |
        package := self findOrCreatePackage: packageName.
        
        classesDict keysAndValuesDo: [ :className :methodsDict |
            | class |
            class := self findOrCreateClass: className inPackage: package.
            
            "Process methods with custom side detection"
            methodsDict keysAndValuesDo: [ :methodName :typeSet |
                | side method |
                side := aSideDetectionBlock value: methodName value: class.
                method := self findOrCreateMethod: methodName inSide: side.
                self addReturnTypes: typeSet toMethod: method ] ] ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> findClass: className inPackage: packageName [
    "Find class by name in package"
    | package |
    package := self findPackage: packageName.
    package ifNil: [ ^ nil ].
    ^ package classes 
        detect: [ :cls | cls name = className ]
        ifNone: [ nil ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> findMethod: methodName inClass: className package: packageName [
    "Find method by name in class"
    | class side |
    class := self findClass: className inPackage: packageName.
    class ifNil: [ ^ nil ].
    side := class instSide.
    ^ side methods 
        detect: [ :m | m name = methodName ]
        ifNone: [ nil ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> findOrCreateClass: className inPackage: package [
    "Find existing class or create new one"
    | class |
    class := package classes 
        detect: [ :cls | cls name = className ]
        ifNone: [ nil ].
    
    class ifNil: [
        class := HyClass new
            name: className;
            superclass: '?';
            yourself.
        package addClass: class ].
    
    ^ class
]

{ #category : 'initialization' }
TypeMeResultsExporter >> findOrCreateMethod: methodName inSide: side [
    "Find existing method or create new one"
    | method |
    method := side methods 
        detect: [ :m | m name = methodName ]
        ifNone: [ nil ].
    
    method ifNil: [
        method := HyMethod new
            name: methodName;
            confidence: defaultConfidence;
            yourself.
        side addMethod: method ].
    
    ^ method
]

{ #category : 'initialization' }
TypeMeResultsExporter >> findOrCreatePackage: packageName [
    "Find existing package or create new one"
    | package |
    package := hyDataRepresentation packages 
        detect: [ :pkg | pkg name = packageName ]
        ifNone: [ nil ].
    
    package ifNil: [
        package := HyPackage new 
            name: packageName;
            yourself.
        hyDataRepresentation addPackage: package ].
    
    ^ package
]

{ #category : 'initialization' }
TypeMeResultsExporter >> findPackage: packageName [
    "Find package by name"
    ^ hyDataRepresentation packages 
        detect: [ :pkg | pkg name = packageName ]
        ifNone: [ nil ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> groupTypeResults: typeResults [
    "Group type results by package -> class -> method -> types"
    | grouped |
    grouped := Dictionary new.
    
    typeResults do: [ :result |
        | packageName className methodName typeName packageDict classDict methodSet |
        packageName := result at: 1.
        className := result at: 2.
        methodName := result at: 3.
        typeName := result at: 4.
        
        "Get or create package entry"
        packageDict := grouped at: packageName ifAbsentPut: [ Dictionary new ].
        
        "Get or create class entry"
        classDict := packageDict at: className ifAbsentPut: [ Dictionary new ].
        
        "Get or create method entry (set of types)"
        methodSet := classDict at: methodName ifAbsentPut: [ Set new ].
        
        "Add type to set"
        methodSet add: typeName ].
    
    ^ grouped
]

{ #category : 'initialization' }
TypeMeResultsExporter >> hyDataRepresentation: aHyDataRepresentation [
    hyDataRepresentation := aHyDataRepresentation
]

{ #category : 'initialization' }
TypeMeResultsExporter >> initialize [
    
	 super initialize.
    defaultSource := 'TypeMe'.
    defaultConfidence := 0.8
]

{ #category : 'initialization' }
TypeMeResultsExporter >> printStatistics [
    "Print statistics about the export"
    | typeResults packageCount classCount methodCount typeCount |
    typeResults := typeMeResults typeResults.
    
    packageCount := (typeResults collect: [ :r | r at: 1 ]) asSet size.
    classCount := (typeResults collect: [ :r | r at: 2 ]) asSet size.
    methodCount := (typeResults collect: [ :r | r at: 3 ]) asSet size.
    typeCount := typeResults size.
    
    Transcript 
        cr; show: '=== Export Statistics ===';
        cr; show: 'Packages: ', packageCount asString;
        cr; show: 'Classes: ', classCount asString;
        cr; show: 'Methods: ', methodCount asString;
        cr; show: 'Type entries: ', typeCount asString;
        cr
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processClass: className inPackage: package methods: methodsDict [
	"Process a class and its methods"

	| class |
	class := self findOrCreateClass: className inPackage: package.
	methodsDict keysAndValuesDo: [ :methodName :typeSet |
		self processMethod: methodName withTypes: typeSet inClass: class ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processMethod: methodName withTypes: typeSet inClass: aClass [
	"Process a method and add return types"

	| method |
	method := aClass findOrCreateMethod: methodName.
	self addReturnTypes: typeSet toMethod: method
	
	"Determine which side (class_side or inst_side)
	side := self determineSide: methodName forClass: class.""Find or create method"
	
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processPackage: packageName classes: classesDict [
	"Process a package and its classes"

	| package |
	package := self findOrCreatePackage: packageName.
	classesDict keysAndValuesDo: [ :className :methodsDict |
		self processClass: className inPackage: package methods: methodsDict ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> processTypeResults: typeResults [
	"Process all type results and update HyDataRepresentation"

	| grouped |
	"Group by package -> class -> method"
	grouped := self groupTypeResults: typeResults.
	grouped keysAndValuesDo: [ :packageName :classesDict |
		self processPackage: packageName classes: classesDict ]
]

{ #category : 'initialization' }
TypeMeResultsExporter >> save [
    "Save the updated HyDataRepresentation"
    hyDataRepresentation exportToJson
]

{ #category : 'initialization' }
TypeMeResultsExporter >> saveToFile: aFilePath [
    "Save the updated HyDataRepresentation to a specific file"
    hyDataRepresentation exportToJsonFile: aFilePath
]

{ #category : 'initialization' }
TypeMeResultsExporter >> typeMeResults: aTypeMeResults [

    typeMeResults := aTypeMeResults
]
