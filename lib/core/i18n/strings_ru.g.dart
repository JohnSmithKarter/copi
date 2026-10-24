///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsRu extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => 'copi';
	@override late final _Translations$home$ru home = _Translations$home$ru._(_root);
	@override late final _Translations$settings$ru settings = _Translations$settings$ru._(_root);
	@override late final _Translations$presets$ru presets = _Translations$presets$ru._(_root);
	@override late final _Translations$sync$ru sync = _Translations$sync$ru._(_root);
	@override late final _Translations$about$ru about = _Translations$about$ru._(_root);
	@override late final _Translations$logs$ru logs = _Translations$logs$ru._(_root);
	@override late final _Translations$errors$ru errors = _Translations$errors$ru._(_root);
}

// Path: home
class _Translations$home$ru extends Translations$home$en {
	_Translations$home$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get presets => 'Копии';
	@override String get settings => 'Настройки';
	@override String get noAccess => 'Нет доступа';
	@override String get allow => 'Разрешить';
	@override String get empty => 'Пусто';
	@override String get disks => 'Диски';
	@override late final _Translations$home$roots$ru roots = _Translations$home$roots$ru._(_root);
}

// Path: settings
class _Translations$settings$ru extends Translations$settings$en {
	_Translations$settings$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки';
	@override String get accent => 'Акцент';
	@override String get language => 'Язык';
	@override String get files => 'Файлы';
	@override String get showHidden => 'Показывать скрытые файлы';
	@override String get russian => 'Русский';
	@override String get english => 'English';
	@override String get permissions => 'Папки';
	@override String get version => 'Версия';
	@override String get logs => 'Логи';
	@override String get granted => 'Разрешено';
	@override String get missing => 'Нет доступа';
}

// Path: presets
class _Translations$presets$ru extends Translations$presets$en {
	_Translations$presets$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Копии';
	@override String get newTitle => 'Новая копия';
	@override String get empty => 'Копий пока нет';
	@override String get create => 'Создать копию';
	@override String get name => 'Имя';
	@override String get nameHint => 'Ежемесячный бэкап';
	@override String get save => 'Сохранить';
	@override String get delete => 'Удалить';
	@override String get edit => 'Изменить';
	@override String get run => 'Запустить';
	@override String get source => 'Откуда';
	@override String get destination => 'Куда';
	@override String get addPair => 'Ещё папка';
	@override String get remove => 'Убрать';
	@override String get clear => 'Убрать выбор';
	@override String get mode => 'Режим';
	@override String get mirror => 'Как в источнике';
	@override String get additive => 'Новое и изменённое';
	@override String get mirrorHint => 'Папка копируется внутрь выбранного места под своим именем и становится такой же, как источник';
	@override String get additiveHint => 'Папка копируется внутрь выбранного места под своим именем. Новые и изменённые файлы дописываются в неё, старые остаются';
	@override String get needBoth => 'Выберите папку слева и справа';
	@override String get needSource => 'Слева выберите папку, которую копировать';
	@override String get needDestination => 'Справа выберите папку или диск, куда её положить';
	@override String get sameFolder => 'Папки слева и справа должны отличаться';
	@override String get needName => 'Назовите копию';
	@override String pairCount({required Object count}) => '${count} папок';
	@override String get deleteTitle => 'Удалить копию?';
	@override String get deleteBody => 'Сохранённые папки будут забыты. Файлы на диске останутся.';
	@override String get cancel => 'Отмена';
	@override late final _Translations$presets$help$ru help = _Translations$presets$help$ru._(_root);
}

// Path: sync
class _Translations$sync$ru extends Translations$sync$en {
	_Translations$sync$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Синхронизация';
	@override String get scanning => 'Смотрим папки';
	@override String get copying => 'Копирование';
	@override String get deleting => 'Убираем лишнее';
	@override String get done => 'Готово';
	@override String get error => 'Не удалось закончить';
	@override String get cancelled => 'Отменено';
	@override String get cancel => 'Отмена';
	@override String get close => 'Закрыть';
	@override String get now => 'Сейчас';
	@override String progress({required Object done, required Object total}) => '${done} из ${total}';
	@override String get conflictTitle => 'Такое имя уже есть';
	@override String conflictBody({required Object name}) => 'На диске уже есть «${name}».';
	@override String get conflictReplace => 'Заменить';
	@override String get conflictKeepBoth => 'Оставить оба';
	@override String get conflictSkip => 'Пропустить';
	@override String get conflictApplyToAll => 'Выполнить для всех';
}

