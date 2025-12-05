"
class for subscribing repositories to start automatic type inference if a specific action happens

	- Repository created, commited, pulled, pushed.
	- Packages loaded, removed from repository
"
Class {
	#name : 'RepositorySubscriptionPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'repositoryList',
		'selectedRepositoryList',
		'addButton',
		'removeButton',
		'clearButton',
		'onActionsLabel',
		'selectAllCheckbox',
		'pullCheckbox',
		'commitCheckbox',
		'pushCheckbox',
		'packageAddedCheckbox',
		'packageRemovedCheckbox',
		'subscribeAllCheckbox',
		'saveButton',
		'cancelButton'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'layout' }
RepositorySubscriptionPresenter >> connectPresenters [ 
	super connectPresenters.
	
	"Connect button actions"
	addButton action: [ self onAddRepository ].
	removeButton action: [ self onRemoveRepository ].
	clearButton action: [ self onClearRepositories ].
	
	"Connect checkbox behavior"
	selectAllCheckbox whenActivatedDo: [ self enableActionCheckboxes ].
	selectAllCheckbox whenDeactivatedDo: [ self disableActionCheckboxes ].
	
	"Connect save and cancel buttons"
	saveButton action: [ self onSave ].
	cancelButton action: [ self onCancel ]

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> defaultLayout [ 

	^ SpBoxLayout newTopToBottom
		spacing: 10;
		add: #titleLabel expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 10;
			add: #repositoryList;
			add: (SpBoxLayout newTopToBottom
				vAlignCenter;
				spacing: 5;
				add: #addButton expand: false;
				add: #removeButton expand: false;
				add: #clearButton expand: false;
				yourself);
			add: #selectedRepositoryList;
			yourself) expand: true;
		add: (SpBoxLayout newTopToBottom) expand: false;
		add: #onActionsLabel expand: false;
		add: #selectAllCheckbox expand: false;
		add: (SpBoxLayout newTopToBottom) expand: false;
		add: #pullCheckbox expand: false;
		add: #commitCheckbox expand: false;
		add: #pushCheckbox expand: false;
		add: #packageAddedCheckbox expand: false;
		add: #packageRemovedCheckbox expand: false;
		add: (SpBoxLayout newTopToBottom) expand: false;
		add: #subscribeAllCheckbox expand: false;
		add: (SpBoxLayout newTopToBottom) expand: false;
		add: (SpBoxLayout newLeftToRight
			hAlignCenter;
			spacing: 10;
			add: #saveButton expand: false;
			add: #cancelButton expand: false;
			yourself) expand: false;
		yourself

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> disableActionCheckboxes [ 

	pullCheckbox disable.
	commitCheckbox disable.
	pushCheckbox disable.
	packageAddedCheckbox disable.
	packageRemovedCheckbox disable

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> enableActionCheckboxes [ 

	pullCheckbox enable.
	commitCheckbox enable.
	pushCheckbox enable.
	packageAddedCheckbox enable.
	packageRemovedCheckbox enable
]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> initializeDialogWindow: aDialogPresenter [ 
	
	aDialogPresenter
		title: 'Repository Subscription Settings';
		initialExtent: 700@600

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> initializePresenters [ 
	"Initialize title label"
	titleLabel := self newLabel
		label: 'Subscribe repositories for automatic type inference';
		yourself.
	
	"Initialize repository lists"
	repositoryList := self newList
		items: self loadIcebergRepositories;
		display: [ :repo | repo name ];
		yourself.
	
	selectedRepositoryList := self newList
		display: [ :repo | repo name ];
		yourself.
	
	"Initialize buttons for repository management"
	addButton := self newButton
		label: 'Add >';
		icon: (self iconNamed: #smallAdd);
		yourself.
	
	removeButton := self newButton
		label: '< Remove';
		icon: (self iconNamed: #smallDelete);
		yourself.
	
	clearButton := self newButton
		label: 'Clear All';
		icon: (self iconNamed: #smallCancel);
		yourself.
	
	"Initialize 'On actions:' label"
	onActionsLabel := self newLabel
		label: 'On actions:';
		yourself.
	
	"Initialize select all checkbox"
	selectAllCheckbox := self newCheckBox
		label: 'Select all';
		state: false;
		yourself.
	
	"Initialize action checkboxes - all disabled by default"
	pullCheckbox := self newCheckBox
		label: 'Pull';
		disable;
		yourself.
	
	commitCheckbox := self newCheckBox
		label: 'Commit';
		disable;
		yourself.
	
	pushCheckbox := self newCheckBox
		label: 'Push';
		disable;
		yourself.
	
	packageAddedCheckbox := self newCheckBox
		label: 'Package added';
		disable;
		yourself.
	
	packageRemovedCheckbox := self newCheckBox
		label: 'Package removed';
		disable;
		yourself.
	
	"Initialize subscribe all future repositories checkbox"
	subscribeAllCheckbox := self newCheckBox
		label: 'Subscribe all future repositories';
		yourself.
	
	"Initialize save and cancel buttons"
	saveButton := self newButton
		label: 'Save';
		icon: (self iconNamed: #smallOk);
		yourself.
	
	cancelButton := self newButton
		label: 'Cancel';
		icon: (self iconNamed: #smallCancel);
		yourself

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> initializeWindow: aWindowPresenter [ 

	aWindowPresenter
		title: 'Repository Subscription Settings';
		initialExtent: 700@600

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> loadIcebergRepositories [ 
	
	^ IceRepository registry


]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> onAddRepository [ 
	"Move selected repository from available list to selected list"
	repositoryList selectedItem ifNotNil: [ :repo |
		| currentItems |
		currentItems := selectedRepositoryList items asOrderedCollection.
		(currentItems includes: repo) ifFalse: [
			currentItems add: repo.
			selectedRepositoryList items: currentItems ]
	]

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> onCancel [ 
	"Close the window without saving"
	self window close
]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> onClearRepositories [ 
	"Clear all repositories from selected list"
	selectedRepositoryList items: #()

]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> onRemoveRepository [ 
	"Remove selected repository from selected list"
	selectedRepositoryList selectedItem ifNotNil: [ :repo |
		| currentItems |
		currentItems := selectedRepositoryList items asOrderedCollection.
		currentItems remove: repo.
		selectedRepositoryList items: currentItems ]
]

{ #category : 'layout' }
RepositorySubscriptionPresenter >> onSave [ 
	"Save the configuration and close the window"
	| config |
	config := Dictionary new.
	config at: #repositories put: selectedRepositoryList items.
	config at: #onPull put: pullCheckbox state.
	config at: #onCommit put: commitCheckbox state.
	config at: #onPush put: pushCheckbox state.
	config at: #onPackageAdded put: packageAddedCheckbox state.
	config at: #onPackageRemoved put: packageRemovedCheckbox state.
	config at: #subscribeAllFuture put: subscribeAllCheckbox state.
	
	"Here you would typically save the configuration"
	self inform: 'Configuration saved successfully'.
	self window close
]
