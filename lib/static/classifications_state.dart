sealed class ClassificationsState {}

class ClassificationsNoneState extends ClassificationsState {}

class ClassificationsLoadingState extends ClassificationsState {}

class ClassificationsLoadedState extends ClassificationsState {
  final Map<String, num> result;

  ClassificationsLoadedState(this.result);
}

class ClassificationsErrorState extends ClassificationsState {
  final String error;

  ClassificationsErrorState(this.error);
}
