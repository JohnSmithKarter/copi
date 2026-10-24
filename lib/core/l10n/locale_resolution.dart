/// Ключ выбранного языка в настройках.
const localeStorageKey = 'locale';

/// Русский, если система русская и выбора ещё нет. Иначе английский.
/// Сохранённое значение не перезаписывается языком системы.
String resolveInitialLocale({
  required String? stored,
  required String systemLanguageCode,
}) {
  if (stored == 'ru') {
    return 'ru';
  }
  if (stored == 'en') {
    return 'en';
  }
  return systemLanguageCode == 'ru' ? 'ru' : 'en';
}
