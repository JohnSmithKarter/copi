///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'copi'
	String get appName => 'copi';

	late final Translations$home$en home = Translations$home$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$presets$en presets = Translations$presets$en.internal(_root);
	late final Translations$sync$en sync = Translations$sync$en.internal(_root);
	late final Translations$about$en about = Translations$about$en.internal(_root);
	late final Translations$logs$en logs = Translations$logs$en.internal(_root);
	late final Translations$errors$en errors = Translations$errors$en.internal(_root);
}

// Path: home
class Translations$home$en {
	Translations$home$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Copies'
	String get presets => 'Copies';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'No access'
	String get noAccess => 'No access';

	/// en: 'Allow'
	String get allow => 'Allow';

	/// en: 'Empty'
	String get empty => 'Empty';

	/// en: 'Disks'
	String get disks => 'Disks';

	late final Translations$home$roots$en roots = Translations$home$roots$en.internal(_root);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Accent'
	String get accent => 'Accent';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Files'
	String get files => 'Files';

	/// en: 'Show hidden files'
	String get showHidden => 'Show hidden files';

	/// en: 'Русский'
	String get russian => 'Русский';

	/// en: 'English'
	String get english => 'English';

	/// en: 'Folders'
	String get permissions => 'Folders';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Logs'
	String get logs => 'Logs';

	/// en: 'Allowed'
	String get granted => 'Allowed';

	/// en: 'Not allowed'
	String get missing => 'Not allowed';
}

// Path: presets
class Translations$presets$en {
	Translations$presets$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Copies'
	String get title => 'Copies';

	/// en: 'New copy'
	String get newTitle => 'New copy';

	/// en: 'No copies yet'
	String get empty => 'No copies yet';

	/// en: 'Create a copy'
	String get create => 'Create a copy';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Monthly backup'
	String get nameHint => 'Monthly backup';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Run'
	String get run => 'Run';

	/// en: 'From'
	String get source => 'From';

	/// en: 'To'
	String get destination => 'To';

	/// en: 'Another folder'
	String get addPair => 'Another folder';

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Mode'
	String get mode => 'Mode';

	/// en: 'Match source'
	String get mirror => 'Match source';

	/// en: 'New and changed'
	String get additive => 'New and changed';

	/// en: 'The folder is copied into the chosen place under its own name and then matches the source'
	String get mirrorHint => 'The folder is copied into the chosen place under its own name and then matches the source';

	/// en: 'The folder is copied into the chosen place under its own name. New and changed files are added there, older files stay'
	String get additiveHint => 'The folder is copied into the chosen place under its own name. New and changed files are added there, older files stay';

	/// en: 'Choose a folder on each side'
	String get needBoth => 'Choose a folder on each side';

	/// en: 'Choose the folder to copy on the left'
	String get needSource => 'Choose the folder to copy on the left';

	/// en: 'Choose the folder or disk to put it in on the right'
	String get needDestination => 'Choose the folder or disk to put it in on the right';

	/// en: 'The folders on the left and right must be different'
	String get sameFolder => 'The folders on the left and right must be different';

	/// en: 'Name the copy'
	String get needName => 'Name the copy';

	/// en: '{count} folders'
	String pairCount({required Object count}) => '${count} folders';

	/// en: 'Delete this copy?'
	String get deleteTitle => 'Delete this copy?';

	/// en: 'The saved folders are removed. Files on disk stay.'
	String get deleteBody => 'The saved folders are removed. Files on disk stay.';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	late final Translations$presets$help$en help = Translations$presets$help$en.internal(_root);
}

// Path: sync
class Translations$sync$en {
	Translations$sync$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sync'
	String get title => 'Sync';

	/// en: 'Looking through folders'
	String get scanning => 'Looking through folders';

	/// en: 'Copying'
	String get copying => 'Copying';

	/// en: 'Removing extra files'
	String get deleting => 'Removing extra files';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Could not finish'
	String get error => 'Could not finish';

	/// en: 'Cancelled'
	String get cancelled => 'Cancelled';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Now'
	String get now => 'Now';

	/// en: '{done} of {total}'
	String progress({required Object done, required Object total}) => '${done} of ${total}';

	/// en: 'Same name'
	String get conflictTitle => 'Same name';

	/// en: '“{name}” is already on the disk.'
	String conflictBody({required Object name}) => '“${name}” is already on the disk.';

	/// en: 'Replace'
	String get conflictReplace => 'Replace';

	/// en: 'Keep both'
	String get conflictKeepBoth => 'Keep both';

	/// en: 'Skip'
	String get conflictSkip => 'Skip';

	/// en: 'Apply to all'
	String get conflictApplyToAll => 'Apply to all';
}

// Path: about
class Translations$about$en {
	Translations$about$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'About'
	String get title => 'About';

	/// en: 'Why it exists'
	String get goalTitle => 'Why it exists';

	/// en: 'copi copies local folders onto another disk for you. Choose the folders you usually drag by hand, save a copy, and run it again next time.'
	String get goal => 'copi copies local folders onto another disk for you. Choose the folders you usually drag by hand, save a copy, and run it again next time.';