// Path: about
class _Translations$about$ru extends Translations$about$en {
	_Translations$about$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Информация';
	@override String get goalTitle => 'Зачем это';
	@override String get goal => 'copi сам копирует локальные папки на другой диск. Один раз указываете папки, которые обычно переносите руками, сохраняете копию и запускаете её в следующий раз.';
	@override String get canTitle => 'Что умеет';
	@override String get can => 'Запоминает пары папок и копирует всё, что лежит внутри: обычные файлы, скрытые и ссылки. Новые и изменённые переносятся снова. В режиме «Как в источнике» из копии уходит то, чего в папке уже нет. Прогресс виден на экране, запуск можно отменить.';
	@override String get limitsTitle => 'Ограничения';
	@override String get limits => 'Файл считается тем же, если совпали размер и дата, без сверки по хешу. Ссылка копируется как ссылка, файл за пределами папки по ней не подтягивается. Метки Finder, права и прочие атрибуты macOS не переносятся. Windows пока не поддерживается.';
}

// Path: logs
class _Translations$logs$ru extends Translations$logs$en {
	_Translations$logs$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Логи';
}

// Path: errors
class _Translations$errors$ru extends Translations$errors$en {
	_Translations$errors$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get destinationUnavailable => 'Диск назначения недоступен. Ничего не удалено.';
	@override String get sameLocation => 'Источник и назначение — одна и та же папка.';
	@override String get accessDenied => 'Папку не удалось открыть. Ничего не скопировано.';
	@override String get fileFailed => 'Не удалось обработать файл. Уже сделанное остаётся на диске.';
	@override String get bookmark => 'Не удалось сохранить разрешение на папку.';
}

// Path: home.roots
class _Translations$home$roots$ru extends Translations$home$roots$en {
	_Translations$home$roots$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get home => 'Домой';
	@override String get desktop => 'Рабочий стол';
	@override String get documents => 'Документы';
	@override String get downloads => 'Загрузки';
}

