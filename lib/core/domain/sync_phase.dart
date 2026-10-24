/// Фаза одного запуска пресета.
enum SyncPhase {
  scanning,
  copying,
  deleting,
  done,
  error,
  cancelled,
}
