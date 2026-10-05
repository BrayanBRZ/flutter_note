class Schema {
  Schema._();

  static const List<String> createTables = [
    '''
      CREATE TABLE reminder(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        regularity TEXT NOT NULL,
        regular_time TEXT NOT NULL,
        remind_before INTEGER NOT NULL,
        is_active INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE subject(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE tag(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL COLLATE NOCASE UNIQUE,
        color INTEGER NOT NULL,
        reminder_id INTEGER NOT NULL UNIQUE,
        is_default INTEGER NOT NULL DEFAULT 0 CHECK(is_default IN (0, 1)),
        FOREIGN KEY (reminder_id) REFERENCES reminder (id)
      )
    ''',
    '''
      CREATE TABLE task(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        regularity TEXT NOT NULL,
        target_date TEXT NOT NULL,
        tag_id INTEGER NOT NULL DEFAULT 1,
        subject_id INTEGER,
        reminder_id INTEGER UNIQUE,
        description TEXT,
        FOREIGN KEY (tag_id) REFERENCES tag (id) ON DELETE SET DEFAULT,
        FOREIGN KEY (subject_id) REFERENCES subject (id) ON DELETE SET NULL,
        FOREIGN KEY (reminder_id) REFERENCES reminder (id) ON DELETE SET NULL
      )
    ''',
  ];

  static const List<String> createTriggers = [
    '''
      CREATE TRIGGER prevent_tag_reminder_update
      BEFORE UPDATE OF reminder_id ON tag
      WHEN OLD.reminder_id != NEW.reminder_id
      BEGIN
        SELECT RAISE(ABORT, 'tag reminder cannot be changed');
      END
    ''',
    '''
      CREATE TRIGGER delete_tag_reminder_after_tag_delete
      AFTER DELETE ON tag
      BEGIN
        DELETE FROM reminder WHERE id = OLD.reminder_id;
      END
    ''',
  ];

  // Existing installations retain the original protection triggers.
  static const List<String> unlockDefaultTags = [
    'DROP TRIGGER IF EXISTS prevent_default_tag_update',
    'DROP TRIGGER IF EXISTS prevent_default_tag_delete',
  ];
}
