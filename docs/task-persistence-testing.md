# Task persistence: setup and testing

The app extracts tasks from text or an uploaded image through a Firebase callable
function backed by OpenAI. Confirmed tasks use Firestore. See
`task-extraction.md` for extraction setup and testing.

## One-time Firebase setup

1. Open Firebase Console for `project-database-3265e` (the project already in
   `lib/firebase_options.dart`).
2. Under Firestore Database, create the **default** database if it does not exist.
   Use Firestore Standard edition / Native mode and production rules. Choose the
   region appropriate for your users; this implementation does not choose one.
3. In Firestore's Rules tab, publish the contents of the root `firestore.rules`
   file. If the project already has rules for other features, merge this task
   match block with those rules instead of removing their access rules. Remove
   any broad test-mode rule that grants access to every document: it would also
   grant access to other users' tasks.
4. Alternatively, with Firebase CLI installed and signed in, deploy the local
   rules using:

   ```powershell
   firebase deploy --only firestore:rules --project project-database-3265e
   ```

   This command publishes the entire local ruleset, so review existing remote
   rules first. No database or rules deployment was performed by this change.

No parent user document needs to be manually created. Documents are written to
`users/{Firebase Authentication UID}/tasks/{task ID}`. Each document contains
`title`, `dueDate` as `YYYY-MM-DD`, `notes`, and `subject` (optional strings).
Older documents without `subject` still load. Republish `firestore.rules` before
saving with the updated app: the previous rules reject the new subject field.
IDs are the
document IDs. Rules permit the owner to read/create/update these task documents;
other users and signed-out clients cannot access them. Delete is not implemented.

## Start the app

From the project directory:

```powershell
flutter pub get
flutter run -d chrome
```

Use a full restart after adding the Firestore plugin, rather than hot reload.

## Happy-path checks

1. Sign in as account A. Open Capture from Home, select Text, enter
   "Read chapter 3 today. Submit the worksheet in three days. Bring a pen.",
   and press Extract tasks.
2. Tap the pencil on the first card; edit its title, subject, and custom note.
   Leave it due today. Leave the
   second task due in three days. Deselect any other tasks and confirm both.
   Tasks without deadlines start unselected; choose a date before saving them.
3. The button shows Saving while awaiting Firestore acknowledgement. Once it
   succeeds, Home displays the first task under Today's Plan and the second under
   Upcoming Deadlines, including notes and dates.
4. Refresh Chrome. The tasks should reload. Sign out and back in as account A;
   the same tasks should return.
5. Sign in as account B. A's tasks must not appear. Create a task for B, then
   switch back to A; A should still see only A's tasks.
6. Run capture again, deselect one result, and save. Only the selected result
   should be added. Blank selected titles are rejected. Check the Firestore Data
   tab to verify the exact documents and account UID.

Re-extracting in a new capture session intentionally creates new task IDs. Retry
protection applies to confirming the same drafts, not matching similar titles.

## Failure and retry checks

1. Extract tasks, edit them, then switch the browser/network offline before
   confirming. The app should stay on Capture. After approximately 20 seconds,
   it explains that saving was not confirmed and retains your edits.
2. Reconnect and retry the same drafts. Verify only one document per draft ID
   exists. A timed-out Firestore batch can still finish after reconnection;
   retries write to the same IDs. Do not start a new capture to retry this save.
3. Rapidly press Confirm while Saving is shown. It must not submit another save
   or let you edit the submitted draft while the acknowledgement is pending.
4. A Firestore read failure should show Could not load tasks and a Retry button,
   rather than an empty list. Test permission failures in a development Firebase
   project or emulator, not by weakening production rules.
5. In Firebase's Rules Playground, check a document path such as
   `/users/alice/tasks/test`: authenticated UID `alice` should be allowed to read
   and write a valid task; UID `bob` and unauthenticated requests must be denied.
   An invalid task (empty title, missing date, unexpected fields) must be denied.

## Automated checks

```powershell
flutter analyze
flutter test
```

Tests cover serialization, invalid dates, owner-scoped batch paths, save
acknowledgement and errors, account switching, selection and edit preservation,
stable IDs on retry, and Home loading/error/retry behavior. They use controlled
repository/Firestore doubles; they do not verify the deployed database or
execute Firestore security rules. The live steps above remain necessary.

For these two milestones, overdue display and automatic midnight refresh are
still deferred. Use today/future dates when checking Home grouping.
