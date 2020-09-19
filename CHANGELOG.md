## [1.51] - 2020-05-08
* Add a bottom bar in the NoteEditor to show the Folder
* Add very basic Image support
* Allow sorting by Title and Filename
* Add a Debug screen for users to more easily debug issues

## [1.50] - 2020-05-01
* Show num of changes to be pushed
* Follow GitHub's checklist format
* Allow Sharing of Notes
* Allow configuring of default Folder for Journal Editor
* Editor: Show ✕ or ✓ in AppBar depending on if the note has been modified

## [1.49] - 2020-04-22
* Allow Pay what you want for Pro version
* Collect better crash information
* Allow folders to be renamed
* Search in filename as well

## [1.48] - 2020-04-17
* Cache Network Images
* Allow Markdown View/Edit mode to configured
* Bug: Do not allow / in file names

## [1.47] - 2020-04-14
* Added Pro mode
* Improved sync speed by avoiding unnecessary options
* Polishing the UI

## [1.46] - 2020-04-02
* Add a Grid View
* Beautify the Cards Folder View
* Show images if path is relative
* Allow linking to other notes
* EditorSelector: Make it prettier

## [1.45] - 2020-03-20
* Add an "All Notes" view
* Allow quickly opening a note with a specific editor
* Save the Note type (Checklist/Journal) in the metadata
* Fix validation of custom ssh keys
* Performance improvements for faster loading of Notes
* Add experimental Cards view

## [1.44] - 2020-03-11
* Allow the Folder View to be configured
* Faster loading of notes
* BugFix: Notes should update when modified in another repo

## [1.43.2] - 2020-03-05
* Optimize the NotesCache

## [1.43] - 2020-03-02
* BUG: Fix crash in NotesCache

## [1.42] - 2020-03-01
* Add experimental Journal Editor
* Improved loading time
* Remove the FAB

## [1.41] - 2020-02-17
* Support custom SSH Keys
* Polish the Checklist Editor
* Allow YAML Metadata to be disabled

## [1.40] - 2020-02-16
* Polish the Checklist Editor
* Add emoji support

## [1.39] - 2020-02-11
* Add Experimental Checklist Editor
* Performance improvements of about 22%

## [1.38] - 2020-02-09
* Allow Note sorting to be configured
* Allow git push frequency to be configured
* Show animations when adding/removing a note

## [1.37] - 2020-01-31
* Allow note changes to be discarded
* Do not load too many notes in one go
* Stop the Snackbar from overlapping the FAB

## [1.36] - 2020-01-28
* Automatically resolve merge conflicts
* New combined editor / viewer
* Allow Notes to moved to another Folder

## [1.35] - 2020-01-27
* Allow notes to be renamed
* Dark Theme improvements

## [1.34] - 2020-01-27
* Fix git host setup

## [1.33] - 2020-01-25
* Save notes by default with the title as the filename
* Fix bug where notes contents would disappear if app was switched while editing

## [1.31] - 2020-01-06
* Allow the modified key in notes to be configured.
  This improves compatibility with Hugo blog posts, as
  GitJournal can now update the 'lastmod' field as used
  by Hugo front matter.

## [1.30] - 2020-01-04
* Add support for AWS Code Commit
* Expose the Git Remote in the Settings

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
