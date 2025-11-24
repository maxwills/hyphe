Class {
	#name : 'AssignConfidencePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'methodsTable',
		'saveButton',
		'cancelButton',
		'resetAllButton',
		'resetSelectedButton',
		'originalData'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'initialization' }
AssignConfidencePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		spacing: 10;
		add: methodsTable;
		add: (SpBoxLayout newLeftToRight
			spacing: 5;
			add: saveButton;
			add: cancelButton;
			add: resetAllButton;
			add: resetSelectedButton;
			yourself) expand: false;
		yourself
]

{ #category : 'initialization' }
AssignConfidencePresenter >> initializePresenters [

	"Initialize the table"
	methodsTable := self newTable.
	methodsTable
		addColumn: (SpStringTableColumn 
			title: 'Method' 
			evaluated: [ :item | item name ]);
		addColumn: (SpStringTableColumn 
			title: 'Confidence (0-1)' 
			evaluated: [ :item | item confidence asString ]);
		beResizable.
	
	"Load data from InferenceMethod instances"
	self loadMethodsData.
	
	"Make the confidence column editable"
	self makeConfidenceEditable.
	
	"Initialize buttons"
	saveButton := self newButton.
	saveButton 
		label: 'Save';
		action: [ self onSave ].
	
	cancelButton := self newButton.
	cancelButton 
		label: 'Cancel';
		action: [ self onCancel ].
	
	resetAllButton := self newButton.
	resetAllButton 
		label: 'Reset All';
		action: [ self onResetAll ].
	
	resetSelectedButton := self newButton.
	resetSelectedButton 
		label: 'Reset Selected';
		action: [ self onResetSelected ]
]

{ #category : 'initialization' }
AssignConfidencePresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Assign Confidence Level';
		initialExtent: 500@400
]

{ #category : 'initialization' }
AssignConfidencePresenter >> loadMethodsData [

	"Load inference methods and store original data"
	| methods |
	methods := InferenceMethod allInstances.
	
	"Store original values for reset functionality"
	originalData := methods collect: [ :method |
		method name -> method confidence ] as: Dictionary.
	
	methodsTable items: methods
]

{ #category : 'initialization' }
AssignConfidencePresenter >> makeConfidenceEditable [

	"Make the confidence column editable"
	| confidenceColumn |
	confidenceColumn := methodsTable columns second.
	confidenceColumn
		onAcceptEdition: [ :item :newValue | 
			self updateConfidence: item with: newValue ]
]

{ #category : 'initialization' }
AssignConfidencePresenter >> onCancel [

	"Cancel changes and close"
	self onResetAll.
	self window close
]

{ #category : 'initialization' }
AssignConfidencePresenter >> onResetAll [

	"Reset all methods to their original confidence values"
	methodsTable items do: [ :method |
		| originalConfidence |
		originalConfidence := originalData at: method name ifAbsent: [ method confidence ].
		method confidence: originalConfidence ].
	
	methodsTable refresh
]

{ #category : 'initialization' }
AssignConfidencePresenter >> onResetSelected [

	"Reset selected methods to their original confidence values"
	| selected |
	selected := methodsTable selectedItems.
	
	selected ifEmpty: [ 
		self inform: 'No methods selected'.
		^ self ].
	
	selected do: [ :method |
		| originalConfidence |
		originalConfidence := originalData at: method name ifAbsent: [ method confidence ].
		method confidence: originalConfidence ].
	
	methodsTable refresh
]

{ #category : 'initialization' }
AssignConfidencePresenter >> onSave [

	"Save the changes and close"
	self inform: 'Confidence levels saved successfully!'.
	self window close
]

{ #category : 'initialization' }
AssignConfidencePresenter >> updateConfidence: anInferenceMethod with: newValue [

	"Update confidence value with validation"
	| numericValue |
	
	[ numericValue := newValue asNumber ]
		on: Error
		do: [ 
			self inform: 'Invalid number format: ' , newValue.
			^ self ].
	
	"Validate range 0-1"
	(numericValue between: 0 and: 1)
		ifFalse: [ 
			self inform: 'Confidence must be between 0 and 1'.
			^ self ].
	
	"Update the confidence"
	anInferenceMethod confidence: numericValue.
	methodsTable refresh
]