	/// en: 'What it does'
	String get canTitle => 'What it does';

	/// en: 'It remembers folder pairs and copies everything inside: ordinary files, hidden files, and links. New and changed files are copied again. Match source removes anything the folder no longer has. Progress stays on screen, and you can cancel.'
	String get can => 'It remembers folder pairs and copies everything inside: ordinary files, hidden files, and links. New and changed files are copied again. Match source removes anything the folder no longer has. Progress stays on screen, and you can cancel.';

	/// en: 'Limits'
	String get limitsTitle => 'Limits';

	/// en: 'A file counts as the same when its size and date match, without a content hash. A link is copied as a link, so a file outside the folder is not pulled in. Finder tags, permissions, and other macOS attributes are not copied. Windows is not supported yet.'
	String get limits => 'A file counts as the same when its size and date match, without a content hash. A link is copied as a link, so a file outside the folder is not pulled in. Finder tags, permissions, and other macOS attributes are not copied. Windows is not supported yet.';
}

// Path: logs
class Translations$logs$en {
	Translations$logs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logs'
	String get title => 'Logs';
}

// Path: errors
class Translations$errors$en {
	Translations$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The destination disk is unavailable. Nothing was deleted.'
	String get destinationUnavailable => 'The destination disk is unavailable. Nothing was deleted.';

	/// en: 'Source and destination are the same folder.'
	String get sameLocation => 'Source and destination are the same folder.';

	/// en: 'A folder could not be opened. Nothing was copied.'
	String get accessDenied => 'A folder could not be opened. Nothing was copied.';

	/// en: 'A file could not be handled. What was already done stays on the disk.'
	String get fileFailed => 'A file could not be handled. What was already done stays on the disk.';

	/// en: 'The folder permission could not be saved.'
	String get bookmark => 'The folder permission could not be saved.';
}

// Path: home.roots
class Translations$home$roots$en {
	Translations$home$roots$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Desktop'
	String get desktop => 'Desktop';

	/// en: 'Documents'
	String get documents => 'Documents';

	/// en: 'Downloads'
	String get downloads => 'Downloads';
}

// Path: presets.help
class Translations$presets$help$en {
	Translations$presets$help$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How to use'
	String get title => 'How to use';

	/// en: 'From and to'
	String get chooseTitle => 'From and to';

	/// en: 'On the left, choose the folder to copy. On the right, choose the folder or disk to put it in. Tap a name to select the folder. The arrow only opens it. Tap the same row again, or the cross on the chip, to clear the choice. The folder is copied into the chosen place under its own name.'
	String get choose => 'On the left, choose the folder to copy. On the right, choose the folder or disk to put it in. Tap a name to select the folder. The arrow only opens it. Tap the same row again, or the cross on the chip, to clear the choice. The folder is copied into the chosen place under its own name.';

	/// en: 'Mode'
	String get modeTitle => 'Mode';

	/// en: 'Match source makes the copied folder the same as the source and removes extras inside it. New and changed adds new and changed files and leaves older files in place.'
	String get mode => 'Match source makes the copied folder the same as the source and removes extras inside it. New and changed adds new and changed files and leaves older files in place.';

	/// en: 'Several folders'
	String get moreTitle => 'Several folders';

	/// en: 'Another folder remembers the current pair and clears the choice so you can pick the next one. Every pair is saved under one name and runs together. With a single folder you can skip that button: Save takes whatever is selected now.'
	String get more => 'Another folder remembers the current pair and clears the choice so you can pick the next one. Every pair is saved under one name and runs together. With a single folder you can skip that button: Save takes whatever is selected now.';

	/// en: 'Same names'
	String get sameNameTitle => 'Same names';

