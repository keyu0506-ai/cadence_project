# Task extraction

Capture sends typed notes or one local PNG/JPEG to the authenticated Firebase
callable `extractTasks` in `us-central1`. The function calls OpenAI and returns
validated drafts with title, subject, deadline and notes. Missing or ambiguous
deadlines remain empty. Users review/edit/select drafts before confirmation
writes them to Firestore. Extraction itself never saves tasks or source images.

The OpenAI key stays in the `OPENAI_API_KEY` Firebase secret. The model is
`gpt-4.1-mini`, configured through `TASK_EXTRACTION_MODEL`. Requests accept up to
20,000 text characters or a 10 MB PNG/JPEG. Images are sent to OpenAI for analysis;
the Responses request sets `store: false`.

## Deploy

On Windows, run `./deploy-functions.ps1` from the project root. It allows 60
seconds for Firebase CLI source discovery and restores the previous environment
setting afterward. The OpenAI SDK is loaded only when a request needs it.
For a manual PowerShell deployment, set `$env:FUNCTIONS_DISCOVERY_TIMEOUT='60'`
before `firebase deploy --only functions`. This is separate from the function's
90-second request timeout. See [Firebase discovery timeout guidance](https://firebase.google.com/docs/functions/tips#avoid_deployment_timeouts_during_initialization).

Install dependencies with `npm --prefix functions ci`. Set the non-secret model
in `functions/.env.project-database-3265e`:

```dotenv
TASK_EXTRACTION_MODEL=gpt-4.1-mini
```

Deploy with `firebase deploy --only functions:extractTasks --project project-database-3265e`.
The Firebase secret must be enabled and the OpenAI API account must have credits.
The live API check on October 7, 2026 returned `credit_balance_exhausted`;
successful live extraction could not be verified until credits are added.

Deployment succeeded on October 7, 2026, and the deployed endpoint correctly
rejected an unauthenticated request. Firebase CLI exited with a housekeeping
warning because no Artifact Registry cleanup policy is configured in
`us-central1`; this did not prevent function creation.

## Test

Run `npm --prefix functions test`, `flutter test`, and `flutter analyze`.
Fully restart Flutter after installing the new Cloud Functions dependency.

1. Sign in, open Capture, and upload a syllabus or homework screenshot.
2. Press Extract tasks. Verify titles, subjects, notes and deadlines against the image.
3. Edit a draft, deselect another, and set dates for any selected undated tasks.
4. Confirm. Check Today/Upcoming on Home and refresh to verify persistence.
5. Try typed notes, an image with no tasks, and a network failure. Errors should
   retain the input for retry; no tasks should save before confirmation.

The deterministic extractor is retained only for tests. Model errors, timeout,
empty results and exhausted API credits have separate user-facing states.

API references: [image inputs](https://developers.openai.com/api/docs/guides/images-vision)
and [structured outputs](https://developers.openai.com/api/docs/guides/structured-outputs).
