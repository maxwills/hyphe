Class {
	#name : 'HypheIcebergEventHandler',
	#superclass : 'Object',
	#classVars : [
		'Subscriptions'
	],
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'initialization' }
HypheIcebergEventHandler class >> initialize [
    self subscribe
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryCreated: ann [
    Transcript 
        show: '[Hyphe] Repository created: ', ann repository name;
        cr
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryForgotten: ann [
    Transcript 
        show: '[Hyphe] Repository forgotten: ', (ann repository ifNotNil: #name ifNil: ['(all)']);
        cr
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryModified: ann [
    Transcript 
        show: '[Hyphe] Repository modified: ', (ann repository ifNotNil: #name ifNil: ['(unknown)']);
        cr
]

{ #category : 'event handlers' }
HypheIcebergEventHandler class >> onRepositoryPushed: ann [
    Transcript 
        show: '[Hyphe] Repository pushed: ', ann repository name;
        cr
]

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> subscribe [
    self unsubscribe.
    Subscriptions := OrderedCollection new.
    
    "Iceberg announcements"
    Subscriptions add: (Iceberg announcer weak
        when: IceRepositoryCreated
        send: #onRepositoryCreated:
        to: self).
    
    Subscriptions add: (Iceberg announcer weak
        when: IceRepositoryForgotten
        send: #onRepositoryForgotten:
        to: self).
    
    Subscriptions add: (Iceberg announcer weak
        when: IceRepositoryModified
        send: #onRepositoryModified:
        to: self).
    
    Subscriptions add: (Iceberg announcer weak
        when: IcePushed
        send: #onRepositoryPushed:
        to: self)
]

{ #category : 'subscribing' }
HypheIcebergEventHandler class >> unsubscribe [
    Subscriptions ifNotNil: [
        Subscriptions do: [ :sub | 
            sub announcer removeSubscription: sub ].
        Subscriptions := nil ]
]
