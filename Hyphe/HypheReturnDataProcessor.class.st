Class {
	#name : 'HypheReturnDataProcessor',
	#superclass : 'Object',
	#instVars : [
		'dataItems'
	],
	#category : 'Hyphe-CollectorsProcessing',
	#package : 'Hyphe',
	#tag : 'CollectorsProcessing'
}

{ #category : 'instance creation' }
HypheReturnDataProcessor class >> process: aCollection [
    ^ self new
        dataItems: aCollection;
        process
]

{ #category : 'private' }
HypheReturnDataProcessor >> countReturnClasses: items [
    | counts |
    counts := Dictionary new.
    
    items do: [ :item |
        | returnClass |
        returnClass := item returnClass.
        counts 
            at: returnClass 
            ifPresent: [ :count | counts at: returnClass put: count + 1 ]
            ifAbsentPut: [ 1 ] ].
    
    ^ counts
]

{ #category : 'initialization' }
HypheReturnDataProcessor >> dataItems: aCollection [
    dataItems := aCollection
]

{ #category : 'private' }
HypheReturnDataProcessor >> groupByMethod [
    | grouped |
    grouped := Dictionary new.
    
    dataItems do: [ :item |
        | key |
        key := item receiverClass name, '>>', item methodSelector asString.
        grouped 
            at: key 
            ifAbsentPut: [ OrderedCollection new ].
        (grouped at: key) add: item ].
    
    ^ grouped
]

{ #category : 'processing' }
HypheReturnDataProcessor >> process [
    | processedReturns grouped |
    processedReturns := HypheProcessedReturns new.
    
    "Group items by receiverClass>>#methodSelector"
    grouped := self groupByMethod.
    
    "Process each group"
    grouped keysAndValuesDo: [ :key :items |
        | processedItem returnClassCounts totalCount |
        
        "Create processed item with method info from first item"
        processedItem := HypheProcessedReturnsItem new
            receiverClass: items first receiverClass
            methodSelector: items first methodSelector
            definingClass: items first definingClass.
        
        "Count return classes"
        returnClassCounts := self countReturnClasses: items.
        totalCount := returnClassCounts values sum.
        
        "Create HypheReturnsInfo for each return class"
        returnClassCounts keysAndValuesDo: [ :returnClass :count |
            | percentage returnsInfo |
            percentage := count / totalCount asFloat.
            returnsInfo := HypheReturnsInfo new
                returnClass: returnClass
                count: count
                percentage: percentage.
            processedItem addReturnsInfo: returnsInfo ].
        
        processedReturns at: key put: processedItem ].
    
    "Build organized views by package and receiver class"
    processedReturns buildOrganizedViews.
    
    ^ processedReturns
]