// Path: presets.help
class _Translations$presets$help$ru extends Translations$presets$help$en {
	_Translations$presets$help$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Как пользоваться';
	@override String get chooseTitle => 'Откуда и куда';
	@override String get choose => 'Слева выбираете папку, которую копировать. Справа — папку или диск, куда её положить. Нажатие на имя выбирает папку, стрелка только раскрывает. Повторное нажатие или крестик на плашке снимает выбор. Папка копируется внутрь выбранного места под своим именем.';
	@override String get modeTitle => 'Режим';
	@override String get mode => '«Как в источнике» делает скопированную папку такой же, как источник: лишнее внутри неё убирается. «Новое и изменённое» дописывает новые и изменённые файлы, старые остаются.';
	@override String get moreTitle => 'Несколько папок';
	@override String get more => '«Ещё папка» запоминает текущую пару и очищает выбор, чтобы указать следующую. Все пары сохраняются под одним именем и запускаются вместе. Если папка одна, кнопку можно не нажимать: «Сохранить» возьмёт то, что выбрано сейчас.';
	@override String get sameNameTitle => 'Одинаковые имена';
	@override String get sameName => 'Если на диске уже есть файл с таким именем, копирование спрашивает: заменить, оставить оба или пропустить. «Оставить оба» дописывает к имени копии « (1)». «Выполнить для всех» повторяет выбор до конца запуска. В режиме «Как в источнике» копия с « (1)» пропадёт при следующем запуске: в источнике её нет.';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'copi',
			'home.presets' => 'Копии',
			'home.settings' => 'Настройки',
			'home.noAccess' => 'Нет доступа',
			'home.allow' => 'Разрешить',
			'home.empty' => 'Пусто',
			'home.disks' => 'Диски',
			'home.roots.home' => 'Домой',
			'home.roots.desktop' => 'Рабочий стол',
			'home.roots.documents' => 'Документы',
			'home.roots.downloads' => 'Загрузки',
			'settings.title' => 'Настройки',
			'settings.accent' => 'Акцент',
			'settings.language' => 'Язык',
			'settings.files' => 'Файлы',
			'settings.showHidden' => 'Показывать скрытые файлы',
			'settings.russian' => 'Русский',
			'settings.english' => 'English',
			'settings.permissions' => 'Папки',
			'settings.version' => 'Версия',
			'settings.logs' => 'Логи',
			'settings.granted' => 'Разрешено',
			'settings.missing' => 'Нет доступа',
			'presets.title' => 'Копии',
			'presets.newTitle' => 'Новая копия',
			'presets.empty' => 'Копий пока нет',
			'presets.create' => 'Создать копию',
			'presets.name' => 'Имя',
			'presets.nameHint' => 'Ежемесячный бэкап',
			'presets.save' => 'Сохранить',
			'presets.delete' => 'Удалить',
			'presets.edit' => 'Изменить',
			'presets.run' => 'Запустить',
			'presets.source' => 'Откуда',
			'presets.destination' => 'Куда',
			'presets.addPair' => 'Ещё папка',
			'presets.remove' => 'Убрать',
			'presets.clear' => 'Убрать выбор',
			'presets.mode' => 'Режим',
			'presets.mirror' => 'Как в источнике',
			'presets.additive' => 'Новое и изменённое',
			'presets.mirrorHint' => 'Папка копируется внутрь выбранного места под своим именем и становится такой же, как источник',
			'presets.additiveHint' => 'Папка копируется внутрь выбранного места под своим именем. Новые и изменённые файлы дописываются в неё, старые остаются',
			'presets.needBoth' => 'Выберите папку слева и справа',
			'presets.needSource' => 'Слева выберите папку, которую копировать',
			'presets.needDestination' => 'Справа выберите папку или диск, куда её положить',
			'presets.sameFolder' => 'Папки слева и справа должны отличаться',
			'presets.needName' => 'Назовите копию',
			'presets.pairCount' => ({required Object count}) => '${count} папок',
			'presets.deleteTitle' => 'Удалить копию?',
			'presets.deleteBody' => 'Сохранённые папки будут забыты. Файлы на диске останутся.',
			'presets.cancel' => 'Отмена',
			'presets.help.title' => 'Как пользоваться',
			'presets.help.chooseTitle' => 'Откуда и куда',
			'presets.help.choose' => 'Слева выбираете папку, которую копировать. Справа — папку или диск, куда её положить. Нажатие на имя выбирает папку, стрелка только раскрывает. Повторное нажатие или крестик на плашке снимает выбор. Папка копируется внутрь выбранного места под своим именем.',
			'presets.help.modeTitle' => 'Режим',
			'presets.help.mode' => '«Как в источнике» делает скопированную папку такой же, как источник: лишнее внутри неё убирается. «Новое и изменённое» дописывает новые и изменённые файлы, старые остаются.',
			'presets.help.moreTitle' => 'Несколько папок',
			'presets.help.more' => '«Ещё папка» запоминает текущую пару и очищает выбор, чтобы указать следующую. Все пары сохраняются под одним именем и запускаются вместе. Если папка одна, кнопку можно не нажимать: «Сохранить» возьмёт то, что выбрано сейчас.',
			'presets.help.sameNameTitle' => 'Одинаковые имена',
			'presets.help.sameName' => 'Если на диске уже есть файл с таким именем, копирование спрашивает: заменить, оставить оба или пропустить. «Оставить оба» дописывает к имени копии « (1)». «Выполнить для всех» повторяет выбор до конца запуска. В режиме «Как в источнике» копия с « (1)» пропадёт при следующем запуске: в источнике её нет.',
			'sync.title' => 'Синхронизация',
			'sync.scanning' => 'Смотрим папки',
			'sync.copying' => 'Копирование',
			'sync.deleting' => 'Убираем лишнее',
			'sync.done' => 'Готово',
			'sync.error' => 'Не удалось закончить',
			'sync.cancelled' => 'Отменено',
			'sync.cancel' => 'Отмена',
			'sync.close' => 'Закрыть',
			'sync.now' => 'Сейчас',
			'sync.progress' => ({required Object done, required Object total}) => '${done} из ${total}',
			'sync.conflictTitle' => 'Такое имя уже есть',
			'sync.conflictBody' => ({required Object name}) => 'На диске уже есть «${name}».',
			'sync.conflictReplace' => 'Заменить',
			'sync.conflictKeepBoth' => 'Оставить оба',
			'sync.conflictSkip' => 'Пропустить',
			'sync.conflictApplyToAll' => 'Выполнить для всех',
			'about.title' => 'Информация',
			'about.goalTitle' => 'Зачем это',
			'about.goal' => 'copi сам копирует локальные папки на другой диск. Один раз указываете папки, которые обычно переносите руками, сохраняете копию и запускаете её в следующий раз.',
			'about.canTitle' => 'Что умеет',
			'about.can' => 'Запоминает пары папок и копирует всё, что лежит внутри: обычные файлы, скрытые и ссылки. Новые и изменённые переносятся снова. В режиме «Как в источнике» из копии уходит то, чего в папке уже нет. Прогресс виден на экране, запуск можно отменить.',
			'about.limitsTitle' => 'Ограничения',
			'about.limits' => 'Файл считается тем же, если совпали размер и дата, без сверки по хешу. Ссылка копируется как ссылка, файл за пределами папки по ней не подтягивается. Метки Finder, права и прочие атрибуты macOS не переносятся. Windows пока не поддерживается.',
			'logs.title' => 'Логи',
			'errors.destinationUnavailable' => 'Диск назначения недоступен. Ничего не удалено.',
			'errors.sameLocation' => 'Источник и назначение — одна и та же папка.',
			'errors.accessDenied' => 'Папку не удалось открыть. Ничего не скопировано.',
			'errors.fileFailed' => 'Не удалось обработать файл. Уже сделанное остаётся на диске.',
			'errors.bookmark' => 'Не удалось сохранить разрешение на папку.',
			_ => null,
		};
	}
}
