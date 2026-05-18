enum ProgressBreakdownMode {
  demographics,
  ministries;

  String get label => switch (this) {
        ProgressBreakdownMode.demographics => 'Demographics',
        ProgressBreakdownMode.ministries => 'Ministries',
      };
}
