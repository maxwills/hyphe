Class {
	#name : 'ManifestHyphe',
	#superclass : 'PackageManifest',
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'install/uninstall' }
ManifestHyphe class >> unload [
    "Clean up Hyphe injection before package removal"
    HyphePackageDictionary cleanUpInjection.
    HyphePackageDictionary restoreOriginalMethod.
    HypheIcebergEventHandler ifNotNil: [ HypheIcebergEventHandler unsubscribe ]
]