	/// en: 'If the disk already has a file with that name, copying asks you to replace it, keep both, or skip it. Keep both adds “ (1)” to the copy’s name. Apply to all repeats the choice for the rest of the run. In Match source, that “ (1)” copy is removed on the next run, because it is not in the source.'
	String get sameName => 'If the disk already has a file with that name, copying asks you to replace it, keep both, or skip it. Keep both adds “ (1)” to the copy’s name. Apply to all repeats the choice for the rest of the run. In Match source, that “ (1)” copy is removed on the next run, because it is not in the source.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'copi',
			'home.presets' => 'Copies',
			'home.settings' => 'Settings',
			'home.noAccess' => 'No access',
			'home.allow' => 'Allow',
			'home.empty' => 'Empty',
			'home.disks' => 'Disks',
			'home.roots.home' => 'Home',
			'home.roots.desktop' => 'Desktop',
			'home.roots.documents' => 'Documents',
			'home.roots.downloads' => 'Downloads',
			'settings.title' => 'Settings',
			'settings.accent' => 'Accent',
			'settings.language' => 'Language',
			'settings.files' => 'Files',
			'settings.showHidden' => 'Show hidden files',
			'settings.russian' => 'Русский',
			'settings.english' => 'English',
			'settings.permissions' => 'Folders',
			'settings.version' => 'Version',
			'settings.logs' => 'Logs',
			'settings.granted' => 'Allowed',
			'settings.missing' => 'Not allowed',
			'presets.title' => 'Copies',
			'presets.newTitle' => 'New copy',
			'presets.empty' => 'No copies yet',
			'presets.create' => 'Create a copy',
			'presets.name' => 'Name',
			'presets.nameHint' => 'Monthly backup',
			'presets.save' => 'Save',
			'presets.delete' => 'Delete',
			'presets.edit' => 'Edit',
			'presets.run' => 'Run',
			'presets.source' => 'From',
			'presets.destination' => 'To',
			'presets.addPair' => 'Another folder',
			'presets.remove' => 'Remove',
			'presets.clear' => 'Clear',
			'presets.mode' => 'Mode',
			'presets.mirror' => 'Match source',
			'presets.additive' => 'New and changed',
			'presets.mirrorHint' => 'The folder is copied into the chosen place under its own name and then matches the source',
			'presets.additiveHint' => 'The folder is copied into the chosen place under its own name. New and changed files are added there, older files stay',
			'presets.needBoth' => 'Choose a folder on each side',
			'presets.needSource' => 'Choose the folder to copy on the left',
			'presets.needDestination' => 'Choose the folder or disk to put it in on the right',
			'presets.sameFolder' => 'The folders on the left and right must be different',
			'presets.needName' => 'Name the copy',
			'presets.pairCount' => ({required Object count}) => '${count} folders',
			'presets.deleteTitle' => 'Delete this copy?',
			'presets.deleteBody' => 'The saved folders are removed. Files on disk stay.',
			'presets.cancel' => 'Cancel',
			'presets.help.title' => 'How to use',
			'presets.help.chooseTitle' => 'From and to',
			'presets.help.choose' => 'On the left, choose the folder to copy. On the right, choose the folder or disk to put it in. Tap a name to select the folder. The arrow only opens it. Tap the same row again, or the cross on the chip, to clear the choice. The folder is copied into the chosen place under its own name.',
			'presets.help.modeTitle' => 'Mode',
			'presets.help.mode' => 'Match source makes the copied folder the same as the source and removes extras inside it. New and changed adds new and changed files and leaves older files in place.',
			'presets.help.moreTitle' => 'Several folders',
			'presets.help.more' => 'Another folder remembers the current pair and clears the choice so you can pick the next one. Every pair is saved under one name and runs together. With a single folder you can skip that button: Save takes whatever is selected now.',
			'presets.help.sameNameTitle' => 'Same names',
			'presets.help.sameName' => 'If the disk already has a file with that name, copying asks you to replace it, keep both, or skip it. Keep both adds “ (1)” to the copy’s name. Apply to all repeats the choice for the rest of the run. In Match source, that “ (1)” copy is removed on the next run, because it is not in the source.',
			'sync.title' => 'Sync',
			'sync.scanning' => 'Looking through folders',
			'sync.copying' => 'Copying',
			'sync.deleting' => 'Removing extra files',
			'sync.done' => 'Done',
			'sync.error' => 'Could not finish',
			'sync.cancelled' => 'Cancelled',
			'sync.cancel' => 'Cancel',
			'sync.close' => 'Close',
			'sync.now' => 'Now',
			'sync.progress' => ({required Object done, required Object total}) => '${done} of ${total}',
			'sync.conflictTitle' => 'Same name',
			'sync.conflictBody' => ({required Object name}) => '“${name}” is already on the disk.',
			'sync.conflictReplace' => 'Replace',
			'sync.conflictKeepBoth' => 'Keep both',
			'sync.conflictSkip' => 'Skip',
			'sync.conflictApplyToAll' => 'Apply to all',
			'about.title' => 'About',
			'about.goalTitle' => 'Why it exists',
			'about.goal' => 'copi copies local folders onto another disk for you. Choose the folders you usually drag by hand, save a copy, and run it again next time.',
			'about.canTitle' => 'What it does',
			'about.can' => 'It remembers folder pairs and copies everything inside: ordinary files, hidden files, and links. New and changed files are copied again. Match source removes anything the folder no longer has. Progress stays on screen, and you can cancel.',
			'about.limitsTitle' => 'Limits',
			'about.limits' => 'A file counts as the same when its size and date match, without a content hash. A link is copied as a link, so a file outside the folder is not pulled in. Finder tags, permissions, and other macOS attributes are not copied. Windows is not supported yet.',
			'logs.title' => 'Logs',
			'errors.destinationUnavailable' => 'The destination disk is unavailable. Nothing was deleted.',
			'errors.sameLocation' => 'Source and destination are the same folder.',
			'errors.accessDenied' => 'A folder could not be opened. Nothing was copied.',
			'errors.fileFailed' => 'A file could not be handled. What was already done stays on the disk.',
			'errors.bookmark' => 'The folder permission could not be saved.',
			_ => null,
		};
	}
}
