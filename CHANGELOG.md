## [1.28] - 2020-01-02
* Fix: New repo in GitLab fix

## [1.28] - 2019-12-28
* Fix: Allow # to be used in the title

## [1.27] - 2019-12-27
* Allow Note titles to be specified
* Links can now be opened from Notes

## [1.26] - 2019-12-26
* Support Git repos which do not have master branches
* Add scrollbars
* Add a button to show network state
* Fix Folder Navigation
* Split GitJournal into many plugins
  - This way more people can build Git based apps

## [1.25] - 2019-12-14
* Fix sorting of Notes and Folders

## [1.24] - 2019-12-14
* Improve Folder Support
  - Folders can now be deleted
  - Subfolders can be also created
* Improve markdown support - we now support all of GitHub markdown minus HTML.
* Mark when the note was last modified in the metadata.
* Bug fixes related to datetime parsing and serializaiton.

## [1.23] - 2019-12-08
* Massive performance boosts. We aren't just saying that, now notes are loaded asynchronously in the background, and we only re-parse them when necessary.

## [1.22] - 2019-12-07

* Improve animations while navigating
* Allow folders to be renamed

## [1.21] - 2019-12-06

* Polish Folder support
  - Allow new folders to be created
* Make everything look a bit prettier

## [1.20] - 2019-12-04

* We now have basic Folder support
* Notes can be managed inside any Folder
* Improve appearance in dark mode
* Bug: Fix ssh key not being regenerated error

## [1.18] - 2019-11-02

* Better handling of Markdown files without YAML headers
* Raw Note editing now uses a Monospace Font
* The Settings Screen has been made prettier
* Back button automatically saves the note
* Improved performance by build time caching of constant values
* Bug: Avoid saving notes if not modified
