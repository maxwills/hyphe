Class {
	#name : 'HypheReturnsCollectorLogger',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'logToTranscript'
	],
	#category : 'Hyphe-Collectors',
	#package : 'Hyphe',
	#tag : 'Collectors'
}

{ #category : 'instance creation' }
HypheReturnsCollectorLogger class >> new [
    ^ super new initialize
]

{ #category : 'operations' }
HypheReturnsCollectorLogger >> clear [
    stream := String new writeStream
]

{ #category : 'accessing' }
HypheReturnsCollectorLogger >> contents [
    ^ stream contents
]

{ #category : 'logging' }
HypheReturnsCollectorLogger >> cr [
    stream cr.
    logToTranscript ifTrue: [ Transcript cr ]
]

{ #category : 'configuration' }
HypheReturnsCollectorLogger >> disableTranscriptLogging [
    logToTranscript := false
]

{ #category : 'configuration' }
HypheReturnsCollectorLogger >> enableTranscriptLogging [
    logToTranscript := true
]

{ #category : 'initialization' }
HypheReturnsCollectorLogger >> initialize [
    super initialize.
    stream := String new writeStream.
    logToTranscript := true
]

{ #category : 'logging' }
HypheReturnsCollectorLogger >> log: aString [
    | logMessage |
    logMessage := DateAndTime now asString, ' - ', aString.
    stream nextPutAll: logMessage; cr.
    logToTranscript ifTrue: [ 
        Transcript show: logMessage; cr 
    ]
]

{ #category : 'accessing' }
HypheReturnsCollectorLogger >> logToTranscript [
    ^ logToTranscript
]

{ #category : 'accessing' }
HypheReturnsCollectorLogger >> logToTranscript: aBoolean [
    logToTranscript := aBoolean
]

{ #category : 'printing' }
HypheReturnsCollectorLogger >> printOn: aStream [
    aStream 
        nextPutAll: 'HypheReturnsCollectorLogger(';
        nextPutAll: stream contents size asString;
        nextPutAll: ' characters, transcript: ';
        nextPutAll: logToTranscript asString;
        nextPutAll: ')'
]

{ #category : 'logging' }
HypheReturnsCollectorLogger >> show: aString [
    self log: aString
]
