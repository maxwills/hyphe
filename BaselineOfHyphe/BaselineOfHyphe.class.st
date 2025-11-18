Class {
	#name : 'BaselineOfHyphe',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHyphe',
	#package : 'BaselineOfHyphe'
}

{ #category : 'baselines' }
BaselineOfHyphe >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec baseline: 'TypeInfoTools' with: [
			spec
				repository: 'github://JanBliznicenko/TypeInfoTools:main';
				loads: #( returntypes ) ].

		spec
			baseline: 'NeoCSV'
			with: [ spec repository: 'github://svenvc/NeoCSV' ].

		spec
			baseline: 'LLMAPI'
			with: [
			spec repository: 'github://JanBliznicenko/Pharo-LLMAPI:main' ].

		spec
			baseline: 'TypeMe'
			with: [
			spec repository: 'github://lsafina/typeMeI:main' ].

		spec
			package: #Hyphe
			with: [ spec requires: #( 'TypeInfoTools' 'NeoCSV' 'LLMAPI' 'TypeMe' ) ];
			package: #'Hyphe-Tests' with: [ spec requires: #( 'Hyphe' ) ].
		spec
			group: 'Core' with: #( 'Hyphe' 'Hyphe-Tests' );
			group: 'default' with: #( 'Hyphe' 'Hyphe-Tests' ) ]
]
