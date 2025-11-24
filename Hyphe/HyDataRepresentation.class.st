Class {
	#name : 'HyDataRepresentation',
	#superclass : 'Object',
	#instVars : [
		'filePath',
		'metadata',
		'packages'
	],
	#category : 'Hyphe-Data',
	#package : 'Hyphe',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyDataRepresentation class >> fromJsonFile: aPath [

	| data instance |
	aPath asFileReference readStreamDo: [ :stream |
		data := (NeoJSONReader on: stream) next ].
	instance := self new
		            filePath: aPath;
		            yourself.
	data do: [ :packageDict |
		instance addPackage: (HyPackage fromJsonDictionary: packageDict) ].
	^ instance
]

{ #category : 'adding' }
HyDataRepresentation >> addPackage: aPackageObj [

	(self hasPackageNamed: aPackageObj name) ifFalse: [ 
		packages add: aPackageObj.
		^ aPackageObj
		]
	ifTrue: [ 
		^ (self getPackageNamed: aPackageObj name) updateClasses: (aPackageObj classes)
	].
	 
]

{ #category : 'adding' }
HyDataRepresentation >> addPackageNamed: packageName [

	(self hasPackageNamed: packageName) ifFalse: [ packages add: (HyPackage new name: packageName; yourself)].
	^ packages getPackage: packageName
]

{ #category : 'adding' }
HyDataRepresentation >> addPackageNamed: packageName withClasses: classesCollection [

	(self hasPackageNamed: packageName) ifFalse: [ 
		packages add: (HyPackage new name: packageName; classes: classesCollection; yourself).
		^ packages getPackageNamed: packageName
		]
	ifTrue: [ 
		^ (packages getPackageNamed: packageName) updateClasses: classesCollection.
	].
]

{ #category : 'accessing' }
HyDataRepresentation >> asJsonDictionary [

    ^ OrderedCollection new
        addAll: (packages collect: [ :pkg | pkg asJsonDictionary ]);
        yourself
]

{ #category : 'adding' }
HyDataRepresentation >> defaultFilePath [

	^ 'types.json'
]

{ #category : 'accessing' }
HyDataRepresentation >> exportToJson [

    ^ self exportToJsonFile: filePath
]

{ #category : 'accessing' }
HyDataRepresentation >> exportToJsonFile: aPath [

	| jsonDict file |
	jsonDict := self asJsonDictionary.
	aPath asFileReference delete.
	file := aPath asFileReference.
	file writeStreamDo: [ :stream |
			(NeoJSONWriter on: stream)
				prettyPrint: true;
				nextPut: jsonDict ].
	^ file
]

{ #category : 'accessing' }
HyDataRepresentation >> exportToJsonString [

    | jsonDict |
    jsonDict := self asJsonDictionary.
    ^ String streamContents: [ :stream |
        (NeoJSONWriter on: stream)
            prettyPrint: true;
            nextPut: jsonDict ]
]

{ #category : 'accessing' }
HyDataRepresentation >> filePath [

	^ filePath
]

{ #category : 'accessing' }
HyDataRepresentation >> filePath: anObject [

	filePath := anObject
]

{ #category : 'adding' }
HyDataRepresentation >> getPackageNamed: aPackage [

	^ (packages select: [ :p | p name = aPackage ]) first 
]

{ #category : 'adding' }
HyDataRepresentation >> hasPackageNamed: aPackage [

	^ packages anySatisfy: [ :p | p name = aPackage ] 
]

{ #category : 'adding' }
HyDataRepresentation >> initialize [

	super initialize.
	packages := OrderedCollection new.
	filePath := self defaultFilePath
]

{ #category : 'accessing' }
HyDataRepresentation >> metadata [

	^ metadata
]

{ #category : 'accessing' }
HyDataRepresentation >> metadata: anObject [

	metadata := anObject
]

{ #category : 'adding' }
HyDataRepresentation >> packages [
	
	^ packages 
]

{ #category : 'accessing' }
HyDataRepresentation >> packages: anObject [

	packages := anObject
]

{ #category : 'adding' }
HyDataRepresentation >> removePackageNamed: packageName [

	(self hasPackageNamed: packageName) ifTrue: [
		packages remove: (self getPackageNamed: packageName) ]
]

{ #category : 'accessing' }
HyDataRepresentation >> save [

	^ self exportToJsonFile: filePath
]
